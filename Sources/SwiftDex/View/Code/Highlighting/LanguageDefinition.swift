import Foundation

/// The lexical rules of a programming language, used by `CodeTokenizer`.
///
/// A language is described by data only — keyword set, comment delimiters,
/// string behavior — so supporting a new language means adding a new static
/// definition rather than a new scanner.
struct LanguageDefinition {
    struct BlockComment {
        let start: String
        let end: String
    }

    /// Words highlighted as keywords.
    let keywords: Set<String>

    /// The prefix that starts a comment running to the end of the line.
    let lineCommentPrefix: String?

    /// The delimiters of a block comment.
    let blockComment: BlockComment?

    /// Whether block comments can be nested (true for Swift).
    let supportsNestedBlockComments: Bool

    /// Whether `\(...)` inside a string literal embeds code (true for Swift).
    let supportsStringInterpolation: Bool

    /// The character that starts an attribute (e.g. `@` for `@escaping`).
    let attributePrefix: Character?

    /// The character that starts a compiler directive (e.g. `#` for `#if`).
    let directivePrefix: Character?
}

extension LanguageDefinition {
    static let swift = LanguageDefinition(
        keywords: [
            "actor", "any", "as", "associatedtype", "async", "await",
            "borrowing", "break", "case", "catch", "class", "consuming",
            "continue", "convenience", "default", "defer", "deinit", "didSet",
            "do", "dynamic", "else", "enum", "extension", "fallthrough",
            "false", "fileprivate", "final", "for", "func", "get", "guard",
            "if", "import", "in", "indirect", "init", "inout", "internal",
            "is", "isolated", "lazy", "let", "mutating", "nil", "nonisolated",
            "nonmutating", "open", "operator", "optional", "override",
            "precedencegroup", "private", "protocol", "public", "repeat",
            "required", "rethrows", "return", "self", "Self", "set", "some",
            "static", "struct", "subscript", "super", "switch", "throw",
            "throws", "true", "try", "typealias", "unowned", "var", "weak",
            "where", "while", "willSet",
        ],
        lineCommentPrefix: "//",
        blockComment: BlockComment(start: "/*", end: "*/"),
        supportsNestedBlockComments: true,
        supportsStringInterpolation: true,
        attributePrefix: "@",
        directivePrefix: "#"
    )
}
