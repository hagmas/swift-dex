import SwiftUI

public extension ViewBuilder {
    static func buildPartialBlock(first content: String) -> some View {
        Text(content)
    }

    static func buildPartialBlock(first content: some View) -> some View {
        content
    }

    static func buildPartialBlock<A: View>(accumulated: A, next: String) -> TupleView<(A, Text)> {
        TupleView((accumulated, Text(next)))
    }

    static func buildPartialBlock<A: View, B: View>(accumulated: A, next: B) -> TupleView<(A, B)> {
        TupleView((accumulated, next))
    }
}
