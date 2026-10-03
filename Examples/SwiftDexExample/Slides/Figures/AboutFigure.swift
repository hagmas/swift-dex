import Loom
import SwiftDex
import SwiftUI

/// A figure that grows as the slide advances.
///
/// The figure is a plain value, so showing more of it is a matter of handing it
/// a different one. Nothing here asks for an animation: the slide moves on, the
/// value changes, and SwiftUI does the rest.
struct AboutFigure: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Figures"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            "A **`Figure`** is a value. Give it a different one and the figure grows."
            GrowingFlow(elementID: .element(0))
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Grow(.element(0))
    }
}

/// An action that does nothing but count the clicks it has been given.
private struct Grow: Action {
    let elementID: ElementID

    init(_ elementID: ElementID) {
        self.elementID = elementID
    }
}

private struct GrowingFlow: View {
    let elementID: ElementID

    var body: some View {
        ActionReader(Grow.self, elementID: elementID, clicks: 2) { progress in
            FigureView(DataFlow(reached: reached(progress)), routing: .orthogonal)
                .figureAtBodyTextSize()
        } animation: { _ in
            .bouncy(duration: 0.8)
        }
    }

    /// How far through the slide we are, as a number the figure understands.
    private func reached(_ progress: ActionProgress<Grow>) -> Int {
        switch progress {
        case .idle(let previous, _):
            previous == nil ? 0 : 2

        case .active(_, let step):
            step

        case .completed:
            2
        }
    }
}

private extension NodeID {
    static let view = NodeID("view")
    static let model = NodeID("model")
    static let store = NodeID("store")
    static let remote = NodeID("remote")
}

private struct DataFlow: Figure {
    /// How much of the flow to show.
    ///
    /// Nothing but a number. The arrangement and the lines are both written as
    /// functions of it, so the two can never disagree about what is showing.
    var reached: Int

    var arrangement: some FigureElement {
        Column(spacing: 48) {
            Row { Box(.view, title: "View") }
            Row { Box(.model, title: "ViewModel") }
            if reached >= 1 {
                Row { Box(.store, title: "Store") }
            }
            if reached >= 2 {
                Row { Box(.remote, title: "Remote") }
            }
        }
    }

    /// Written once, with no conditions of their own: a line whose nodes are
    /// not there yet is simply not drawn.
    var lines: [Line] {
        Line(from: .view, to: .model, label: "observes")
        Line(from: .model, to: .store, label: "reads")
        Line(from: .store, to: .remote, label: "fetches")
        Line(looping: .remote.trailing, label: "retries")
    }
}

#Preview {
    SlidePreview(slide: AboutFigure())
}
