import Foundation

/// An `Action` for applying `ElementTransition` to each item in the `Bullets`.
public struct ApplyByItem: Action {
    /// The `ElementTransition` that will be applied to each items in the `Bullets`.
    public let elementTransition: ElementTransition

    /// The `ElementID` of the `Bullets`.
    public let elementID: ElementID

    /// Create a new instance.
    public init(
        _ elementTransition: ElementTransition,
        to elementID: ElementID
    ) {
        self.elementTransition = elementTransition
        self.elementID = elementID
    }
}
