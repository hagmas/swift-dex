import SwiftUI

/// A node with a line of text in it — the node nine figures out of ten are
/// made of.
///
/// `TextNode` is to ``Node`` what `Text` is to `View`: the concrete type you
/// reach for until you need your own.
///
/// ```swift
/// TextNode(.repository, title: "Repository")
/// ```
///
/// Its frame, and how its text is set, are up to the ``NodeStyle`` around it.
public struct TextNode: Node {
    /// The identity lines refer to.
    public let id: NodeID

    /// The text shown in the node.
    public var title: String

    /// Creates a node of text.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to.
    ///   - title: The text shown in the node.
    public init(_ id: NodeID, title: String) {
        self.id = id
        self.title = title
    }

    /// The text, unframed.
    public var body: some View {
        Text(title)
    }
}
