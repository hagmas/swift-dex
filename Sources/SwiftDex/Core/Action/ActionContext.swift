import SwiftUI

/// `ActionContext` is a Property Wrapper that allows a `View` to obtain its current `ActionState` from its `ElementID` and any `Action` type.
///
/// As the state of the slide changes, new `ActionState` values are notified to each View.
/// To define a custom Action, create a custom View with this Property Wrapper and apply the action to the View according to the obtained `ActionState`.
/// Additionally, after an action has been executed, call `deactivate(actionID: ActionID)` with the assigned `ActionID` to notify the `slideViewModel` that the action is complete.
///
@propertyWrapper
public struct ActionContext<A: Action>: DynamicProperty {
    @Environment(\.elementID) private var elementID: ElementID
    @Environment(AnySlideViewModel.self) private var slideViewModel

    /// Initializes the `ActionContext` for a specific `Action` type.
    public init(_: A.Type) {}

    /// Direct access to the ActionContext itself, eliminating the intermediate ActionContextValue layer.
    public var wrappedValue: ActionContext<A> { self }
    
    /// The current state of the action for the given element ID and action type.
    public var state: ActionState<A>? {
        slideViewModel.actionState(for: elementID, type: A.self)
    }

    /// Deactivates the action with the given action ID, notifying the `slideViewModel` that the action is complete.
    public func deactivate(actionID: ActionID) {
        slideViewModel.deactivate(actionID: actionID)
    }

    /// Indicates whether the action can be animated based on the current slide's state.
    public var canBeAnimated: Bool {
        slideViewModel.canBeAnimated
    }
}

/// `ActionState` is a type that defines the state of an `Action` for a View at the current step.
///
/// `ActionState` can be divided into Dynamic and Static states, where Dynamic states are further
/// divided into `Activated` and `Deactivated`.
/// The `Static` state indicates that there are no actions to be executed at that step.
/// `Activated` indicates that there are actions to be executed at that step, and the action is either
/// about to be applied or is currently being applied.
/// `Deactivated` indicates that the action has been fully applied.
///
public enum ActionState<A: Action>: Equatable {
    /// Equality check for `ActionState`.
    public static func == (lhs: ActionState<A>, rhs: ActionState<A>) -> Bool {
        switch (lhs, rhs) {
        case (.activated(let lhs), .activated(let rhs)):
            lhs.step == rhs.step

        case (.deactivated(let lhs), .deactivated(let rhs)):
            lhs.step == rhs.step

        case (.static(let lhs), .static(let rhs)):
            lhs.step == rhs.step

        default:
            false
        }
    }

    /// Represents a static state where no action is to be executed.
    public struct Static {
        let step: Int
        let previous: A?
        let next: A?
    }

    /// Represents an activated state where the action is about to be applied or is currently being applied.
    public struct Activated {
        let step: Int
        let actionID: ActionID
        let current: A
        let previous: A?
        let next: A?
    }

    /// Represents a deactivated state where the action has been fully applied.
    public struct Deactivated {
        let step: Int
        let actionID: ActionID
        let current: A
        let previous: A?
        let next: A?
    }

    case `static`(Static)
    case activated(Activated)
    case deactivated(Deactivated)
}

public extension ActionState {
    /// Retrieves the `ActionID` associated with the current action, if it exists.
    var actionID: ActionID? {
        switch self {
        case .activated(let value):
            return value.actionID

        default:
            return nil
        }
    }

    /// Indicates whether the action state is activated (i.e., whether it is in the activated state).
    var isActivated: Bool {
        if case .activated(_) = self {
            return true
        }
        else {
            return false
        }
    }
}
