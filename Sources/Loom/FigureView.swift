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
    private let routing: LineRouting

    /// Renders a figure.
    ///
    /// - Parameters:
    ///   - figure: The figure to draw.
    ///   - color: The colour of the lines.
    ///   - width: The stroke width of the lines.
    ///   - spacing: How far apart lines sharing an edge or a tie are held.
    ///   - routing: How lines get where they are going. A line can override it,
    ///     but a figure almost always wants one kind of line throughout.
    public init(
        _ figure: Content,
        color: Color = .secondary,
        width: CGFloat = 1.5,
        spacing: CGFloat = 10,
        routing: LineRouting = .straight
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
        VStack {
            figure.arrangement.elementBody
        }
        .environment(\.tieSpans, TieSpans.spans(for: figure.lines, spacing: spacing))
        .backgroundPreferenceValue(NodeAnchorsPreference.self) { anchors in
            GeometryReader { proxy in
                let placements = figure.arrangement.placements
                let routes = LineRouter.routes(
                    for: figure.lines,
                    rects: anchors.mapValues { proxy[$0] },
                    addresses: Placement.addresses(in: placements),
                    tieAxes: Placement.tieAxes(in: placements),
                    routing: routing,
                    spacing: spacing
                )
                ForEach(routes.indices, id: \.self) { index in
                    LineView(route: routes[index], color: color, width: width)
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

    private var head: CGFloat {
        width * 5
    }

    var body: some View {
        let points = route.points

        ZStack {
            Path { path in
                path.addLines(points)
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

            if let label = route.label, let middle = points.middle {
                Text(label)
                    .font(.caption)
                    .padding(.horizontal, 4)
                    // Opaque, so the line reads as split by the words rather
                    // than running under them. It matches whatever `Box` fills
                    // itself with, and has the same limit: on a background that
                    // is not a flat colour, the line shows through.
                    .background(.background)
                    .position(middle)
            }
        }
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
