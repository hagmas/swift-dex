import Loom
import SwiftUI

extension Scenario {
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
                Row { TextNode(.view, title: "View") }
            }
            Row { TextNode(.model, title: "ViewModel") }
            if step >= 1 {
                Row { TextNode(.store, title: "Store") }
            }
            if step >= 2 {
                Row { TextNode(.remote, title: "Remote") }
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
