import Foundation

/// An `Action` for applying `ElementTransition` to an Element.
public struct Apply: Action {
    /// The `ElementTransition` that will be applied to the target.
    public let elementTransition: ElementTransition

    /// The `ElementID` of the target.
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
