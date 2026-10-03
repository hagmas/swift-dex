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
    private let color: Color
    private let width: CGFloat
    private let spacing: CGFloat
    private let routing: Line.Routing

    @Environment(\.figureScale) private var scale

    /// Renders a figure.
    ///
    /// - Parameters:
    ///   - figure: The figure to draw.
    ///   - color: The colour of the lines.
    ///   - width: The stroke width of the lines.
    ///   - spacing: How far apart lines sharing an edge or a waypoint are held.
    ///   - routing: How lines get where they are going. A line can override it,
    ///     but a figure almost always wants one kind of line throughout.
    public init(
        _ figure: Content,
        color: Color = .black,
        width: CGFloat = 1.5,
        spacing: CGFloat = 10,
        routing: Line.Routing = .straight
    ) {
        self.figure = figure
        self.color = color
        self.width = width
        self.spacing = spacing
        self.routing = routing
    }

    /// The content and behavior of the view.
    public var body: some View {
        // The arrangement's root may hold several elements. Stacking them here
        // gives the outermost container a direction, which is the same one
        // `Placement.addresses(in:)` reads a line's leaving edge from.
        let spacing = spacing * scale

        ScaledVStack(alignment: .center, spacing: 8, content: figure.arrangement.elementBody)
            .environment(\.waypointSpans, WaypointSpans.spans(for: figure.lines, spacing: spacing))
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
                        for: figure.lines,
                        rects: anchors.mapValues { proxy[$0] },
                        addresses: Placement.addresses(in: placements),
                        waypointAxes: Placement.waypointAxes(in: placements),
                        routing: routing,
                        spacing: spacing
                    )
                    ForEach(routes.indices, id: \.self) { index in
                        LineView(route: routes[index], color: color, width: width * scale, scale: scale)
                    }
                }
            }
    }
}

/// One line, drawn through the points it was routed along.
private struct LineView: View {
    let route: RoutedLine
    let color: Color
    let width: CGFloat
    let scale: CGFloat

    private var head: CGFloat {
        width * 5
    }

    var body: some View {
        let points = route.points

        ZStack {
            Path { path in
                path.addLines(stroked(points))
            }
            .stroke(color, lineWidth: width)

            if route.arrow.tipsEnd, points.count >= 2 {
                ArrowHead(tip: points[points.count - 1], from: points[points.count - 2], size: head)
                    .fill(color)
            }

            if route.arrow.tipsStart, points.count >= 2 {
                ArrowHead(tip: points[0], from: points[1], size: head)
                    .fill(color)
            }

            if let label = route.label, let middle = route.labelPoint {
                Text(label)
                    .font(.system(size: 10 * scale))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 4 * scale)
                    // Opaque, so the line reads as split by the words rather
                    // than running under them. It assumes a white page, and on
                    // a background that is not a flat colour the line shows
                    // through.
                    .background(.white)
                    .position(middle)
            }
        }
    }
}

private extension LineView {
    /// The points the stroke runs through, stopped short of any arrowhead.
    ///
    /// A stroke ends square across its full width, and an arrowhead narrows to
    /// a point, so a line drawn right up to the tip pokes out either side of
    /// it — more visibly the thicker the line. Stopping halfway into the head
    /// leaves the end where the head is still twice the line's width.
    func stroked(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 2 else {
            return points
        }

        var points = points
        let inset = head / 2
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

/// A filled triangle at `tip`, pointing away from `from`.
private struct ArrowHead: Shape {
    let tip: CGPoint
    let from: CGPoint
    let size: CGFloat

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

        path.move(to: tip)
        path.addLine(to: CGPoint(x: base.x - uy * half, y: base.y + ux * half))
        path.addLine(to: CGPoint(x: base.x + uy * half, y: base.y - ux * half))
        path.closeSubpath()
        return path
    }
}
