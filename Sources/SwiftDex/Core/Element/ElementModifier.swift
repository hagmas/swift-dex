import CoreGraphics
import SwiftUI

/// `ElementModifier` is a struct that consolidates various arguments applicable to `ViewModifier`s defined on a `View`, treating them as a single type.
///
/// It can be applied to a View using `ElementViewModifier`.
/// - Important: Due to the limitation of SwiftUI, the order in these view modifiers applied to a `View` is statically defined (Refer to `ElementViewModifier`).
/// This might cause an unexpected effect when two or more modifiers are combined (e.g., `RotationEffect` + `Offset` or `ScaleEffect` + `Offset`).
/// For precise control over effects, please consider defining a custom view and action.
public struct ElementModifier {
    struct RotationEffect: Equatable {
        let angle: Angle
        let anchor: UnitPoint
        static let identity = RotationEffect(
            angle: .zero,
            anchor: .center
        )
    }

    struct ScaleEffect: Equatable {
        let scale: CGSize
        let anchor: UnitPoint
        static let identity = ScaleEffect(
            scale: CGSize(width: 1.0, height: 1.0),
            anchor: .center
        )
    }

    struct Offset: Equatable {
        let x: CGFloat
        let y: CGFloat
        static let identity = Offset(x: 0, y: 0)
    }

    struct Blur: Equatable {
        let radius: CGFloat
        let opaque: Bool
        static let identity = Blur(radius: 0, opaque: false)
    }

    struct Shadow: Equatable {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        static let identity = Shadow(color: .clear, radius: 0, x: 0, y: 0)
    }

    var isHidden: Bool = false
    var scaleEffect: ScaleEffect = .identity
    var rotationEffect: RotationEffect = .identity
    var offset: Offset = .identity
    var opacity: Double = 1
    var blur: Blur = .identity
    var shadow: Shadow = .identity
}

public extension ElementModifier {
    static let identity = ElementModifier()

    /// Returns an `ElementModifier` that is hidden.
    ///
    /// - Returns: An `ElementModifier` with the updated visibility.
    static func hidden() -> ElementModifier {
        .identity.hidden()
    }

    /// Sets hidden to the `ElementModifier`.
    ///
    /// - Returns: An `ElementModifier` with the updated visibility.
    func hidden() -> ElementModifier {
        var `self` = self
        self.isHidden = true
        return self
    }

    /// Returns an `ElementModifier` that applies a rotation effect.
    ///
    /// - Parameters:
    ///   - angle: The angle of rotation.
    ///   - anchor: The anchor point for the rotation. Defaults to `.center`.
    /// - Returns: An `ElementModifier` with the rotation effect applied.
    static func rotationEffect(
        _ angle: Angle,
        anchor: UnitPoint = .center
    ) -> ElementModifier {
        .identity.rotationEffect(angle, anchor: anchor)
    }

    /// Add a rotation effect to the `ElementModifier`.
    ///
    /// - Parameters:
    ///   - angle: The angle of rotation.
    ///   - anchor: The anchor point for the rotation. Defaults to `.center`.
    /// - Returns: An `ElementModifier` with the rotation effect applied.
    func rotationEffect(
        _ angle: Angle,
        anchor: UnitPoint = .center
    ) -> ElementModifier {
        var `self` = self
        self.rotationEffect = RotationEffect(angle: angle, anchor: anchor)
        return self
    }

    /// Returns an `ElementModifier` that applies a scaling effect.
    ///
    /// - Parameters:
    ///   - scale: A `CGSize` to scale the view.
    ///   - anchor: The point from which the scaling should be applied. Defaults to `.center`.
    /// - Returns: An `ElementModifier` with the scale effect applied.
    static func scaleEffect(
        _ scale: CGSize,
        anchor: UnitPoint = .center
    ) -> ElementModifier {
        .identity.scaleEffect(scale, anchor: anchor)
    }

    /// Add a scale effect to the `ElementModifier`.
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

    /// Returns an `ElementModifier` that applies an offset.
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset the view.
    ///   - y: The vertical distance to offset the view.
    /// - Returns: An `ElementModifier` with the offset applied.
    static func offset(
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ElementModifier {
        .identity.offset(x: x, y: y)
    }

    /// Add an offset to the `ElementModifier`.
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

    /// Returns an `ElementModifier` that sets the opacity.
    ///
    /// - Parameter opacity: A Double value that determines the opacity of the view.
    /// - Returns: An `ElementModifier` with the updated opacity.
    static func opacity(_ opacity: Double) -> ElementModifier {
        .identity.opacity(opacity)
    }

    /// Add the opacity of the `ElementModifier`.
    ///
    /// - Parameter opacity: A Double value that determines the opacity of the view.
    /// - Returns: An `ElementModifier` with the updated opacity.
    func opacity(_ opacity: Double) -> ElementModifier {
        var `self` = self
        self.opacity = opacity
        return self
    }

    /// Returns an `ElementModifier` that applies a blur effect.
    ///
    /// - Parameters:
    ///   - radius: The radial size of the blur.
    ///   - opaque: A Boolean value that indicates whether the blur renderer permits transparency.
    /// - Returns: An `ElementModifier` with the blur effect applied.
    static func blur(
        radius: CGFloat,
        opaque: Bool = false
    ) -> ElementModifier {
        .identity.blur(radius: radius, opaque: opaque)
    }

    /// Add a blur effect to the `ElementModifier`.
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

    /// Returns an `ElementModifier` that applies a shadow.
    ///
    /// - Parameters:
    ///   - color: The shadow color. Defaults to a semi-transparent black.
    ///   - radius: The shadow blur radius.
    ///   - x: The horizontal offset of the shadow.
    ///   - y: The vertical offset of the shadow.
    /// - Returns: An `ElementModifier` with the shadow applied.
    static func shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ElementModifier {
        .identity.shadow(color: color, radius: radius, x: x, y: y)
    }

    /// Add a shdow to the `ElementModifier`.
    ///
    /// - Parameters:
    ///   - color: The shadow color. Defaults to a semi-transparent black.
    ///   - radius: The shadow blur radius.
    ///   - x: The horizontal offset of the shadow.
    ///   - y: The vertical offset of the shadow.
    /// - Returns: An `ElementModifier` with the shadow applied.
    func shadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ElementModifier {
        var `self` = self
        self.shadow = Shadow(color: color, radius: radius, x: x, y: y)
        return self
    }
}
