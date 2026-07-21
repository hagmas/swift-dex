import SwiftUI

/// The progress of an `Action` as seen by the `View` that renders it.
///
/// Unlike `ActionState`, which describes the raw state of the action timeline,
/// `ActionProgress` is the value handed to an `ActionStepper` content closure.
/// A sub-step counter only exists in the `active` case, making it impossible to
/// read a step value that has no meaning.
public enum ActionProgress<A: Action> {
    /// No action of this type is running at the current step.
    ///
    /// `previous` and `next` are the neighboring actions on the step timeline, if any.
    /// Their presence tells the view whether it sits before, between, or after actions.
    case idle(previous: A?, next: A?)

    /// The action is running. `step` is the current sub-step, starting at `1`.
    case active(current: A, step: Int)

    /// The action has completed, but the slide is still on its step.
    case completed(current: A)
}

public extension ActionProgress {
    /// The running or completed action, or `nil` when idle.
    var current: A? {
        switch self {
        case .idle:
            nil

        case .active(let current, _):
            current

        case .completed(let current):
            current
        }
    }
}

public extension ActionProgress where A: TransitionAction {
    /// The animation for the current progress.
    ///
    /// Returns the running or completed action's animation, falling back to the
    /// previous action's animation when idle.
    var transitionAnimation: Animation? {
        switch self {
        case .idle(let previous, _):
            previous?.elementTransition.animation

        case .active(let current, _):
            current.elementTransition.animation

        case .completed(let current):
            current.elementTransition.animation
        }
    }

    /// The `ElementModifier` for an element treated as a single unit.
    ///
    /// While the action is running or completed, this is the action's `current` phase.
    /// When idle, it is resolved from the neighboring actions: the next action's `before`
    /// phase, the previous action's `after` phase, then the previous action's `current` phase.
    var elementModifier: ElementModifier? {
        switch self {
        case .idle(let previous, let next):
            next?.elementTransition.before
                ?? previous?.elementTransition.after
                ?? previous?.elementTransition.current

        case .active(let current, _):
            current.elementTransition.current

        case .completed(let current):
            current.elementTransition.current
        }
    }
}
