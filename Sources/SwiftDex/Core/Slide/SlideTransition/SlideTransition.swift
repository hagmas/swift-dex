import SwiftUI

/// A type for defining the transition of a `Slide`.
public struct SlideTransition {
    /// This `transition` is applied as the `removal` of the disappearing view and the `insertion` of the appearing view.
    let transition: AnyTransition

    /// The Animation that is applied to the specified `transition`.
    let animation: Animation?

    /// Setting this flag to `true` allows for transitions using `matchedGeometryEffect`.
    /// `matchedGeometryEffect` will be applied to Views with the same `MatchID`.
    let isMatched: Bool

    /// Initializes a new `SlideTransition`.
    ///
    /// - Parameters:
    ///   - transition: The type of transition (e.g., fade, slide, etc.).
    ///   - animation: The animation style to apply to the transition.
    ///   - isMatched: A Boolean value that, when true, enables matched geometry effects for the transition.
    public init(
        transition: AnyTransition,
        animation: Animation?,
        isMatched: Bool = false
    ) {
        self.transition = transition
        self.animation = animation
        self.isMatched = isMatched
    }
}

public extension SlideTransition {
    /// A `SlideTransition` that represents no transition effect.
    static let none = SlideTransition(transition: .identity, animation: nil)

    /// Creates a slide transition with a push effect.
    ///
    /// - Parameter duration: The duration of the animation, defaulting to 0.5 seconds.
    /// - Returns: A `SlideTransition` with a push effect.
    static func push(duration: TimeInterval = 0.5) -> SlideTransition {
        SlideTransition(
            transition: AnyTransition.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ),
            animation: .spring(duration: duration)
        )
    }

    /// Creates a slide transition with a dissolve effect.
    ///
    /// - Parameter duration: The duration of the animation, defaulting to 0.5 seconds.
    /// - Returns: A `SlideTransition` with a dissolve effect.
    static func dissolve(duration: TimeInterval = 0.5) -> SlideTransition {
        SlideTransition(
            transition: .opacity,
            animation: .linear(duration: duration)
        )
    }

    /// Creates a matched transition using `matchedGeometryEffect`.
    ///
    /// This is useful for a smooth transition between elements shared across slides.
    /// - Parameter duration: The duration of the animation, defaulting to 1.0 seconds.
    /// - Returns: A `SlideTransition` with a matched effect.
    static func matched(duration: TimeInterval = 1.0) -> SlideTransition {
        SlideTransition(
            transition: .opacity,
            animation: .spring(duration: duration),
            isMatched: true
        )
    }
}
