import Loom
import SwiftUI

/// A figure inside a node of another, its node IDs repeating the outer
/// figure's on purpose.
///
/// It grows a node inside, then one outside, so that the lines on both
/// sides have to follow the node holding the figure. The figure inside
/// has a loop and a line going round the outside, which reach past its
/// nodes, so the node makes room for them.
struct NestedScenario: Scenario {
    static let name = "Nested"
    static let steps = 2

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(System(step: step, routing: routing), routing: routing)
            .nodeStyle(.frosty(.soda))
            .lineStyle(.iceCandy)
    }
}

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
    static let c = NodeID("c")
    static let backend = NodeID("backend")
}

private extension NodeStyle {
    /// A frosty box rather than a capsule: a capsule's ends would round off
    /// the figure inside.
    static let container = NodeStyle.frosty(.soda).with {
        $0.shape = .roundedRectangle(cornerRadius: 22)
        $0.fill = IceCandy.Flavor.soda.lightened(by: 0.92)
    }
}

private struct System: Figure {
    var step: Int

    /// How the lines are drawn, inside the backend as well as out.
    var routing: Line.Routing

    var arrangement: some FigureElement {
        Column(spacing: 68) {
            Row(spacing: 44) {
                TextNode(.a, title: "App")
                TextNode(.b, title: "Logs")
                if step >= 2 {
                    TextNode(.c, title: "Metrics")
                }
            }
            Row { Backend(id: .backend, step: step, routing: routing).nodeStyle(.container) }
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
    var routing: Line.Routing

    var body: some View {
        VStack(spacing: 6) {
            Text("Backend")
            // The container's style would reach the nodes inside too, so they
            // are given one of their own.
            FigureView(Services(step: step), routing: routing)
                .nodeStyle(.frosty(.grape))
                // The node is as big as the figure's nodes and cuts off what
                // goes past them: room for the loop above, and for the line
                // going round on the right.
                .padding(EdgeInsets(top: 28, leading: 0, bottom: 0, trailing: 44))
        }
    }
}

/// The figure inside, with the same IDs as the one outside.
private struct Services: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 44) {
            Row(spacing: 68) {
                TextNode(.a, title: "API")
                TextNode(.b, title: "DB")
            }
            if step >= 1 {
                Row(spacing: 68) {
                    Empty()
                    TextNode(.c, title: "Cache")
                }
            }
        }
    }

    var lines: [Line] {
        Line(from: .a, to: .b, label: "queries")
        Line(from: .b, to: .c)
        Line(looping: .a.top, label: "retries")
        Line(from: .c.trailing, to: .b.trailing, label: "refills")
    }
}
