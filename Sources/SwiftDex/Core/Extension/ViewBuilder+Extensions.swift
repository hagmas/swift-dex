import SwiftUI

public extension ViewBuilder {
    static func buildExpression(_ content: String) -> some View {
        if let attributedString = try? AttributedString(markdown: content) {
            return Text(attributedString)
        }
        else {
            return Text(content)
        }
    }

    static func buildExpression(_ content: AttributedString) -> some View {
        Text(content)
    }
}
