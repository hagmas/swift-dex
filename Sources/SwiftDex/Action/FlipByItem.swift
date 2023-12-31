import SwiftUI

/// An `Action` for displaying each item one by one in the `Flipper`.
public struct FlipByItem: Action {
    /// The `ElementID` of the `Flipper`.
    public let elementID: ElementID

    /// Create a new instance.
    public init(_ elementID: ElementID) {
        self.elementID = elementID
    }
}
