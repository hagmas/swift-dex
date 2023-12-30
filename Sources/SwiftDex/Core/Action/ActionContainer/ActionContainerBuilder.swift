import Foundation

/// A ResultBuilder for creating `ActionContainer`.
@resultBuilder
public struct ActionContainerBuilder {
    /// Builds an initial `TempActionContainer` from a single action.
    public static func buildPartialBlock<A: Action>(first: A) -> TempActionContainer {
        var container = TempActionContainer()
        container.add(action: first)
        return container
    }

    /// Builds an initial `TempActionContainer` from an action tuple.
    public static func buildPartialBlock<A: ActionTupleElement, B: ActionTupleElement>(
        first: ActionTuple<A, B>
    ) -> TempActionContainer {
        var container = TempActionContainer()
        first.visit(with: &container)
        return container
    }

    /// Adds a new action to an existing `TempActionContainer`.
    public static func buildPartialBlock<A: Action>(accumulated: TempActionContainer, next: A) -> TempActionContainer {
        var accumulated = accumulated
        accumulated.increaseCapacity()
        accumulated.add(action: next)
        return accumulated
    }

    /// Adds a new action tuple to an existing `TempActionContainer`.
    public static func buildPartialBlock<A: ActionTupleElement, B: ActionTupleElement>(
        accumulated: TempActionContainer,
        next: ActionTuple<A, B>
    ) -> TempActionContainer {
        var accumulated = accumulated
        accumulated.increaseCapacity()
        next.visit(with: &accumulated)
        return accumulated
    }

    /// Finalizes the construction of an `ActionContainer` from a `TempActionContainer`.
    public static func buildFinalResult(_ component: TempActionContainer) -> ActionContainer {
        var component = component
        return component.finalize()
    }
}
