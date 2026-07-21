import SwiftUI

public extension ActionState {
    /// The action to be executed at the current step, or `nil` if the state is `.static`.
    var current: A? {
        switch self {
        case .static:
            nil

        case .activated(let value):
            value.current

        case .deactivated(let value):
            value.current
        }
    }

    /// The action executed at a previous step, if any.
    var previous: A? {
        switch self {
        case .static(let value):
            value.previous

        case .activated(let value):
            value.previous

        case .deactivated(let value):
            value.previous
        }
    }

    /// The action to be executed at a later step, if any.
    var next: A? {
        switch self {
        case .static(let value):
            value.next

        case .activated(let value):
            value.next

        case .deactivated(let value):
            value.next
        }
    }
}

public extension ActionState where A: TransitionAction {
    /// The animation for the current state.
    ///
    /// Returns the current action's animation, falling back to the previous action's
    /// animation when no action exists at this step.
    var transitionAnimation: Animation? {
        (current ?? previous)?.elementTransition.animation
    }

    /// The `ElementModifier` resolved from neighboring actions when no action exists at this step.
    ///
    /// Resolution order: the next action's `previous` state, the previous action's `next` state,
    /// then the previous action's `current` state.
    var nearestElementModifier: ElementModifier? {
        next?.elementTransition.previous
            ?? previous?.elementTransition.next
            ?? previous?.elementTransition.current
    }
}
