import Loom
import SwiftUI

/// A flowchart whose "no" branch loops back up round the side.
struct FlowchartScenario: Scenario {
    static let name = "Flowchart"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Flowchart(aligned: false), routing: routing)
    }
}

/// The same flowchart with its boxes lined up on a spine, so the lines
/// down it run straight.
struct AlignedFlowchartScenario: Scenario {
    static let name = "Flowchart, aligned"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Flowchart(aligned: true), routing: routing)
    }
}

private extension NodeID {
    static let start = NodeID("start")
    static let fetch = NodeID("fetch")
    static let valid = NodeID("valid")
    static let save = NodeID("save")
    static let done = NodeID("done")
    static let back = NodeID("back")
}

private struct Flowchart: Figure {
    /// Whether the boxes are lined up on the column's spine.
    ///
    /// Without it, the waypoint beside "Fetch data" pulls that row's middle
    /// off the others', and every line through it bends.
    var aligned: Bool

    var arrangement: some FigureElement {
        Column(alignment: aligned ? .columnSpine : .center, spacing: 56) {
            Row { TextNode(.start, title: "Start") }
            Row(spacing: 88) {
                TextNode(.fetch, title: "Fetch data").aligned(on: .columnSpine)
                Waypoint(.back)
            }
            Row { TextNode(.valid, title: "Valid?") }
            Row { TextNode(.save, title: "Save") }
            Row { TextNode(.done, title: "Done") }
        }
    }

    var lines: [Line] {
        Line(from: .start, to: .fetch)
        Line(from: .fetch, to: .valid)
        Line(from: .valid, to: .save, label: "yes")
        Line(from: .valid.trailing, to: .fetch.trailing, through: .back, label: "no")
        Line(from: .save, to: .done)
    }
}
