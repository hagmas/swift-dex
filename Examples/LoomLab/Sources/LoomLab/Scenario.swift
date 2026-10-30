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
    /// Every scenario the lab knows, in the order the lab lists them.
    ///
    /// Each is defined in a file of its own under `Gallery/`: figures of the
    /// kinds a talk tends to draw, each written the way an author would write
    /// it, to look through for whatever reads oddly.
    static let all: [Scenario] = [
        .growingFlow,
        .growingFan,
        .classDiagram,
        .stateMachine,
        .layers,
        .layersStraight,
        .flowchart,
        .flowchartAligned,
        .shapes,
        .nested,
        .hub,
        .ragged,
    ]
}
