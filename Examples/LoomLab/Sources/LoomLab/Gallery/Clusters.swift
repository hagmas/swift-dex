import Loom
import SwiftUI

/// Clusters, one inside another, with lines across their boxes to the
/// nodes in them and one to a box as a whole.
///
/// It grows a node inside the inner cluster, then one outside both, so
/// that the boxes have to grow and the lines across them follow.
struct ClustersScenario: Scenario {
    static let name = "Clusters"
    static let steps = 2

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Architecture(step: step), routing: routing)
            .nodeStyle(NodeStyle(minWidth: 128))
    }
}

private extension NodeID {
    static let client = NodeID("client")
    static let monitor = NodeID("monitor")
    static let vpc = NodeID("vpc")
    static let backend = NodeID("backend")
    static let api = NodeID("api")
    static let worker = NodeID("worker")
    static let database = NodeID("database")
    static let storage = NodeID("storage")
}

private extension ClusterStyle {
    static let network = ClusterStyle.standard.with {
        $0.fill = .white
        $0.stroke = .orange
        $0.dash = [8, 6]
        $0.titleColor = .orange
    }
}

private struct Architecture: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(alignment: .columnSpine, spacing: 68) {
            Row { TextNode(.client, title: "Client") }
            // The monitor beside the network rather than above it, so that
            // its line comes in from the side instead of alongside the
            // client's — level with the worker it watches, so it runs
            // straight across both boxes.
            Row(alignment: .rowSpine, spacing: 88) {
                Cluster(.vpc, title: "VPC") {
                    Row(alignment: .rowSpine, spacing: 44) {
                        TextNode(.database, title: "Database").aligned(on: .rowSpine)
                        Cluster(.backend, title: "Backend") {
                            Row(spacing: 32) {
                                TextNode(.api, title: "API").aligned(on: .rowSpine)
                                if step >= 1 {
                                    TextNode(.worker, title: "Worker").aligned(on: .columnSpine)
                                }
                            }
                        }
                        // The network's style would reach the cluster inside
                        // it too, so it is given the standard one back.
                        .clusterStyle(.standard)
                    }
                }
                .clusterStyle(.network)
                TextNode(.monitor, title: "Monitor").aligned(on: .rowSpine)
            }
            if step >= 2 {
                // Under the worker, across both boxes, so the line down to it
                // runs straight rather than turning wherever halfway falls —
                // which here would be along the network's edge.
                Row { TextNode(.storage, title: "S3").aligned(on: .columnSpine) }
            }
        }
    }

    var lines: [Line] {
        Line(from: .client, to: .api, label: "calls")
        Line(from: .monitor, to: .worker, label: "watches")
        Line(from: .api, to: .database)
        Line(from: .worker, to: .storage, label: "uploads")
    }
}
