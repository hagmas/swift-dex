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
/// Route it deliberately by naming waypoints to pass through, in order. The
/// route is still written in terms of the arrangement rather than in
/// coordinates:
///
/// ```swift
/// Line(from: .viewModel, to: .store, through: .sideChannel)
/// ```
///
/// One line can fan out to several nodes, or gather several into one. It is
/// drawn as a single trunk at the shared end that branches towards the others —
/// the way a class diagram draws subclasses meeting at one arrowhead:
///
/// ```swift
/// Line(from: .model, to: .user, .settings)
/// Line(from: .dog, .cat, to: .animal, style: .inheritance)
/// ```
///
/// Lines written separately are separate relationships, and are held apart
/// where they meet the same side of a node even when they go to different
/// places. Saying which lines belong together is the author's call, not
/// something worked out from where they happen to go.
///
/// A line carries no identity of its own. Identity is opt-in everywhere in a
/// figure, and most lines are never addressed by anything.
public struct Line {
    /// The nodes the line leaves.
    ///
    /// More than one only when ``to`` has one.
    public let from: [NodeID]

    /// The nodes the line arrives at.
    ///
    /// More than one only when ``from`` has one.
    public let to: [NodeID]

    /// The waypoints the line is routed through, in the order it meets them.
    public let waypoints: [NodeID]

    /// Words written along the line, splitting it where they sit.
    public var label: String?

    /// How the line gets where it is going, or `nil` to follow the figure.
    public var routing: Routing?

    /// Which ends are tipped with an arrowhead.
    public var arrow: Arrow

    /// How the line looks, or `nil` to follow the figure.
    public var style: LineStyle?

    /// Creates a line between two nodes.
    ///
    /// - Parameters:
    ///   - from: The node the line leaves.
    ///   - to: The node the line arrives at.
    ///   - through: Waypoints to route through, in the order the line meets them.
    ///   - label: Words to write along the line.
    ///   - routing: How the line gets where it is going. Defaults to whatever
    ///     the figure was rendered with, since a figure almost always wants one
    ///     kind of line throughout.
    ///   - arrow: Which ends are tipped. Defaults to the arriving end, since
    ///     `from`/`to` already state a direction.
    ///   - style: How the line looks. Defaults to the figure's line style.
    public init(
        from: NodeID,
        to: NodeID,
        through: NodeID...,
        label: String? = nil,
        routing: Routing? = nil,
        arrow: Arrow = .end,
        style: LineStyle? = nil
    ) {
        self.init(
            from: [from],
            to: [to],
            through: through,
            label: label,
            routing: routing,
            arrow: arrow,
            style: style
        )
    }

    /// Creates a line from one node that branches out to several.
    ///
    /// ```swift
    /// Line(from: .model, to: .user, .settings)
    /// ```
    ///
    /// The parameters are those of ``init(from:to:through:label:routing:arrow:style:)``.
    /// Waypoints are passed through by the trunk, before it branches; the label
    /// sits on the trunk.
    public init(
        from: NodeID,
        to first: NodeID,
        _ second: NodeID,
        _ rest: NodeID...,
        through: NodeID...,
        label: String? = nil,
        routing: Routing? = nil,
        arrow: Arrow = .end,
        style: LineStyle? = nil
    ) {
        self.init(
            from: [from],
            to: [first, second] + rest,
            through: through,
            label: label,
            routing: routing,
            arrow: arrow,
            style: style
        )
    }

    /// Creates a line from several nodes that gathers into one.
    ///
    /// ```swift
    /// Line(from: .dog, .cat, to: .animal, style: .inheritance)
    /// ```
    ///
    /// The parameters are those of ``init(from:to:through:label:routing:arrow:style:)``.
    /// Waypoints are passed through by the trunk, after it has gathered; the
    /// label sits on the trunk.
    public init(
        from first: NodeID,
        _ second: NodeID,
        _ rest: NodeID...,
        to: NodeID,
        through: NodeID...,
        label: String? = nil,
        routing: Routing? = nil,
        arrow: Arrow = .end,
        style: LineStyle? = nil
    ) {
        self.init(
            from: [first, second] + rest,
            to: [to],
            through: through,
            label: label,
            routing: routing,
            arrow: arrow,
            style: style
        )
    }

    private init(
        from: [NodeID],
        to: [NodeID],
        through: [NodeID],
        label: String?,
        routing: Routing?,
        arrow: Arrow,
        style: LineStyle?
    ) {
        self.from = from
        self.to = to
        self.waypoints = through
        self.label = label
        self.routing = routing
        self.arrow = arrow
        self.style = style
    }

    /// Creates a line from a node back to itself.
    ///
    /// Name the side the loop should sit on — the whole of it hangs off that
    /// one side, leaving and arriving there:
    ///
    /// ```swift
    /// Line(looping: .deactivated.trailing, label: "stays")
    /// ```
    ///
    /// A loop always goes round, whatever the figure's routing says, because
    /// there is no straight reading of coming back to where you started.
    ///
    /// - Parameters:
    ///   - end: The side of the node the loop hangs off.
    ///   - label: Words to write along the loop.
    ///   - arrow: Which ends are tipped. The two ends sit a lane apart on the
    ///     same side, so this is also which way round the loop reads.
    ///   - style: How the loop looks. Defaults to the figure's line style.
    public init(looping end: NodeID, label: String? = nil, arrow: Arrow = .end, style: LineStyle? = nil) {
        self.init(from: end, to: end, label: label, arrow: arrow, style: style)
    }

    /// Whether the line comes back to the node it left.
    var isLoop: Bool {
        from.count == 1 && to.count == 1 && from[0].node == to[0].node
    }

    /// Every node each branch of the line touches, in order — one branch for
    /// each node at the end that has several, and just the one otherwise.
    ///
    /// A branch is a run of hops between consecutive stops, and each hop picks
    /// its own edges — which is why a line leaves its first node aimed at the
    /// first waypoint rather than at its eventual destination.
    public var branches: [[NodeID]] {
        from.flatMap { start in
            to.map { end in [start] + waypoints + [end] }
        }
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

        /// The same arrowheads, less the one at the start or at the end.
        func without(atStart start: Bool) -> Arrow {
            switch (self, start) {
            case (.both, true): .end
            case (.both, false): .start
            case (.start, true), (.end, false): .none
            default: self
            }
        }
    }

    /// How a line gets from one node to the next.
    ///
    /// Set it once for a figure — a diagram wants one kind of line throughout,
    /// and a single line drawn differently from its neighbours reads as a
    /// mistake rather than as emphasis. Override it on a line only when it
    /// means something.
    enum Routing: Hashable, Sendable {
        /// Straight from one node to the other.
        case straight

        /// Along the axes, turning at right angles.
        ///
        /// A line leaves and arrives along the direction its edges face, so a
        /// hop between two rows goes down, across, and down again rather than
        /// cutting the corner. Where the two ends already line up the turns
        /// collapse and the line comes out straight.
        case orthogonal
    }
}

/// Collects the lines of a figure written as a block.
@resultBuilder
public enum LineBuilder {
    /// Takes a line written on its own.
    public static func buildExpression(_ line: Line) -> [Line] {
        [line]
    }

    /// Takes a ready-made array of lines.
    public static func buildExpression(_ lines: [Line]) -> [Line] {
        lines
    }

    /// Gathers everything the block produced.
    public static func buildBlock(_ lines: [Line]...) -> [Line] {
        lines.flatMap { $0 }
    }

    /// Keeps the lines an `if` may or may not have reached.
    public static func buildOptional(_ lines: [Line]?) -> [Line] {
        lines ?? []
    }

    /// Takes the `if` branch of an `if`/`else`.
    public static func buildEither(first lines: [Line]) -> [Line] {
        lines
    }

    /// Takes the `else` branch of an `if`/`else`.
    public static func buildEither(second lines: [Line]) -> [Line] {
        lines
    }

    /// Gathers the lines a `for` produced.
    public static func buildArray(_ lines: [[Line]]) -> [Line] {
        lines.flatMap { $0 }
    }
}
