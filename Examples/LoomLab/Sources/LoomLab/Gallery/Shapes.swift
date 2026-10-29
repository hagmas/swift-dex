import Loom
import SwiftUI

extension Scenario {
    /// Nodes of every shape, with lines sitting side by side and a loop on
    /// them, so that their ends are off the middle of a side.
    static let shapes = Scenario(name: "Shapes", steps: 0) { _ in
        AnyView(FigureView(Shapes(), routing: .orthogonal))
    }
}

private extension NodeID {
    static let begin = NodeID("begin")
    static let ready = NodeID("ready")
    static let saving = NodeID("saving")
    static let check = NodeID("check")
    static let ok = NodeID("ok")
    static let retrying = NodeID("retrying")
    static let aside = NodeID("aside")
}

private extension NodeStyle {
    static let state = NodeStyle.standard.with {
        $0.shape = .circle
        $0.minWidth = 80
    }
    static let decision = NodeStyle.standard.with {
        $0.shape = .diamond
        $0.minWidth = 0
    }
    static let terminal = NodeStyle.standard.with { $0.shape = .capsule }
    static let note = NodeStyle.standard.with {
        $0.shape = .ellipse
        $0.minWidth = 0
    }
}

private struct Shapes: Figure {
    var arrangement: some FigureElement {
        Column(alignment: .columnSpine, spacing: 32) {
            Row { TextNode(.begin, title: "Begin").nodeStyle(.terminal) }
            Row(spacing: 48) {
                TextNode(.ready, title: "Ready").nodeStyle(.state).aligned(on: .columnSpine)
                TextNode(.aside, title: "Logs").nodeStyle(.note)
            }
            Row(spacing: 48) {
                TextNode(.saving, title: "Saving").nodeStyle(.state)
                TextNode(.check, title: "Valid?").nodeStyle(.decision).aligned(on: .columnSpine)
            }
            Row(spacing: 48) {
                TextNode(.ok, title: "Done").nodeStyle(.state)
                TextNode(.retrying, title: "Retry").nodeStyle(.state)
            }
        }
    }

    var lines: [Line] {
        Line(from: .begin, to: .ready)
        Line(from: .ready, to: .aside)
        Line(from: .ready, to: .check, label: "submit")
        Line(from: .ready.leading, to: .saving.top, label: "autosave")
        Line(from: .saving, to: .check)
        Line(from: .check, to: .ok, .retrying)
        Line(from: .retrying.top, to: .check.trailing)
        Line(looping: .retrying.trailing, label: "wait")
    }
}
