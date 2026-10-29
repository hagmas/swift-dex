import Loom
import SwiftUI

extension Scenario {
    /// A flowchart whose "no" branch loops back up round the side.
    static let flowchart = Scenario(name: "Flowchart", steps: 0) { _ in
        AnyView(FigureView(Flowchart(aligned: false), routing: .orthogonal))
    }

    /// The same flowchart with its boxes lined up on a spine, so the lines
    /// down it run straight.
    static let flowchartAligned = Scenario(name: "Flowchart, aligned", steps: 0) { _ in
        AnyView(FigureView(Flowchart(aligned: true), routing: .orthogonal))
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
        Column(alignment: aligned ? .columnSpine : .center, spacing: 40) {
            Row { TextNode(.start, title: "Start") }
            Row(spacing: 64) {
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
