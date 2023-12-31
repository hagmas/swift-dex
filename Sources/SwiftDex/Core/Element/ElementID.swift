import SwiftUI

/// `ElementID` is an identifier for each element within a slide.
///
/// It is used to specify which element is the target when using `Action`.
/// The `.elementID` View Modifier can be used to assign an ID to a View, which can then be retrieved as an `environmentValue` in child Views.
public struct ElementID: Hashable {
    /// A `String` representation of the `ElementID`.
    public let rawValue: String

    /// Create a new instance.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension ElementID {
    static var none = ElementID(rawValue: "")

    static var title = ElementID(rawValue: "title")

    static var bullets = ElementID(rawValue: "bullets")
    static func bullets(_ number: Int) -> ElementID {
        ElementID(rawValue: "bullets\(number)")
    }

    static var flipper = ElementID(rawValue: "flipper")
    static func flipper(_ number: Int) -> ElementID {
        ElementID(rawValue: "flipper\(number)")
    }

    static func element(_ number: Int) -> ElementID {
        ElementID(rawValue: "element\(number)")
    }
}

private struct ElementIDKey: EnvironmentKey {
    static let defaultValue: ElementID = .none
}

extension EnvironmentValues {
    var elementID: ElementID {
        get { self[ElementIDKey.self] }
        set { self[ElementIDKey.self] = newValue }
    }
}
