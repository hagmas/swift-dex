import Foundation

/// A ResultBuilder for creating `ActionContainer`.
///
/// Each line of the builder is a beat on the slide timeline, executed in order.
/// Within a line, compose actions with `&` (parallel) and `then(_:)` (serial).
@resultBuilder
public struct ActionContainerBuilder {
    /// Builds an initial `TempActionContainer` from the first line.
    public static func buildPartialBlock(first: some ActionComposable) -> TempActionContainer {
        var container = TempActionContainer()
        container.addLine(first)
        return container
    }

    /// Adds a new line to an existing `TempActionContainer`.
    public static func buildPartialBlock(
        accumulated: TempActionContainer,
        next: some ActionComposable
    ) -> TempActionContainer {
        var accumulated = accumulated
        accumulated.addLine(next)
        return accumulated
    }

    /// Finalizes the construction of an `ActionContainer` from a `TempActionContainer`.
    public static func buildFinalResult(_ component: TempActionContainer) -> ActionContainer {
        var component = component
        return component.finalize()
    }
}
