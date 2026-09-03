import SwiftUI

/// `ElementID` is an identifier for each element within a slide.
///
/// It is used to specify which element is the target when using `Action`.
/// Wrap an arbitrary view in an ``Element`` to give it an identity, or pass the
/// identity to the initializer of a view that consumes its own action
/// (`Bullets`, `Flipper`, `VideoView`).
public struct ElementID: Hashable, Sendable {
    /// A `String` representation of the `ElementID`.
    public let rawValue: String

    /// Create a new instance.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension ElementID {
    static let none = ElementID(rawValue: "")

    static let title = ElementID(rawValue: "title")

    static let bullets = ElementID(rawValue: "bullets")
    static func bullets(_ number: Int) -> ElementID {
        ElementID(rawValue: "bullets\(number)")
    }

    static let flipper = ElementID(rawValue: "flipper")
    static func flipper(_ number: Int) -> ElementID {
        ElementID(rawValue: "flipper\(number)")
    }

    static let video = ElementID(rawValue: "video")
    static func video(_ number: Int) -> ElementID {
        ElementID(rawValue: "video\(number)")
    }

    static func element(_ number: Int) -> ElementID {
        ElementID(rawValue: "element\(number)")
    }
}

private struct ElementIDKey: EnvironmentKey {
    static let defaultValue: ElementID = .none
}

extension EnvironmentValues {
    /// Plumbing for `@SlideValue`.
    ///
    /// A property wrapper cannot read an identity from its view's initializer,
    /// so a view that owns an `ElementID` writes it here for a private child
    /// view that declares the `@SlideValue` (see `VideoView`).
    ///
    /// Actions never resolve their target through this value: `ActionReader`
    /// takes its `ElementID` explicitly.
    var elementID: ElementID {
        get { self[ElementIDKey.self] }
        set { self[ElementIDKey.self] = newValue }
    }
}
