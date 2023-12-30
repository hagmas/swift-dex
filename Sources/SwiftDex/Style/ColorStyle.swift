import SwiftUI

/// `ColorStyle` is a protocol for defining a Color Style that is shared across the entire Deck.
public protocol ColorStyle {
    /// The color set as the background for each Slide.
    ///
    /// It is set behind the `background` of `Slide`. By default, `.white` is set.
    static var backgroundColor: Color { get }

    /// A function for setting the text color for each `TextStyle`.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the text color is to be overridden.
    /// - Returns: A `Color` for the text style. Returns `nil` if the default color, which is `.black`, should be used.
    static func overrideTextColor(textStyle: TextStyle) -> Color?
}

public extension ColorStyle {
    /// Default background color for the deck.
    static var backgroundColor: Color {
        .white
    }

    /// Default implementation for `overrideTextColor`.
    static func overrideTextColor(textStyle: TextStyle) -> Color? {
        nil
    }

    /// Provides the text color for a given text style.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the text color is to be overridden.
    /// - Returns: A `Color` for the text style. Uses the overridden color if available, otherwise defaults to `.black`.
    static func textColor(textStyle: TextStyle) -> Color {
        overrideTextColor(textStyle: textStyle) ?? .black
    }
}

/// A default implementation of the `ColorStyle` protocol.
public struct DefaultColorStyle: ColorStyle {}

struct ColorStyleKey: EnvironmentKey {
    static let defaultValue: ColorStyle.Type = DefaultColorStyle.self
}

extension EnvironmentValues {
    var colorStyle: ColorStyle.Type {
        get { self[ColorStyleKey.self] }
        set { self[ColorStyleKey.self] = newValue }
    }
}
