import Foundation

/// A connection drawn between two nodes.
///
/// Anchors are chosen automatically, so the common case needs no geometry at
/// the call site.
///
/// ```swift
/// Line(from: .viewModel, to: .repository)
/// ```
///
/// Route it deliberately by naming ties to pass through, in order. The route is
/// still written in terms of the arrangement rather than in coordinates:
///
/// ```swift
/// Line(from: .viewModel, to: .store, through: .sideChannel)
/// ```
///
/// A line carries no identity of its own. Identity is opt-in everywhere in a
/// figure, and most lines are never addressed by anything.
public struct Line {
    /// The node the line leaves.
    public let from: NodeID

    /// The node the line arrives at.
    public let to: NodeID

    /// The ties the line is routed through, in the order it meets them.
    public let waypoints: [NodeID]

    /// Which ends are tipped with an arrowhead.
    public var arrow: Arrow

    /// Creates a line between two nodes.
    ///
    /// - Parameters:
    ///   - from: The node the line leaves.
    ///   - to: The node the line arrives at.
    ///   - through: Ties to route through, in the order the line meets them.
    ///   - arrow: Which ends are tipped. Defaults to the arriving end, since
    ///     `from`/`to` already state a direction.
    public init(
        from: NodeID,
        to: NodeID,
        through: NodeID...,
        arrow: Arrow = .end
    ) {
        self.from = from
        self.to = to
        self.waypoints = through
        self.arrow = arrow
    }

    /// Every node the line touches, in order.
    ///
    /// A line is a run of hops between consecutive stops, and each hop picks
    /// its own edges — which is why a line leaves its first node aimed at the
    /// first tie rather than at its eventual destination.
    public var stops: [NodeID] {
        [from] + waypoints + [to]
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
