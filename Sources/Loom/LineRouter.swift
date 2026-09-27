import CoreGraphics

/// One side of a node's bounds.
enum NodeEdge: Hashable {
    case top
    case bottom
    case leading
    case trailing

    /// The midpoint of this edge of `rect`.
    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .top:
            CGPoint(x: rect.midX, y: rect.minY)
        case .bottom:
            CGPoint(x: rect.midX, y: rect.maxY)
        case .leading:
            CGPoint(x: rect.minX, y: rect.midY)
        case .trailing:
            CGPoint(x: rect.maxX, y: rect.midY)
        }
    }
}

/// Chooses where a line meets the nodes it connects.
///
/// The choice is made from the arrangement, not from the rectangles the nodes
/// landed on. Two nodes side by side in a row are joined side to side; two
/// nodes in different rows are joined bottom to top — whatever the measured
/// distances say. Picking the geometrically shortest run instead reads wrong
/// the moment a row is wider than the gap between rows: a line meant to say
/// "the level below" comes out of a node's flank and points sideways.
///
/// So: find the container the two nodes share, take its direction, and leave
/// and arrive along it, in the order the two sit in that container.
enum LineRouter {
    /// The edges a line between two nodes leaves and arrives on.
    ///
    /// Returns `nil` when either node is missing from the arrangement — the
    /// same condition ``Figure/issues()`` reports.
    static func edges(
        from: NodeID,
        to: NodeID,
        addresses: [NodeID: NodeAddress]
    ) -> (start: NodeEdge, end: NodeEdge)? {
        guard let start = addresses[from], let end = addresses[to] else {
            return nil
        }
        return edges(from: start, to: end)
    }

    /// The edges a line between two placed nodes leaves and arrives on.
    static func edges(from: NodeAddress, to: NodeAddress) -> (start: NodeEdge, end: NodeEdge) {
        var depth = 0
        while depth < from.count, depth < to.count, from[depth] == to[depth] {
            depth += 1
        }

        // Distinct nodes are leaves of the same tree, so they part company
        // inside some container they share. A node compared with itself does
        // not, and neither end of that line means anything; fall through to the
        // vertical reading rather than inventing one.
        guard depth < from.count, depth < to.count else {
            return (.bottom, .top)
        }

        let leaves = from[depth]
        let arrives = to[depth]
        let inOrder = leaves.index < arrives.index

        return switch leaves.axis {
        case .horizontal:
            inOrder ? (.trailing, .leading) : (.leading, .trailing)
        case .vertical:
            inOrder ? (.bottom, .top) : (.top, .bottom)
        }
    }

    /// The points at which a line meets the nodes it connects.
    static func endpoints(
        from: CGRect,
        to: CGRect,
        edges: (start: NodeEdge, end: NodeEdge)
    ) -> (start: CGPoint, end: CGPoint) {
        (edges.start.point(in: from), edges.end.point(in: to))
    }
}

/// A line reduced to the points it is drawn through.
struct RoutedLine {
    /// The corners of the line, from where it leaves to where it arrives.
    var points: [CGPoint]

    /// Which ends are tipped with an arrowhead.
    var arrow: Line.Arrow

    /// Words written along the line.
    var label: String?

    /// Where those words go.
    var labelPoint: CGPoint?
}

/// One line's meeting with one node.
///
/// Every field is settled the moment the joint is made, and none of them ever
/// changes afterwards. Where the joint finally lands is not among them: that
/// depends on who else wants the same edge, so it is worked out separately and
/// kept apart from the facts it was derived from.
struct Joint {
    let line: Int
    let node: NodeID

    /// The edge the line uses, or `nil` at a waypoint, which it only passes
    /// through.
    let edge: NodeEdge?

    /// The direction the line travels through here.
    let axis: Axis

    /// The way out of the node, or `nil` at a waypoint, which has no node to
    /// be outside of.
    var facing: CGVector? { edge?.outward }

    /// Where the joint sits before any bundle is spread out.
    let base: CGPoint

    /// The next joint along, which says which way this one is headed.
    let neighbour: CGPoint

    /// What this joint shares with the ones beside it.
    ///
    /// A waypoint is keyed by itself rather than by an edge, so a line arriving
    /// and leaving is one point rather than two, and a bundle passing through
    /// can never pull the two halves apart.
    var bundle: Bundle {
        if let edge {
            // Keyed by the node rather than by the identity the line used, so
            // a line that named this side and one that merely ended up on it
            // are after the same place and are held apart accordingly.
            .edge(node.node, edge)
        }
        else {
            .waypoint(node.node)
        }
    }

    /// The direction a bundle spreads in here: across the travel, not along it.
    var tangent: CGVector {
        switch axis {
        case .vertical: CGVector(dx: 1, dy: 0)
        case .horizontal: CGVector(dx: 0, dy: 1)
        }
    }

    /// How far along `tangent` this joint is headed.
    func heading(along tangent: CGVector) -> CGFloat {
        neighbour.x * tangent.dx + neighbour.y * tangent.dy
    }
}

/// Something several lines have to share.
enum Bundle: Hashable {
    /// One edge of one node. Lines meeting it spread along it.
    case edge(NodeID, NodeEdge)

    /// One waypoint. Lines through it spread across its width.
    case waypoint(NodeID)
}

/// One line, on its way to being drawn.
struct Route {
    let arrow: Line.Arrow
    let label: String?
    let routing: Line.Routing
    let joints: [Joint]

    /// Whether the line comes back to the node it left.
    var isLoop: Bool {
        joints.count == 2 && joints[0].node.node == joints[1].node.node
    }
}

/// Where one joint sits among the routes.
struct JointIndex: Hashable {
    let route: Int
    let joint: Int
}

extension [Route] {
    /// The joint at `index`.
    subscript(index: JointIndex) -> Joint {
        self[index.route].joints[index.joint]
    }
}

extension LineRouter {
    /// How much of a node a loop hanging off it takes up.
    ///
    /// Of the node's shorter side, so a loop on a wide flat box is as tall as
    /// one on a tall thin box is wide, and neither swallows the node.
    static let loopSpan: CGFloat = 0.6

    /// Every line, reduced to the points it is drawn through.
    ///
    /// Lines that meet the same edge, or pass through the same waypoint, are
    /// held apart rather than laid on top of one another. Which edge a line
    /// uses is still decided by the arrangement; only the order lines take
    /// within a bundle is decided by where each is headed, because a line
    /// crossing its neighbours to reach the far side is the one arrangement
    /// that always looks wrong.
    ///
    /// Lines naming a node the arrangement does not hold are dropped — the same
    /// condition ``Figure/issues()`` reports.
    static func routes(
        for lines: [Line],
        rects: [NodeID: CGRect],
        addresses: [NodeID: NodeAddress],
        waypointAxes: [NodeID: Axis],
        routing: Line.Routing,
        spacing: CGFloat
    ) -> [RoutedLine] {
        var routes: [Route] = []

        for (index, line) in lines.enumerated() {
            guard
                let joints = joints(
                    for: line,
                    line: index,
                    rects: rects,
                    addresses: addresses,
                    waypointAxes: waypointAxes
                )
            else {
                continue
            }
            routes.append(
                Route(
                    arrow: line.arrow,
                    label: line.label,
                    routing: line.routing ?? routing,
                    joints: joints
                )
            )
        }

        let spread = spreadPoints(of: routes, spacing: spacing)

        return routes.enumerated().map { index, route in
            // Room to get outside a node before turning back towards it. Taken
            // from the lane width rather than invented, so a figure that wants
            // its lines further apart gets its detours further out as well.
            let drawn = points(of: route, at: index, spread: spread, margin: spacing * 2)
            return RoutedLine(
                points: drawn,
                arrow: route.arrow,
                label: route.label,
                labelPoint: labelPoint(of: route, along: drawn)
            )
        }
    }

    /// Where every joint ends up, once the lines sharing an edge or a waypoint
    /// have been held apart.
    ///
    /// The routes come in immutably, and that is the point rather than a
    /// nicety. Every ordering decision here reads a joint's `base`, and a base
    /// never moves. Were the spread points written back into the joints as they
    /// were worked out, a later bundle could order itself against an earlier
    /// one's result — and since the bundles are gathered in a dictionary, which
    /// came first is not defined. The same figure would come out differently
    /// from one run to the next, by a few points at a time.
    static func spreadPoints(of routes: [Route], spacing: CGFloat) -> [JointIndex: CGPoint] {
        var points: [JointIndex: CGPoint] = [:]

        // A bundle of one falls out of the same arithmetic: its single member
        // sits at the middle, which is nought from its base.
        for members in bundles(in: routes).values {
            let tangent = routes[members[0]].tangent

            // Lanes exist to separate ends that would land on the very same
            // point, so they are worked out among exactly those. Most ends on
            // an edge are all at its middle and make one such group. A loop's
            // two ends are the exception: the loop has already set them apart
            // by a span of its own, and nudging them again would either squash
            // that or blow it out.
            for together in Dictionary(grouping: members, by: { routes[$0].base.rounded }).values {
                // Order by where each line is headed, falling back to the order
                // the lines were written: `sorted(by:)` promises nothing about
                // equal elements, and a figure that came out differently from
                // one run to the next would be worse than any ordering.
                let ordered = together.sorted { left, right in
                    let here = routes[left].heading(along: tangent)
                    let there = routes[right].heading(along: tangent)
                    guard here == there else {
                        return here < there
                    }
                    return (routes[left].line, left.joint) < (routes[right].line, right.joint)
                }

                let middle = CGFloat(ordered.count - 1) / 2
                for (position, member) in ordered.enumerated() {
                    let offset = (CGFloat(position) - middle) * spacing
                    let base = routes[member].base
                    points[member] = CGPoint(
                        x: base.x + tangent.dx * offset,
                        y: base.y + tangent.dy * offset
                    )
                }
            }
        }

        return points
    }

    /// Which joints are after the same edge or the same waypoint.
    private static func bundles(in routes: [Route]) -> [Bundle: [JointIndex]] {
        var bundles: [Bundle: [JointIndex]] = [:]

        for (route, entry) in routes.enumerated() {
            for (joint, value) in entry.joints.enumerated() {
                bundles[value.bundle, default: []]
                    .append(JointIndex(route: route, joint: joint))
            }
        }

        return bundles
    }

    /// Where a line's words go.
    ///
    /// Halfway along, so the words sit on the line and split it. A loop is the
    /// exception: halfway along a loop is the middle of its far side, which is
    /// the very part that makes it read as going round, so the words stand off
    /// beyond it instead.
    private static func labelPoint(of route: Route, along points: [CGPoint]) -> CGPoint? {
        guard route.label != nil, let middle = points.middle else {
            return nil
        }
        guard route.isLoop, let facing = route.joints[0].facing else {
            return middle
        }

        let clear = route.joints[0].base.distance(to: route.joints[1].base)
        return CGPoint(x: middle.x + facing.dx * clear, y: middle.y + facing.dy * clear)
    }

    /// The corners one route is drawn through, turns and all.
    private static func points(
        of route: Route,
        at index: Int,
        spread: [JointIndex: CGPoint],
        margin: CGFloat
    ) -> [CGPoint] {
        let placed = route.joints.indices.map {
            spread[JointIndex(route: index, joint: $0)] ?? route.joints[$0].base
        }

        var points: [CGPoint] = []
        for (position, joint) in route.joints.enumerated() {
            if position > 0 {
                let previous = route.joints[position - 1]
                // A hop that starts and ends at one node is a loop, and a loop
                // drawn straight is a line back on top of itself. There is no
                // straight reading of going round, so it goes round either way.
                let isLoop = previous.node.node == joint.node.node
                let routing: Line.Routing = isLoop ? .orthogonal : route.routing
                // A loop reaches out about as far as it is wide, so it comes
                // out square rather than as a long thin bracket.
                let reach =
                    isLoop ? previous.base.distance(to: joint.base) : margin
                points += routing.corners(
                    from: HopEnd(
                        point: placed[position - 1],
                        axis: previous.axis,
                        facing: previous.facing
                    ),
                    to: HopEnd(point: placed[position], axis: joint.axis, facing: joint.facing),
                    margin: reach
                )
            }
            points.append(placed[position])
        }

        return points.simplified
    }

    private static func joints(
        for line: Line,
        line index: Int,
        rects: [NodeID: CGRect],
        addresses: [NodeID: NodeAddress],
        waypointAxes: [NodeID: Axis]
    ) -> [Joint]? {
        let stops = line.stops
        guard stops.allSatisfy({ rects[$0.node] != nil && addresses[$0.node] != nil }) else {
            return nil
        }

        // Every hop chooses its own edges, so a line with a waypoint in it
        // leaves aimed at the waypoint rather than at where it ends up. A stop
        // naming a side has nothing to choose, but its neighbours still do, so
        // the hops are worked out either way.
        let hops = zip(stops, stops.dropFirst()).map {
            edges(from: addresses[$0.node]!, to: addresses[$1.node]!)
        }

        // A stop is the start of one hop, the end of another, or — at a
        // waypoint — in the middle of both, taking no edge at all. A stop that
        // named a side of its node overrules all of that: being told beats
        // being worked out.
        let stopEdges: [NodeEdge?] = stops.indices.map { position in
            if let named = stops[position].edge {
                return named
            }
            return switch position {
            case 0: hops[0].start
            case stops.count - 1: hops[position - 1].end
            default: nil
            }
        }

        var bases = zip(stops, stopEdges).map { stop, edge in
            let rect = rects[stop.node]!
            return edge?.point(in: rect) ?? CGPoint(x: rect.midX, y: rect.midY)
        }

        // A loop's two ends would otherwise be the same point, left to the
        // bundle to prise apart by one lane — which is the right gap between
        // two lines running side by side, and far too small for something meant
        // to read as going round. So a loop sets its own: a share of the node
        // it hangs off, which keeps it in proportion to the box whatever size
        // the box turns out to be.
        if line.isLoop, let edge = stopEdges.first ?? nil, stopEdges.allSatisfy({ $0 == edge }) {
            let rect = rects[stops[0].node]!
            let span = Swift.min(rect.width, rect.height) * Self.loopSpan
            let across = edge.axis == .horizontal ? CGVector(dx: 0, dy: 1) : CGVector(dx: 1, dy: 0)
            bases = bases.indices.map { position in
                let offset = position == 0 ? -span / 2 : span / 2
                return CGPoint(
                    x: bases[position].x + across.dx * offset,
                    y: bases[position].y + across.dy * offset
                )
            }
        }

        return stops.indices.map { position in
            Joint(
                line: index,
                node: stops[position],
                edge: stopEdges[position],
                axis: stopEdges[position]?.axis ?? waypointAxes[stops[position].node] ?? .vertical,
                base: bases[position],
                neighbour: bases[position == bases.count - 1 ? position - 1 : position + 1]
            )
        }
    }
}

extension NodeEdge {
    /// The direction a line travels as it meets this edge.
    var axis: Axis {
        switch self {
        case .top, .bottom: .vertical
        case .leading, .trailing: .horizontal
        }
    }

    /// The way out of the node from this edge.
    ///
    /// Signed, unlike ``axis``: two ends of a hop can share an axis and still
    /// face the same way rather than at each other, and the line between them
    /// has to be drawn very differently.
    var outward: CGVector {
        switch self {
        case .top: CGVector(dx: 0, dy: -1)
        case .bottom: CGVector(dx: 0, dy: 1)
        case .leading: CGVector(dx: -1, dy: 0)
        case .trailing: CGVector(dx: 1, dy: 0)
        }
    }
}
