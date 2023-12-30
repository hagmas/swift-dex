import SwiftUI

/// The `FontStyle` protocol allows you to define a Font Style that is shared across the entire Deck.
public protocol FontStyle {
    /// If using a custom font, specify it from this field.
    ///
    /// By default, the System Font is used.
    static var customName: String? { get }

    /// Specifies the font size for each text style.
    ///
    /// - Parameter textStyle: The `TextStyle` for which the font size is to be overridden.
    /// - Returns: An optional `CGFloat` representing the overridden font size. Returns `nil` if the default size is used.
    static func overrideSize(textStyle: TextStyle) -> CGFloat?

    /// Specifies the font weight for each text style.
    ///
    /// - Parameter textStyle: The `TextStyle` for which the font weight is to be overridden.
    /// - Returns: An optional `Font.Weight` representing the overridden weight. Returns `nil` if the default weight is used. If `customName` is used, this value is ignored.
    static func overrideWeight(textStyle: TextStyle) -> Font.Weight?

    /// Specifies the font design for each text style.
    ///
    /// - Parameter textStyle: The `TextStyle` for which the font design is to be overridden.
    /// - Returns: An optional `Font.Design` representing the overridden design. Returns `nil` if the default design is used. If `customName` is used, this value is ignored.
    static func overrideDesign(textStyle: TextStyle) -> Font.Design?

    /// Specifies font modifiers for each text style, like `.italic()` or `.monospaced()`.
    ///
    /// - Parameters:
    ///   - font: The `Font` to be modified.
    ///   - textStyle: The `TextStyle` for which the font modifier is to be applied.
    /// - Returns: A `Font` with the applied modifiers.
    static func modifier(font: Font, textStyle: TextStyle) -> Font
}
public extension FontStyle {
    /// A default value for the custom font name.
    static var customName: String? {
        nil
    }

    /// A default implementation for overriding the font name.
    static func overrideName() -> String? {
        nil
    }

    /// A default implementation for overriding the size of a text style.
    static func overrideSize(textStyle: TextStyle) -> CGFloat? {
        nil
    }

    /// A default implementation for overriding the weight of a text style.
    static func overrideWeight(textStyle: TextStyle) -> Font.Weight? {
        nil
    }

    /// A default implementation for overriding the design of a text style.
    static func overrideDesign(textStyle: TextStyle) -> Font.Design? {
        nil
    }

    /// A default implementation for applying a modifier to a font.
    static func modifier(font: Font, textStyle: TextStyle) -> Font {
        font
    }

    /// Calculates the size of the font for the given text style.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the font size is to be overridden.
    /// - Returns: A `CGFloat` value for the text style. Uses the overridden size if available, otherwise defaults to the value defined in the text style.
    static func size(textStyle: TextStyle) -> CGFloat {
        overrideSize(textStyle: textStyle) ?? textStyle.size
    }

    /// Determines the weight of the font for the given text style.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the font weight is to be overridden.
    /// - Returns: A `Font.Weight` value for the text style. Uses the overridden weight if available, otherwise defaults to the value defined in the text style.
    static func weight(textStyle: TextStyle) -> Font.Weight {
        overrideWeight(textStyle: textStyle) ?? textStyle.weight
    }

    /// Determines the design of the font for the given text style.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the font design is to be overridden.
    /// - Returns: A `Font.Design` value for the text style. Uses the overridden design if available, otherwise defaults to the value defined in the text style.
    static func design(textStyle: TextStyle) -> Font.Design {
        overrideDesign(textStyle: textStyle) ?? textStyle.design
    }
    /// Constructs a font for the given text style.
    ///
    /// - Parameter textStyle: A `TextStyle` for which the font to be constructed.
    /// - Returns: A font constructed from the given text style.
    static func font(textStyle: TextStyle) -> Font {
        if let customName = Self.customName {
            modifier(
                font: .custom(
                    customName,
                    size: size(textStyle: textStyle)
                ),
                textStyle: textStyle
            )
        }
        else {
            modifier(
                font: .system(
                    size: size(textStyle: textStyle),
                    weight: weight(textStyle: textStyle),
                    design: design(textStyle: textStyle)
                ),
                textStyle: textStyle
            )
        }
    }
}

/// A default implementation of the `FontStyle` protocol.
///
/// This uses system defaults for font properties and does not override any styles.
public struct DefaultFontStyle: FontStyle {}

struct FontStyleKey: EnvironmentKey {
    static let defaultValue: FontStyle.Type = DefaultFontStyle.self
}

extension EnvironmentValues {
    var fontStyle: FontStyle.Type {
        get { self[FontStyleKey.self] }
        set { self[FontStyleKey.self] = newValue }
    }
}
