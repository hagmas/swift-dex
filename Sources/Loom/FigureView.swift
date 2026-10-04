import SwiftUI

/// Renders a ``Figure``.
///
/// ```swift
/// FigureView(RefactorFigure())
/// ```
///
/// The arrangement is laid out by SwiftUI, each node publishes where it landed,
/// and the lines are drawn from those positions — behind the nodes, so a line
/// arriving at a box never draws across it.
public struct FigureView<Content: Figure>: View {
    private let figure: Content
    private let spacing: CGFloat
    private let routing: Line.Routing

    @Environment(\.figureScale) private var scale
    @Environment(\.lineStyle) private var lineStyle

    /// Renders a figure.
    ///
    /// - Parameters:
    ///   - figure: The figure to draw.
    ///   - spacing: How far apart lines sharing an edge or a waypoint are held.
    ///   - routing: How lines get where they are going. A line can override it,
    ///     but a figure almost always wants one kind of line throughout.
    public init(
        _ figure: Content,
        spacing: CGFloat = 10,
        routing: Line.Routing = .straight
    ) {
        self.figure = figure
        self.spacing = spacing
        self.routing = routing
    }

    /// The content and behavior of the view.
    public var body: some View {
        // The arrangement's root may hold several elements. Stacking them here
        // gives the outermost container a direction, which is the same one
        // `Placement.addresses(in:)` reads a line's leaving edge from.
        let spacing = spacing * scale
        let lines = figure.lines

        ScaledVStack(alignment: .center, spacing: 8, content: figure.arrangement.elementBody)
            .environment(\.waypointSpans, WaypointSpans.spans(for: lines, spacing: spacing))
            // The lines are read outside the arrangement, in the space the figure
            // was given rather than the one it takes up. An arrangement that grows
            // or shrinks drags its own space with it, and an anchor resolved
            // against a space that is itself moving comes out somewhere the node
            // is not — which never shows while a figure is still, and shows up
            // badly the moment one animates.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundPreferenceValue(NodeAnchorsPreference.self) { anchors in
                GeometryReader { proxy in
                    let placements = figure.arrangement.placements
                    let routes = LineRouter.routes(
                        for: lines,
                        rects: anchors.mapValues { proxy[$0] },
                        addresses: Placement.addresses(in: placements),
                        waypointAxes: Placement.waypointAxes(in: placements),
                        routing: routing,
                        spacing: spacing
                    )
                    ForEach(routes.indices, id: \.self) { index in
                        let route = routes[index]
                        LineView(
                            route: route,
                            style: lines[route.line].style ?? lineStyle,
                            scale: scale
                        )
                    }
                }
            }
    }
}

/// One line, drawn through the points it was routed along.
private struct LineView: View {
    let route: RoutedLine
    let style: LineStyle
    let scale: CGFloat

    private var width: CGFloat {
        style.width * scale
    }

    private var head: CGFloat {
        style.arrowHead.size.map { $0 * scale } ?? width * 5
    }

    var body: some View {
        let points = route.points

        ZStack {
            Path { path in
                path.addLines(stroked(points))
            }
            .stroke(style.color, style: StrokeStyle(lineWidth: width, dash: style.dash.map { $0 * scale }))

            if route.arrow.tipsEnd, points.count >= 2 {
                arrowHead(at: points[points.count - 1], from: points[points.count - 2])
            }

            if route.arrow.tipsStart, points.count >= 2 {
                arrowHead(at: points[0], from: points[1])
            }

            if let label = route.label, let middle = route.labelPoint {
                Text(label)
                    .font(.system(size: style.labelFontSize * scale))
                    .foregroundStyle(style.labelColor)
                    .padding(.horizontal, style.labelPadding * scale)
                    // Opaque, so the line reads as split by the words rather
                    // than running under them. On a background that is not a
                    // flat colour, the line shows through.
                    .background(style.labelBackground)
                    .position(middle)
            }
        }
    }

    @ViewBuilder
    private func arrowHead(at tip: CGPoint, from: CGPoint) -> some View {
        // An outline is stroked centred on its path, so its rounded tip
        // reaches half a width past the point it is drawn to. Drawn that much
        // short, it ends where a filled head would.
        let drawnTip = pulled(tip, towards: from, by: width / 2)

        switch style.arrowHead.shape {
        case .filled:
            ArrowHeadShape(tip: tip, from: from, size: head, closed: true)
                .fill(style.color)

        case .hollow:
            ArrowHeadShape(tip: drawnTip, from: from, size: head, closed: true)
                .stroke(style.color, style: StrokeStyle(lineWidth: width, lineJoin: .round))

        case .open:
            ArrowHeadShape(tip: drawnTip, from: from, size: head, closed: false)
                .stroke(style.color, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
    }
}

private extension LineView {
    /// How far short of a tipped end the stroke stops.
    ///
    /// A stroke ends square across its full width. Run up to the point of a
    /// filled head it pokes out either side, so it stops halfway in, where the
    /// head is still twice the line's width. A hollow head must not have the
    /// line showing inside it, so the stroke stops at its base. An open head
    /// is two strokes meeting at a point, and the line meets them there.
    var inset: CGFloat {
        switch style.arrowHead.shape {
        case .filled: head / 2
        case .hollow: width / 2 + head
        case .open: width / 2
        }
    }

    /// The points the stroke runs through, stopped short of any arrowhead.
    func stroked(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 2 else {
            return points
        }

        var points = points
        if route.arrow.tipsEnd {
            points[points.count - 1] = pulled(points[points.count - 1], towards: points[points.count - 2], by: inset)
        }
        if route.arrow.tipsStart {
            points[0] = pulled(points[0], towards: points[1], by: inset)
        }
        return points
    }

    /// `point`, moved `distance` towards `target` but never past it.
    func pulled(_ point: CGPoint, towards target: CGPoint, by distance: CGFloat) -> CGPoint {
        let dx = target.x - point.x
        let dy = target.y - point.y
        let length = (dx * dx + dy * dy).squareRoot()
        guard length > 0 else {
            return point
        }
        let step = min(distance, length) / length
        return CGPoint(x: point.x + dx * step, y: point.y + dy * step)
    }
}

/// A triangle at `tip`, pointing away from `from` — or, left open, just the
/// two sides that meet at the tip.
private struct ArrowHeadShape: Shape {
    let tip: CGPoint
    let from: CGPoint
    let size: CGFloat
    let closed: Bool

    func path(in rect: CGRect) -> Path {
        let dx = tip.x - from.x
        let dy = tip.y - from.y
        let length = (dx * dx + dy * dy).squareRoot()

        var path = Path()
        guard length > 0 else {
            return path
        }

        // Unit vector along the line, and its perpendicular.
        let ux = dx / length
        let uy = dy / length
        let base = CGPoint(x: tip.x - ux * size, y: tip.y - uy * size)
        let half = size * 0.4
        let left = CGPoint(x: base.x - uy * half, y: base.y + ux * half)
        let right = CGPoint(x: base.x + uy * half, y: base.y - ux * half)

        if closed {
            path.move(to: tip)
            path.addLine(to: left)
            path.addLine(to: right)
            path.closeSubpath()
        }
        else {
            path.move(to: left)
            path.addLine(to: tip)
            path.addLine(to: right)
        }
        return path
    }
}
