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

    /// Renders a figure.
    ///
    /// - Parameters:
    ///   - figure: The figure to draw.
    ///   - color: The colour of the lines.
    ///   - width: The stroke width of the lines.
    public init(
        _ figure: Content,
        color: Color = .secondary,
        width: CGFloat = 1.5
    ) {
        self.figure = figure
        self.color = color
        self.width = width
    }

    /// The content and behavior of the view.
    public var body: some View {
        figure.arrangement.elementBody
            .backgroundPreferenceValue(NodeAnchorsPreference.self) { anchors in
                GeometryReader { proxy in
                    let lines = figure.lines
                    ForEach(lines.indices, id: \.self) { index in
                        let line = lines[index]
                        if let from = anchors[line.from], let to = anchors[line.to] {
                            LineView(
                                from: proxy[from],
                                to: proxy[to],
                                arrow: line.arrow,
                                color: color,
                                width: width
                            )
                        }
                    }
                }
            }
    }
}

/// One line, drawn between two placed nodes.
private struct LineView: View {
    let from: CGRect
    let to: CGRect
    let arrow: Line.Arrow
    let color: Color
    let width: CGFloat

    private var head: CGFloat {
        width * 5
    }

    var body: some View {
        let ends = LineRouter.endpoints(from: from, to: to)

        ZStack {
            Path { path in
                path.move(to: ends.start)
                path.addLine(to: ends.end)
            }
            .stroke(color, lineWidth: width)

            if arrow.tipsEnd {
                ArrowHead(tip: ends.end, from: ends.start, size: head)
                    .fill(color)
            }

            if arrow.tipsStart {
                ArrowHead(tip: ends.start, from: ends.end, size: head)
                    .fill(color)
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
