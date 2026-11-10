import Loom
import SwiftUI

/// A state machine: transitions both ways between two states, loops on
/// two states, and a transition that goes round the outside.
struct StateMachineScenario: Scenario {
    static let name = "State machine"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(StateMachine(), routing: routing)
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
        Column(spacing: 80) {
            Row(spacing: 68) {
                TextNode(.idle, title: "Idle")
                TextNode(.loading, title: "Loading")
            }
            Row(spacing: 68) {
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
