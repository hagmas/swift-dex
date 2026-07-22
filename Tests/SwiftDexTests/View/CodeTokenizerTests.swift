import XCTest

@testable import SwiftDex

final class CodeTokenizerTests: XCTestCase {
    private let tokenizer = CodeTokenizer(language: .swift)

    func test_keywordsAndPlainIdentifiers() {
        let fragments = tokenizer.fragments(for: "let value = data")
        XCTAssertEqual(
            fragments,
            [
                .token("let", .keyword),
                .whitespace(" "),
                .plain("value"),
                .whitespace(" "),
                .plain("="),
                .whitespace(" "),
                .plain("data"),
            ]
        )
    }

    func test_typesAndCalls() {
        let fragments = tokenizer.fragments(for: "let view = MyView(count: makeCount())")
        XCTAssertEqual(
            fragments,
            [
                .token("let", .keyword),
                .whitespace(" "),
                .plain("view"),
                .whitespace(" "),
                .plain("="),
                .whitespace(" "),
                .token("MyView", .type),
                .plain("("),
                .plain("count"),
                .plain(":"),
                .whitespace(" "),
                .token("makeCount", .call),
                .plain("("),
                .plain(")"),
                .plain(")"),
            ]
        )
    }

    func test_dotAccessPropertyAndMethodCall() {
        let fragments = tokenizer.fragments(for: "view.model.forward(.fade)")
        XCTAssertEqual(
            fragments,
            [
                .plain("view"),
                .plain("."),
                .token("model", .property),
                .plain("."),
                .token("forward", .call),
                .plain("("),
                .plain("."),
                .token("fade", .dotAccess),
                .plain(")"),
            ]
        )
    }

    func test_numbers() {
        let fragments = tokenizer.fragments(for: "1 + 3.14 + 0xFF + 1_000")
        XCTAssertEqual(
            fragments.filter { fragment in
                if case .token(_, .number) = fragment {
                    return true
                }
                return false
            },
            [
                .token("1", .number),
                .token("3.14", .number),
                .token("0xFF", .number),
                .token("1_000", .number),
            ]
        )
    }

    func test_numberFollowedByPropertyAccess() {
        let fragments = tokenizer.fragments(for: "1.description")
        XCTAssertEqual(
            fragments,
            [
                .token("1", .number),
                .plain("."),
                .token("description", .property),
            ]
        )
    }

    func test_stringLiteral() {
        let fragments = tokenizer.fragments(for: #"let s = "a \"b\" c""#)
        XCTAssertEqual(fragments.last, .token(#""a \"b\" c""#, .string))
    }

    func test_stringInterpolation() {
        let fragments = tokenizer.fragments(for: #""count: \(items.count)""#)
        XCTAssertEqual(
            fragments,
            [
                .token(#""count: \("#, .string),
                .plain("items"),
                .plain("."),
                .token("count", .property),
                .token(")\"", .string),
            ]
        )
    }

    func test_lineComment() {
        let fragments = tokenizer.fragments(for: "let a = 1  // trailing note")
        XCTAssertEqual(fragments.last, .token("// trailing note", .comment))
    }

    func test_nestedBlockComment() {
        let fragments = tokenizer.fragments(for: "/* outer /* inner */ still comment */ let")
        XCTAssertEqual(
            fragments,
            [
                .token("/* outer /* inner */ still comment */", .comment),
                .whitespace(" "),
                .token("let", .keyword),
            ]
        )
    }

    func test_attributeAndDirective() {
        let fragments = tokenizer.fragments(for: "@escaping #if DEBUG")
        XCTAssertEqual(
            fragments,
            [
                .token("@escaping", .keyword),
                .whitespace(" "),
                .token("#if", .preprocessing),
                .whitespace(" "),
                .token("DEBUG", .type),
            ]
        )
    }

    func test_lineGroupSplitsLines() {
        let lineGroup = tokenizer.lineGroup(for: "let a = 1\n\nlet b = 2")
        XCTAssertEqual(lineGroup.elements.count, 3)
        XCTAssertEqual(lineGroup.elements[1], .singleLine([]))
    }

    func test_multilineStringSplitsIntoLines() {
        let lineGroup = tokenizer.lineGroup(for: "\"\"\"\nhello\n\"\"\"")
        XCTAssertEqual(
            lineGroup.elements,
            [
                .singleLine([.token("\"\"\"", .string)]),
                .singleLine([.token("hello", .string)]),
                .singleLine([.token("\"\"\"", .string)]),
            ]
        )
    }
}
