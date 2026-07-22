import Foundation

/// The classification of a highlighted code token.
enum TokenType: Hashable {
    case keyword
    case string
    case type
    case call
    case number
    case comment
    case property
    case dotAccess
    case preprocessing
}
