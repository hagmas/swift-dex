import Loom
import SwiftUI

extension Scenario {
    /// A state machine: transitions both ways between two states, loops on
    /// two states, and a transition that goes round the outside.
    static let stateMachine = Scenario(name: "State machine", steps: 0) { _ in
        AnyView(FigureView(StateMachine(), routing: .orthogonal))
    }
}

private extension NodeID {
    static let idle = NodeID("idle")
    static let loading = NodeID("loading")
    static let loaded = NodeID("loaded")
    static let failed = NodeID("failed")
}

private struct StateMachine: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 56) {
            Row(spacing: 48) {
                TextNode(.idle, title: "Idle")
                TextNode(.loading, title: "Loading")
            }
            Row(spacing: 48) {
                TextNode(.loaded, title: "Loaded")
                TextNode(.failed, title: "Failed")
            }
        }
    }

    var lines: [Line] {
        Line(from: .idle, to: .loading, label: "load")
        Line(from: .loading, to: .idle, label: "cancel")
        Line(from: .loading, to: .loaded, label: "success")
        Line(from: .loading, to: .failed, label: "error")
        Line(from: .failed.trailing, to: .loading.trailing, label: "retry")
        Line(looping: .loading.top, label: "progress")
        Line(looping: .loaded.bottom, label: "refresh")
    }
}
