import SwiftUI

public extension ViewBuilder {
    static func buildExpression(_ content: String) -> some View {
        Text(content)
    }

    static func buildExpression(_ content: AttributedString) -> some View {
        Text(content)
    }
}
