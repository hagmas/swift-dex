import Loom
import SwiftUI

extension Scenario {
    /// Clusters, one inside another, with lines across their boxes to the
    /// nodes in them and one to a box as a whole.
    ///
    /// It grows a node inside the inner cluster, then one outside both, so
    /// that the boxes have to grow and the lines across them follow.
    static let clusters = Scenario(name: "Clusters", steps: 2) { step in
        AnyView(
            FigureView(Architecture(step: step), routing: .orthogonal)
                .nodeStyle(NodeStyle(minWidth: 90))
        )
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
        $0.dash = [6, 4]
        $0.titleColor = .orange
    }
}

private struct Architecture: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(alignment: .columnSpine, spacing: 48) {
            Row { TextNode(.client, title: "Client") }
            // The monitor beside the network rather than above it, so that
            // its line comes in from the side instead of alongside the
            // client's — level with the worker it watches, so it runs
            // straight across both boxes.
            Row(alignment: .rowSpine, spacing: 64) {
                Cluster(.vpc, title: "VPC") {
                    Row(alignment: .rowSpine, spacing: 32) {
                        TextNode(.database, title: "Database").aligned(on: .rowSpine)
                        Cluster(.backend, title: "Backend") {
                            Row(spacing: 24) {
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
