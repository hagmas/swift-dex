import Foundation
import Splash

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

struct CodeOutputFormat: OutputFormat {
    func makeBuilder() -> Builder {
        Builder()
    }

    struct Builder: OutputBuilder {
        typealias Output = LineGroup

        private var groupStack = [LineGroup(id: nil, elements: [])]
        private var currentLine = [HorizontalElement]()
        private var isGroupToken = false

        mutating func addToken(_ token: String, ofType type: TokenType) {
            switch type {
            case .custom(let name) where name == "Element Group Push":
                let id = String(token.split(separator: "@")[1])
                let group = LineGroup(id: id, elements: [])
                groupStack.append(group)
                currentLine = []
                isGroupToken = true

            case .custom(let name) where name == "Element Pop":
                if let popped = groupStack.popLast() {
                    groupStack[groupStack.count - 1].elements.append(.lineGroup(popped))
                }
                currentLine = []
                isGroupToken = true

            default:
                break
            }

            currentLine.append(.token(token, type))
        }

        mutating func addPlainText(_ text: String) {
            currentLine.append(.plainText(text))
        }

        mutating func addWhitespace(_ whitespace: String) {
            var currentIndex = whitespace.startIndex
            var whitespaceStartIndex: String.Index?

            while currentIndex < whitespace.endIndex {
                if whitespace[currentIndex] == "\n" {
                    if let index = whitespaceStartIndex {
                        let subString = String(whitespace[index..<currentIndex])
                        currentLine.append(.whiteSpace(subString))
                        whitespaceStartIndex = nil
                    }

                    if !isGroupToken {
                        groupStack[groupStack.count - 1].elements.append(.singleLine(currentLine))
                    }
                    else {
                        isGroupToken = false
                    }

                    currentLine = []
                    currentIndex = whitespace.index(after: currentIndex)
                    whitespaceStartIndex = currentIndex
                }
                else {
                    if whitespaceStartIndex == nil {
                        whitespaceStartIndex = currentIndex
                    }
                    currentIndex = whitespace.index(after: currentIndex)
                }
            }
            if let index = whitespaceStartIndex {
                let subString = String(whitespace[index...])
                currentLine.append(.whiteSpace(subString))
            }
        }

        func build() -> Output {
            var last = groupStack.last ?? LineGroup(id: nil, elements: [])
            if !currentLine.isEmpty && !isGroupToken {
                last.elements.append(.singleLine(currentLine))
            }
            return last
        }
    }
}
