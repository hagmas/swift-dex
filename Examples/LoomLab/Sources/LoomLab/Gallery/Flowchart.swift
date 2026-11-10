import Loom
import SwiftUI

/// A flowchart whose "no" branch loops back up round the side, twice side by
/// side: as written, and with its boxes lined up on a spine so the lines down
/// it run straight.
struct FlowchartScenario: Scenario {
    static let name = "Flowchart"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Flowcharts(), routing: routing)
            .nodeStyle(.frosty(.soda))
            .lineStyle(.iceCandy)
    }
}

/// The node IDs of one of the two flowcharts.
///
/// The two sit in the same figure, boxed in clusters, so each needs IDs of
/// its own: the same names, under its own prefix.
private struct ChartIDs {
    let start: NodeID
    let fetch: NodeID
    let valid: NodeID
    let save: NodeID
    let done: NodeID
    let back: NodeID

    init(_ prefix: String) {
        start = NodeID("\(prefix).start")
        fetch = NodeID("\(prefix).fetch")
        valid = NodeID("\(prefix).valid")
        save = NodeID("\(prefix).save")
        done = NodeID("\(prefix).done")
        back = NodeID("\(prefix).back")
    }

    static let asWritten = ChartIDs("written")
    static let aligned = ChartIDs("aligned")
}

private extension NodeID {
    static let asWritten = NodeID("asWritten")
    static let aligned = NodeID("aligned")
}

private struct Flowcharts: Figure {
    var arrangement: some FigureElement {
        Row(alignment: .top, spacing: 56) {
            Cluster(.asWritten, title: "As written") {
                chart(.asWritten, aligned: false)
            }
            .clusterStyle(.frosty(.caramel))
            Cluster(.aligned, title: "Aligned") {
                chart(.aligned, aligned: true)
            }
            .clusterStyle(.frosty(.melon))
        }
    }

    var lines: [Line] {
        lines(of: .asWritten) + lines(of: .aligned)
    }

    /// One flowchart.
    ///
    /// Unaligned, the waypoint beside "Fetch data" pulls that row's middle off
    /// the others', and every line through it bends. Aligned, the boxes line
    /// up on the column's spine.
    private func chart(_ ids: ChartIDs, aligned: Bool) -> some FigureElement {
        Column(alignment: aligned ? .columnSpine : .center, spacing: 56) {
            Row { TextNode(ids.start, title: "Start") }
            Row(spacing: 88) {
                TextNode(ids.fetch, title: "Fetch data").aligned(on: .columnSpine)
                Waypoint(ids.back)
            }
            Row { TextNode(ids.valid, title: "Valid?") }
            Row { TextNode(ids.save, title: "Save") }
            Row { TextNode(ids.done, title: "Done") }
        }
    }

    private func lines(of ids: ChartIDs) -> [Line] {
        [
            Line(from: ids.start, to: ids.fetch),
            Line(from: ids.fetch, to: ids.valid),
            Line(from: ids.valid, to: ids.save, label: "yes"),
            Line(from: ids.valid.trailing, to: ids.fetch.trailing, through: ids.back, label: "no"),
            Line(from: ids.save, to: ids.done),
        ]
    }
}
