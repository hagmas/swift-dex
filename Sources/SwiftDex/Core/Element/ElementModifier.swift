import SwiftUI

/// `ElementModifier` is a struct that consolidates various arguments applicable to `ViewModifier`s defined on a `View`, treating them as a single type.
///
/// It can be applied to a View using `ElementViewModifier`.
public struct ElementModifier {

    /// A struct representing the parameters for the `scaleEffect(_:anchor:)` view modifier.
    public struct ScaleEffect: Equatable {
        /// A `CGSize` that represents the horizontal and vertical amount to scale the view.
        public let scale: CGSize

        /// The point with a default of center that defines the location within the view from which to apply the transformation.
        public let anchor: UnitPoint

        /// The default `ScaleEffect` value, which maintains the original size of the view.
        public static let identity = ScaleEffect(
            scale: CGSize(width: 1.0, height: 1.0),
            anchor: .center
        )
    }

    /// A struct representing the parameters for the `offset(_:)` view modifier.
    public struct Offset: Equatable {
        /// The horizontal distance to offset the view.
        public let x: CGFloat

        /// The vertical distance to offset the view.
        public let y: CGFloat

        /// The default `Offset` value.
        public static let identity = Offset(x: 0, y: 0)
    }

    /// A struct representing the parameters for the `blur(radius:opaque:)` view modifier.
    public struct Blur: Equatable {
        /// The radial size of the blur.
        public let radius: CGFloat

        /// A Boolean value that indicates whether the blur renderer permits transparency in the blur output.
        public let opaque: Bool

        /// The default `Blur` value.
        public static let identity = Blur(radius: 0, opaque: false)
    }

    /// Boolean indicating if the view is hidden or visible.
    public var isHidden: Bool = false

    /// The scale effect to be applied to the view.
    public var scaleEffect: ScaleEffect = .identity

    /// The offset effect to be applied to the view.
    public var offset: Offset = .identity

    /// The opacity of the view.
    public var opacity: Double = 1

    /// The blur effect to be applied to the view.
    public var blur: Blur = .identity
}

public extension ElementModifier {
    /// The default `ElementModifier` with no modifications applied.
    static let identity = ElementModifier()

    /// Sets the visibility of the view.
    ///
    /// - Parameter isHidden: A Boolean value that determines whether the view is hidden.
    /// - Returns: An `ElementModifier` with the updated visibility.
    func set(isHidden: Bool) -> ElementModifier {
        var `self` = self
        self.isHidden = isHidden
        return self
    }

    /// Applies a scale effect to the view.
    ///
    /// - Parameters:
    ///   - scale: A `CGSize` to scale the view.
    ///   - anchor: The point from which the scaling should be applied. Defaults to `.center`.
    /// - Returns: An `ElementModifier` with the scale effect applied.
    func scaleEffect(
        _ scale: CGSize,
        anchor: UnitPoint = .center
    ) -> ElementModifier {
        var `self` = self
        self.scaleEffect = ScaleEffect(scale: scale, anchor: anchor)
        return self
    }

    /// Applies an offset to the view.
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset the view.
    ///   - y: The vertical distance to offset the view.
    /// - Returns: An `ElementModifier` with the offset applied.
    func offset(
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ElementModifier {
        var `self` = self
        self.offset = Offset(x: x, y: y)
        return self
    }

    /// Sets the opacity of the view.
    ///
    /// - Parameter opacity: A Double value that determines the opacity of the view.
    /// - Returns: An `ElementModifier` with the updated opacity.
    func opacity(_ opacity: Double) -> ElementModifier {
        var `self` = self
        self.opacity = opacity
        return self
    }

    /// Applies a blur effect to the view.
    ///
    /// - Parameters:
    ///   - radius: The radial size of the blur.
    ///   - opaque: A Boolean value that indicates whether the blur renderer permits transparency.
    /// - Returns: An `ElementModifier` with the blur effect applied.
    func blur(
        radius: CGFloat,
        opaque: Bool = false
    ) -> ElementModifier {
        var `self` = self
        self.blur = Blur(radius: radius, opaque: opaque)
        return self
    }
}
