import Loom
import SwiftUI

extension Scenario {
    /// A figure inside a node of another, its node IDs repeating the outer
    /// figure's on purpose.
    ///
    /// It grows a node inside, then one outside, so that the lines on both
    /// sides have to follow the node holding the figure.
    static let nested = Scenario(name: "Nested", steps: 2) { step in
        AnyView(FigureView(System(step: step), routing: .orthogonal))
    }
}

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
    static let c = NodeID("c")
    static let backend = NodeID("backend")
}

private let containerFill = Color(white: 0.96)

private extension NodeStyle {
    static let container = NodeStyle.standard.with {
        $0.fill = containerFill
        $0.fontWeight = .medium
    }
}

private struct System: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 48) {
            Row(spacing: 32) {
                TextNode(.a, title: "App")
                TextNode(.b, title: "Logs")
                if step >= 2 {
                    TextNode(.c, title: "Metrics")
                }
            }
            Row { Backend(id: .backend, step: step).nodeStyle(.container) }
        }
    }

    var lines: [Line] {
        Line(from: .a, to: .backend, label: "calls")
        Line(from: .a, to: .b)
        Line(from: .b, to: .c)
    }
}

/// A node holding a figure of its own.
private struct Backend: Node {
    let id: NodeID
    var step: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("Backend")
            // The container's style would reach the nodes inside too, so they
            // are given the standard one back. The words on the lines are
            // backed in the container's colour, so they still look to split
            // the line rather than sit on a patch.
            FigureView(Services(step: step), routing: .orthogonal)
                .nodeStyle(.standard)
                .lineStyle(LineStyle(labelBackground: containerFill))
        }
    }
}

/// The figure inside, with the same IDs as the one outside.
private struct Services: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 32) {
            Row(spacing: 48) {
                TextNode(.a, title: "API")
                TextNode(.b, title: "DB")
            }
            if step >= 1 {
                Row(spacing: 48) {
                    Empty()
                    TextNode(.c, title: "Cache")
                }
            }
        }
    }

    var lines: [Line] {
        Line(from: .a, to: .b, label: "queries")
        Line(from: .b, to: .c)
    }
}
