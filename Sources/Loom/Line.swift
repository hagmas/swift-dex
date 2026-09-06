import Foundation

/// A connection drawn between two nodes.
///
/// Anchors are chosen automatically: Loom picks the pair of node edges that
/// gives the shortest run, so the common case needs no geometry at the call
/// site.
///
/// ```swift
/// Line(from: .viewModel, to: .repository)
/// ```
///
/// A line carries no identity of its own. Identity is opt-in everywhere in a
/// figure, and most lines are never addressed by anything.
public struct Line {
    /// The node the line leaves.
    public let from: NodeID

    /// The node the line arrives at.
    public let to: NodeID

    /// Which ends are tipped with an arrowhead.
    public var arrow: Arrow

    /// Creates a line between two nodes.
    ///
    /// - Parameters:
    ///   - from: The node the line leaves.
    ///   - to: The node the line arrives at.
    ///   - arrow: Which ends are tipped. Defaults to the arriving end, since
    ///     `from`/`to` already state a direction.
    public init(from: NodeID, to: NodeID, arrow: Arrow = .end) {
        self.from = from
        self.to = to
        self.arrow = arrow
    }
}

public extension Line {
    /// Which ends of a line are tipped with an arrowhead.
    enum Arrow: Hashable, Sendable {
        /// No arrowheads.
        case none
        /// An arrowhead where the line arrives.
        case end
        /// An arrowhead where the line leaves.
        case start
        /// Arrowheads at both ends.
        case both

        var tipsStart: Bool {
            self == .start || self == .both
        }

        var tipsEnd: Bool {
            self == .end || self == .both
        }
    }
}

/// Collects the lines of a figure written as a block.
@resultBuilder
public enum LineBuilder {
    /// Gathers the lines written one per statement.
    public static func buildBlock(_ lines: Line...) -> [Line] {
        lines
    }

    /// Passes an array of lines through unchanged.
    public static func buildBlock(_ lines: [Line]) -> [Line] {
        lines
    }
}
