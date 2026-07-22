import Foundation

/// A colored fragment of source code, as produced by `CodeTokenizer`.
///
/// Fragments may span multiple lines (comments, multiline strings); splitting
/// into displayable lines happens when building the `LineGroup`.
enum CodeFragment: Hashable {
    case token(String, TokenType)
    case plain(String)
    case whitespace(String)
}

/// Splits source code into colored fragments according to a `LanguageDefinition`.
///
/// The tokenizer is purely lexical and aims for slide-quality highlighting,
/// not compiler-grade accuracy.
struct CodeTokenizer {
    let language: LanguageDefinition

    /// Tokenizes the code and assembles it into the `LineGroup` consumed by `Code`.
    func lineGroup(for code: String) -> LineGroup {
        makeLineGroup(from: fragments(for: code))
    }

    /// Tokenizes the code into a flat list of colored fragments.
    func fragments(for code: String) -> [CodeFragment] {
        let cursor = Cursor(code)
        var fragments: [CodeFragment] = []
        scan(cursor, into: &fragments, isInterpolation: false)
        return fragments
    }
}

// MARK: - Scanning

extension CodeTokenizer {
    private func scan(
        _ cursor: Cursor,
        into fragments: inout [CodeFragment],
        isInterpolation: Bool
    ) {
        // The last significant (non-whitespace) character, used to classify
        // identifiers after a dot.
        var lastSignificant: Character?
        // The significant character preceding the most recent ".", used to
        // distinguish leading-dot members (.fade) from property access (a.b).
        var characterBeforeDot: Character?
        var parenthesisDepth = 0

        while let character = cursor.current {
            // An interpolation scan ends at the closing parenthesis of `\(`.
            if isInterpolation, character == ")", parenthesisDepth == 0 {
                return
            }

            if character.isWhitespace {
                fragments.append(.whitespace(cursor.consume(while: \.isWhitespace)))
                continue
            }

            if let prefix = language.lineCommentPrefix, cursor.matches(prefix) {
                fragments.append(.token(cursor.consume(upTo: "\n"), .comment))
                lastSignificant = nil
                continue
            }

            if let block = language.blockComment, cursor.matches(block.start) {
                fragments.append(.token(consumeBlockComment(cursor, block), .comment))
                lastSignificant = nil
                continue
            }

            if character == "\"" {
                consumeString(cursor, into: &fragments)
                lastSignificant = "\""
                continue
            }

            if character.isNumber {
                fragments.append(.token(consumeNumber(cursor), .number))
                lastSignificant = character
                continue
            }

            if character == language.attributePrefix, isIdentifierStart(cursor.peek()) {
                cursor.advance()
                let name = cursor.consume(while: isIdentifierCharacter)
                fragments.append(.token(String(character) + name, .keyword))
                lastSignificant = name.last
                continue
            }

            if character == language.directivePrefix, isIdentifierStart(cursor.peek()) {
                cursor.advance()
                let name = cursor.consume(while: isIdentifierCharacter)
                fragments.append(.token(String(character) + name, .preprocessing))
                lastSignificant = name.last
                continue
            }

            if isIdentifierStart(character) {
                let name = cursor.consume(while: isIdentifierCharacter)
                let tokenType = classify(
                    name,
                    isFollowedByParenthesis: cursor.current == "(",
                    isPrecededByDot: lastSignificant == ".",
                    characterBeforeDot: characterBeforeDot
                )
                if let tokenType {
                    fragments.append(.token(name, tokenType))
                }
                else {
                    fragments.append(.plain(name))
                }
                lastSignificant = name.last
                continue
            }

            // Any other character is unstyled punctuation.
            switch character {
            case "(":
                parenthesisDepth += 1

            case ")":
                parenthesisDepth -= 1

            case ".":
                characterBeforeDot = lastSignificant

            default:
                break
            }
            fragments.append(.plain(String(character)))
            lastSignificant = character
            cursor.advance()
        }
    }

    private func classify(
        _ name: String,
        isFollowedByParenthesis: Bool,
        isPrecededByDot: Bool,
        characterBeforeDot: Character?
    ) -> TokenType? {
        if language.keywords.contains(name) {
            return .keyword
        }

        if isPrecededByDot {
            if isLeadingDot(characterBeforeDot) {
                return .dotAccess
            }
            return isFollowedByParenthesis ? .call : .property
        }

        if name.first?.isUppercase == true {
            return .type
        }

        if isFollowedByParenthesis {
            return .call
        }

        return nil
    }

    /// A dot is "leading" when it starts a member expression (`.fade`) rather
    /// than accessing a member of a preceding value (`view.fade`).
    private func isLeadingDot(_ characterBeforeDot: Character?) -> Bool {
        guard let character = characterBeforeDot else {
            return true
        }
        let continuesExpression =
            isIdentifierCharacter(character)
            || character == ")"
            || character == "]"
            || character == "\""
        return !continuesExpression
    }
}

// MARK: - Compound token scanners

extension CodeTokenizer {
    private func consumeBlockComment(
        _ cursor: Cursor,
        _ block: LanguageDefinition.BlockComment
    ) -> String {
        var text = ""
        var depth = 0
        while !cursor.isAtEnd {
            if cursor.matches(block.start), depth == 0 || language.supportsNestedBlockComments {
                depth += 1
                text += cursor.consume(block.start)
                continue
            }
            if cursor.matches(block.end) {
                depth -= 1
                text += cursor.consume(block.end)
                if depth == 0 {
                    break
                }
                continue
            }
            if let character = cursor.advance() {
                text.append(character)
            }
        }
        return text
    }

    private func consumeString(_ cursor: Cursor, into fragments: inout [CodeFragment]) {
        let delimiter = cursor.matches("\"\"\"") ? "\"\"\"" : "\""
        var text = cursor.consume(delimiter)

        while !cursor.isAtEnd {
            if cursor.matches(delimiter) {
                text += cursor.consume(delimiter)
                break
            }

            if cursor.current == "\\" {
                if language.supportsStringInterpolation, cursor.peek() == "(" {
                    // Emit the string so far, tokenize the embedded code, then
                    // resume the string scan after the closing parenthesis.
                    text += cursor.consume("\\(")
                    fragments.append(.token(text, .string))
                    scan(cursor, into: &fragments, isInterpolation: true)
                    text = cursor.consume(while: { $0 == ")" }, limit: 1)
                    continue
                }

                // Any other escape sequence, e.g. \" or \n.
                if let backslash = cursor.advance() {
                    text.append(backslash)
                }
                if let escaped = cursor.advance() {
                    text.append(escaped)
                }
                continue
            }

            if let character = cursor.advance() {
                text.append(character)
            }
        }

        fragments.append(.token(text, .string))
    }

    private func consumeNumber(_ cursor: Cursor) -> String {
        var text = ""
        let hasRadixPrefix = cursor.matches("0x") || cursor.matches("0b") || cursor.matches("0o")

        while let character = cursor.current {
            if character.isNumber || character == "_" {
                text.append(character)
                cursor.advance()
                continue
            }

            // A dot only continues the number when followed by a digit,
            // so `1.description` stops at "1".
            if character == ".", cursor.peek()?.isNumber == true {
                text.append(character)
                cursor.advance()
                continue
            }

            if hasRadixPrefix, character.isHexDigit || "xbo".contains(character.lowercased()) {
                text.append(character)
                cursor.advance()
                continue
            }

            // Exponents: 2e5, 1e-3.
            if character.lowercased() == "e", text.last?.isNumber == true {
                if cursor.peek()?.isNumber == true {
                    text.append(character)
                    cursor.advance()
                    continue
                }
                if cursor.peek() == "-" || cursor.peek() == "+", cursor.peek(2)?.isNumber == true {
                    text.append(character)
                    cursor.advance()
                    text.append(cursor.advance() ?? " ")
                    continue
                }
            }

            break
        }
        return text
    }

    private func isIdentifierStart(_ character: Character?) -> Bool {
        guard let character else {
            return false
        }
        return character.isLetter || character == "_"
    }

    private func isIdentifierCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "_"
    }
}

// MARK: - Line assembly

extension CodeTokenizer {
    private func makeLineGroup(from fragments: [CodeFragment]) -> LineGroup {
        var lines: [VerticalElement] = []
        var currentLine: [HorizontalElement] = []

        func flushLine() {
            lines.append(.singleLine(currentLine))
            currentLine = []
        }

        func append(_ element: HorizontalElement) {
            // Merge adjacent plain fragments to keep the view hierarchy small.
            if case .plainText(let text) = element,
                case .plainText(let previous) = currentLine.last
            {
                currentLine[currentLine.count - 1] = .plainText(previous + text)
                return
            }
            currentLine.append(element)
        }

        for fragment in fragments {
            let (text, makeElement): (String, (String) -> HorizontalElement) =
                switch fragment {
                case .token(let text, let type):
                    (text, { .token($0, type) })

                case .plain(let text):
                    (text, { .plainText($0) })

                case .whitespace(let text):
                    (text, { .whiteSpace($0) })
                }

            let segments = text.split(separator: "\n", omittingEmptySubsequences: false)
            for (index, segment) in segments.enumerated() {
                if index > 0 {
                    flushLine()
                }
                if !segment.isEmpty {
                    append(makeElement(String(segment)))
                }
            }
        }

        if !currentLine.isEmpty {
            flushLine()
        }
        return LineGroup(id: nil, elements: lines)
    }
}

// MARK: - Cursor

/// A mutable position in the scanned source.
private final class Cursor {
    private let characters: [Character]
    private var index = 0

    init(_ string: String) {
        characters = Array(string)
    }

    var isAtEnd: Bool {
        index >= characters.count
    }

    var current: Character? {
        index < characters.count ? characters[index] : nil
    }

    func peek(_ offset: Int = 1) -> Character? {
        let target = index + offset
        return target < characters.count ? characters[target] : nil
    }

    func matches(_ string: String) -> Bool {
        characters[index...].starts(with: string)
    }

    @discardableResult
    func advance() -> Character? {
        guard let character = current else {
            return nil
        }
        index += 1
        return character
    }

    /// Consumes the given string, which must match the current position.
    func consume(_ string: String) -> String {
        index += string.count
        return string
    }

    func consume(while predicate: (Character) -> Bool, limit: Int = .max) -> String {
        var text = ""
        while let character = current, predicate(character), text.count < limit {
            text.append(character)
            index += 1
        }
        return text
    }

    /// Consumes up to (but not including) the given character.
    func consume(upTo boundary: Character) -> String {
        consume(while: { $0 != boundary })
    }
}
