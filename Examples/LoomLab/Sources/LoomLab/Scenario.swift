import Loom
import SwiftUI

/// A figure and the steps it is played through.
///
/// A figure is a plain value, so a scenario is nothing but the figure at a
/// step, drawn with the lines the lab asks for. The lab changes the step
/// inside an animation, the way a slide would, and watches what happens.
protocol Scenario: View {
    /// What the lab lists it as.
    static var name: String { get }

    /// How many steps there are after the first: the clicks it takes to play
    /// it through, not the states it passes through.
    static var steps: Int { get }

    /// How its lines are drawn until the lab is asked for another way.
    static var routing: Line.Routing { get }

    /// The figure at `step`, from `0` to ``steps``, its lines drawn as
    /// `routing` says.
    init(step: Int, routing: Line.Routing)
}

extension Scenario {
    static var steps: Int {
        0
    }

    static var routing: Line.Routing {
        .orthogonal
    }
}

/// Every scenario the lab knows, in the order the lab lists them.
///
/// Each is defined in a file of its own under `Gallery/`: figures of the kinds
/// a talk tends to draw, each written the way an author would write it, to
/// look through for whatever reads oddly.
@MainActor let scenarios: [any Scenario.Type] = [
    GrowingFlowScenario.self,
    GrowingFanScenario.self,
    ClassDiagramScenario.self,
    StateMachineScenario.self,
    LayersScenario.self,
    FlowchartScenario.self,
    AlignedFlowchartScenario.self,
    ShapesScenario.self,
    NestedScenario.self,
    PicturesScenario.self,
    ClustersScenario.self,
    StatechartScenario.self,
    HubScenario.self,
    RaggedScenario.self,
]

/// The scenario called `name`, if there is one.
@MainActor func scenario(named name: String?) -> (any Scenario.Type)? {
    scenarios.first { $0.name == name }
}

/// The figure of `scenario` at `step`, its lines drawn as `routing` says.
@MainActor
func figure(of scenario: any Scenario.Type, step: Int, routing: Line.Routing) -> AnyView {
    AnyView(scenario.init(step: step, routing: routing))
}
