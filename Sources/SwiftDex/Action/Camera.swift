import Foundation

/// An `Action` for moving the camera over a slide.
///
/// The camera is the rectangle of the slide the viewport shows. Every operation
/// is a change to that rectangle: `zoom` resizes it around an element, `pan`
/// moves it without changing its size, and `reset` returns it to the slide's
/// home rectangle.
///
/// Because the operations share one rectangle, they compose: a `pan` after a
/// `zoom` travels at the zoom level the `zoom` established, rather than pulling
/// back out.
///
/// ```swift
/// @ActionContainerBuilder
/// var actionContainer: ActionContainer {
///     Camera(.zoom(to: .diagram, ratio: 0.5))
///     Camera(.pan(to: .detail))   // stays at 0.5, travels
///     Camera(.reset)
/// }
/// ```
public struct Camera: Action {

    /// Types of operations that can be specified for `Camera`.
    public enum Operation {
        /// Move the camera onto an element, keeping the current zoom level.
        ///
        /// - Parameter elementID: The `ElementID` of the target to centre on.
        case pan(to: ElementID)

        /// Fit an element into the viewport.
        ///
        /// - Parameters:
        ///     - elementID: The `ElementID` of the target.
        ///     - ratio: The proportion of the target’s width or height to the screen.
        ///       For example, if the ratio is 1.0, the target is zoomed to fit the screen.
        case zoom(to: ElementID, ratio: CGFloat)

        /// Return the camera to the slide's home rectangle.
        case reset
    }

    /// The specified operation.
    public let operation: Operation

    /// Create a new instance.
    public init(_ operation: Operation) {
        self.operation = operation
    }
}
