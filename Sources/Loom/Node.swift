import SwiftUI

/// A thing a figure connects.
///
/// `Node` is a protocol so that what a node *looks like* stays open while the
/// arrangement stays closed. Define a type per kind of node — the type is the
/// category, which is why nodes carry no `role` or `kind` tag:
///
/// ```swift
/// struct ServiceNode: Node {
///     let id: NodeID
///     var name: String
///
///     var body: some View {
///         Text(name)
///             .padding()
///             .background(Capsule().fill(.orange))
///     }
/// }
/// ```
///
/// Loom ships ``Box`` for the common case.
///
/// A node's bounds are published under its ``id`` so lines can find it; that is
/// the whole of what Loom does with a node beyond placing it.
public protocol Node: FigureElement {
    /// The view this node renders as.
    associatedtype Body: View

    /// The identity lines refer to.
    var id: NodeID { get }

    /// The node's appearance. Anything at all.
    @ViewBuilder var body: Body { get }
}

public extension Node {
    var elementBody: some View {
        body
            .anchorPreference(key: NodeAnchorsPreference.self, value: .bounds) {
                [id: $0]
            }
    }

    var nodeIDs: [NodeID] {
        [id]
    }
}

/// Where each node ended up, in the figure's coordinate space.
///
/// Nodes are placed by SwiftUI, so this is the only channel through which a
/// line learns a node's position.
struct NodeAnchorsPreference: PreferenceKey {
    static let defaultValue: [NodeID: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [NodeID: Anchor<CGRect>],
        nextValue: () -> [NodeID: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}
