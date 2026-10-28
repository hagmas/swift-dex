import SwiftUI

/// A thing a figure connects, drawn as its content in a frame.
///
/// A node says what it is; the figure says how it is framed. Write only the
/// content — no background, no outline — and the ``NodeStyle`` around it draws
/// the frame, the same for every kind of node:
///
/// ```swift
/// struct ServiceNode: Node {
///     let id: NodeID
///     var name: String
///     var icon: String
///
///     var body: some View {
///         VStack {
///             Image(systemName: icon)
///             Text(name)
///         }
///     }
/// }
///
/// ServiceNode(id: .api, name: "API", icon: "network")
///     .nodeStyle(.service)
/// ```
///
/// Define a type per kind of node — the type is the category, which is why
/// nodes carry no `role` or `kind` tag. Loom ships ``TextNode`` for the common
/// case.
public protocol Node: Connectable {
    /// The view this node's content renders as.
    associatedtype Body: View

    /// What the node shows, unframed.
    @ViewBuilder var body: Body { get }
}

public extension Node {
    /// The content, framed, reporting where it is.
    @MainActor var elementBody: some View {
        NodeFrame(content: body)
            .reportsBounds(as: id)
    }

    var placements: [Placement] {
        [.node(id)]
    }
}
