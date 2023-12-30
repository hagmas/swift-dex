import Foundation

/// An `Action` for zooming in or out on an Element.
public struct Zoom: Action {

    /// Types of operations that can be specified for `Zoom`.
    public enum Operation {
        /// Zoom In
        ///
        /// - Parameters:
        ///     - ElementID: The `ElementID` of the target.
        ///     - ratio: The proportion of the target’s width or height to the screen.
        ///       For example, if the ratio is 1.0, the target is zoomed to fit the screen.
        case `in`(ElementID, ratio: CGFloat)

        /// Zoom Out to return the entire screen display to default.
        case out
    }

    /// The specified operation.
    public let operation: Operation

    /// Create a new instance.
    public init(_ operation: Operation) {
        self.operation = operation
    }
}

extension Zoom {
    var ratio: CGFloat {
        switch operation {
        case .in(_, let ratio):
            return ratio

        case .out:
            return 1.0
        }
    }
}

extension Zoom.Operation {
    var elementID: ElementID {
        switch self {
        case .in(let elementID, _):
            elementID

        case .out:
            .none
        }
    }
}
