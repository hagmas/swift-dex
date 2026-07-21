import Foundation

/// An `Action` that applies an `ElementTransition` to its target.
///
/// Conforming to this protocol allows a custom `View` to resolve `ElementModifier`
/// and `Animation` values from an `ActionState` using the shared helpers
/// defined on `ActionState where A: TransitionAction`.
public protocol TransitionAction: Action {
    /// The `ElementTransition` that will be applied to the target.
    var elementTransition: ElementTransition { get }
}
