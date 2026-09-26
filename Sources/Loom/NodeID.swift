import Foundation

/// The identity of a node within a figure.
///
/// A node's identity is what lines refer to, so every node carries one. Declare
/// the identities a figure uses as static members, the way `Line` reads at the
/// call site:
///
/// ```swift
/// extension NodeID {
///     static let viewModel = NodeID("viewModel")
///     static let repository = NodeID("repository")
/// }
///
/// Line(from: .viewModel, to: .repository)
/// ```
///
/// Naming one of a node's four sides gives back another identity — the same
/// node, but a particular side of it — which a line may use in place of the
/// node to say exactly where it should meet:
///
/// ```swift
/// Line(from: .viewModel.bottom, to: .repository.top)
/// ```
///
/// A side is part of the identity rather than a note attached to it, so
/// `viewModel` and `viewModel.bottom` are two different values. Only a plain
/// identity ever names a node; a side is somewhere on one.
///
/// The raw value is a plain `String` so a host framework can map it onto its own
/// identity type without Loom knowing anything about that framework.
public struct NodeID: Hashable, Sendable {
    /// The underlying string.
    public let rawValue: String

    /// The side of the node this identity picks out, if it picks one out.
    let edge: NodeEdge?

    /// Creates an identity from its string representation.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
        self.edge = nil
    }

    private init(_ rawValue: String, edge: NodeEdge?) {
        self.rawValue = rawValue
        self.edge = edge
    }

    /// The node itself, with any side forgotten.
    ///
    /// Everything that asks where a node *is* asks with this: a node has one
    /// place, whichever of its sides a line happens to name.
    var node: NodeID {
        edge == nil ? self : NodeID(rawValue)
    }

    func on(_ edge: NodeEdge) -> NodeID {
        NodeID(rawValue, edge: edge)
    }
}

public extension NodeID {
    /// The top of this node.
    var top: NodeID { on(.top) }

    /// The bottom of this node.
    var bottom: NodeID { on(.bottom) }

    /// The leading side of this node.
    var leading: NodeID { on(.leading) }

    /// The trailing side of this node.
    var trailing: NodeID { on(.trailing) }
}

extension NodeID: CustomStringConvertible {
    /// The identity's string representation.
    public var description: String {
        guard let edge else {
            return rawValue
        }
        return "\(rawValue).\(edge)"
    }
}
