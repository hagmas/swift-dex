import Foundation
import SwiftUI

/// A value used in conjunction with `Apply` or `ApplyByItem`.
///
/// These `Actions` allow the application of values defined in `ElementTransition` to elements of a Slide.
public struct ElementTransition {
    /// The `Animation` value used when applying the specified `ElementModifier` to an Element.
    public let animation: Animation?

    /// Optional, defines the state of an element before this value is applied.
    ///
    /// If not specified, a default value is applied.
    public let previous: ElementModifier?

    /// The value that defines the state of an element after this value is applied.
    public let current: ElementModifier

    /// Optional, defines the state of an element after this value is applied.
    ///
    /// If not specified, the value of `current` is applied.
    public let next: ElementModifier?

    /// Initializes a new `ElementTransition`.
    ///
    /// - Parameters:
    ///   - animation: The animation to be used during the transition.
    ///   - previous: The state of the element before the transition.
    ///   - current: The main state of the element during the transition.
    ///   - next: The state of the element after the transition.
    public init(
        animation: Animation? = nil,
        previous: ElementModifier? = nil,
        current: ElementModifier = .identity,
        next: ElementModifier? = nil
    ) {
        self.animation = animation
        self.previous = previous
        self.current = current
        self.next = next
    }
}

public extension ElementTransition {
    /// A predefined `ElementTransition` for an appearing effect.
    ///
    /// This transition starts with the element fully transparent and transitions to its defined state.
    static var appear: ElementTransition {
        .init(previous: .opacity(0))
    }

    /// A predefined `ElementTransition` with a fade-in effect.
    ///
    /// The element starts fully transparent and fades in with an ease-in animation over 0.3 seconds.
    static var fade: ElementTransition {
        .init(
            animation: .easeIn(duration: 0.3),
            previous: .opacity(0)
        )
    }
}
