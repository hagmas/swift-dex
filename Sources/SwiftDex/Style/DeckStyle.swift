import SwiftUI

/// `DeckStyle` is a protocol for setting a style that is shared across the entire Deck.
///
/// Define a custom `DeckStyle` and specify it from the `deckStyle` of the `Deck` protocol.
public protocol DeckStyle {
    static var fontStyle: FontStyle.Type { get }
    static var colorStyle: ColorStyle.Type { get }
    static var slideSize: CGSize { get }
}

public extension DeckStyle {
    /// Provides a default font style for the deck.
    ///
    /// If not overridden, `DefaultFontStyle` is used, which applies the default system font styles.
    static var fontStyle: FontStyle.Type {
        DefaultFontStyle.self
    }

    /// Provides a default color style for the deck.
    ///
    /// If not overridden, `DefaultColorStyle` is used, which applies the default color scheme.
    static var colorStyle: ColorStyle.Type {
        DefaultColorStyle.self
    }

    static var slideSize: CGSize {
        CGSize(width: 1920, height: 1080)
    }
}

/// A default implementation of the `DeckStyle` protocol.
public struct DefaultDeckStyle: DeckStyle {}

struct SlideSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = DefaultDeckStyle.slideSize
}

extension EnvironmentValues {
    var slideSize: CGSize {
        get { self[SlideSizeKey.self] }
        set { self[SlideSizeKey.self] = newValue }
    }
}
