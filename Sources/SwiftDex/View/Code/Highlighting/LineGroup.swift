import Foundation

enum VerticalElement: Hashable {
    case singleLine([HorizontalElement])
    case lineGroup(LineGroup)
}

struct LineGroup: Hashable {
    let id: String?
    var elements: [VerticalElement]
}

enum HorizontalElement: Hashable {
    case token(String, TokenType)
    case plainText(String)
    case whiteSpace(String)
}
