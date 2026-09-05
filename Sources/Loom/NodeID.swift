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
/// The raw value is a plain `String` so a host framework can map it onto its own
/// identity type without Loom knowing anything about that framework.
public struct NodeID: Hashable, Sendable {
    /// The underlying string.
    public let rawValue: String

    /// Creates an identity from its string representation.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension NodeID: CustomStringConvertible {
    /// The identity's string representation.
    public var description: String {
        rawValue
    }
}
