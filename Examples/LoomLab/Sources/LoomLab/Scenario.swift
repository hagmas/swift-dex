import Loom
import SwiftUI

/// A figure and the steps it is played through.
///
/// A figure is a plain value, so a scenario is nothing but a way to make the
/// figure for each step. The lab changes the step inside an animation, the
/// way a slide would, and watches what happens.
struct Scenario: Identifiable, Sendable {
    let name: String

    /// How many steps there are after the first.
    let steps: Int

    /// The figure at a step, from `0` to `steps`.
    let figure: @MainActor @Sendable (Int) -> AnyView

    var id: String {
        name
    }
}

extension Scenario {
    /// Every scenario the lab knows.
    static let all: [Scenario] = [.growingFlow]

    /// Nodes added two steps running, one of them with a loop, then the one at
    /// the top taken away — the figure on the example deck's Figures slide.
    static let growingFlow = Scenario(name: "Growing flow", steps: 3) { step in
        AnyView(FigureView(GrowingFlow(step: step), routing: .orthogonal))
    }
}

private extension NodeID {
    static let view = NodeID("view")
    static let model = NodeID("model")
    static let store = NodeID("store")
    static let remote = NodeID("remote")
}

private struct GrowingFlow: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 48) {
            if step < 3 {
                Row { Box(.view, title: "View") }
            }
            Row { Box(.model, title: "ViewModel") }
            if step >= 1 {
                Row { Box(.store, title: "Store") }
            }
            if step >= 2 {
                Row { Box(.remote, title: "Remote") }
            }
        }
    }

    var lines: [Line] {
        Line(from: .view, to: .model, label: "observes")
        Line(from: .model, to: .store, label: "reads")
        Line(from: .store, to: .remote, label: "fetches")
        Line(looping: .remote.trailing, label: "retries")
    }
}
