import Foundation

/// A protocol for each element of an `ActionTuple`.
///
/// The `visit` function recursively visits each element, storing Actions to be executed simultaneously in the `TempActionContainer`.
public protocol ActionTupleElement {
    func visit(with container: inout TempActionContainer)
}

/// Multiple `Action`s that you want to execute simultaneously can be specified using an `ActionTuple`.
///
/// Actions to be executed simultaneously should be chained together using the `&` operator.
public struct ActionTuple<A: ActionTupleElement, B: ActionTupleElement>: ActionTupleElement {
    let a: A
    let b: B
}

public extension ActionTuple {
    /// Visits each action in the tuple, storing them in the provided container.
    func visit(with container: inout TempActionContainer) {
        a.visit(with: &container)
        b.visit(with: &container)
    }
}

/// Combines two actions into an `ActionTuple`.
///
/// - Parameters:
///   - lhs: The left-hand side action, conforming to `ActionTupleElement`.
///   - rhs: The right-hand side action, also conforming to `ActionTupleElement`.
/// - Returns: An `ActionTuple` containing both the left-hand and right-hand actions.
public func & <A: ActionTupleElement, B: ActionTupleElement>(lhs: A, rhs: B) -> ActionTuple<A, B> {
    ActionTuple(a: lhs, b: rhs)
}
