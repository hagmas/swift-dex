import Foundation

/// An `Action` for highlighting an element by darkening or lightening the surrounding area.
public struct Highlight: Action {

    /// The color effect applied to the area surrounding the highlighted element.
    public enum Mode {
        /// The surrounding area becomes lighter.
        case light

        /// The surrounding area becomes darker.
        case dark
    }

    /// The `ElementID` of the target element to highlight.
    public let target: ElementID

    /// The specified mode.
    public let mode: Mode

    /// Create a new instance.
    public init(
        _ mode: Mode,
        to target: ElementID
    ) {
        self.mode = mode
        self.target = target
    }
}
