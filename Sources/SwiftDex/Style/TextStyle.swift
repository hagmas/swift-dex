import SwiftUI

/// `TextStyle` defines the style categories for text elements within a Deck.
///
/// It is used to apply consistent font styles across different types of text content.
public enum TextStyle {
    /// Used for main titles, typically the largest and most prominent text.
    case title

    /// A smaller variant of the title, for less dominant headings.
    case titleSmall

    /// Used for subtitles, providing additional context or information.
    case subtitle

    /// A smaller variant of the subtitle, for less emphasis.
    case subtitleSmall

    /// The primary style for body text, used for the main content.
    case body

    /// Used for captions, smaller descriptive text often used beneath images or as annotations.
    case caption

    /// Intended for quotations, highlighting excerpts or special remarks.
    case quate
}

public extension TextStyle {
    var size: CGFloat {
        switch self {
        case .title:
            128

        case .titleSmall:
            84

        case .subtitle:
            60

        case .subtitleSmall:
            44

        case .body:
            44

        case .caption:
            24

        case .quate:
            84
        }
    }

    var weight: Font.Weight {
        switch self {
        case .title, .titleSmall:
            .bold

        case .subtitle, .subtitleSmall:
            .semibold

        case .body:
            .regular

        case .caption:
            .regular

        case .quate:
            .bold
        }
    }

    var design: Font.Design {
        .default
    }
}

public extension View {
    func textStyle(_ textStyle: TextStyle) -> some View {
        self
            .modifier(TextStyleModifier(textStyle: textStyle))
    }
}

private struct TextStyleModifier: ViewModifier {
    @Environment(\.fontStyle) var fontStyle
    @Environment(\.colorStyle) var colorStyle
    var textStyle: TextStyle

    init(textStyle: TextStyle) {
        self.textStyle = textStyle
    }

    func body(content: Content) -> some View {
        content
            .font(fontStyle.font(textStyle: textStyle))
            .foregroundColor(colorStyle.textColor(textStyle: textStyle))
    }
}
