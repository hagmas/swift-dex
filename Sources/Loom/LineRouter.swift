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
            .edge(node, edge)
        }
        else {
            .waypoint(node)
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
            RoutedLine(
                points: points(of: route, at: index, spread: spread),
                arrow: route.arrow,
                label: route.label
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

            // Order by where each line is headed along the spreading direction,
            // falling back to the order the lines were written.
            let ordered = members.sorted { left, right in
                let leading = routes[left].heading(along: tangent)
                let trailing = routes[right].heading(along: tangent)
                return leading == trailing
                    ? routes[left].line < routes[right].line
                    : leading < trailing
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

    /// The corners one route is drawn through, turns and all.
    private static func points(
        of route: Route,
        at index: Int,
        spread: [JointIndex: CGPoint]
    ) -> [CGPoint] {
        let placed = route.joints.indices.map {
            spread[JointIndex(route: index, joint: $0)] ?? route.joints[$0].base
        }

        var points: [CGPoint] = []
        for (position, joint) in route.joints.enumerated() {
            if position > 0 {
                points += route.routing.corners(
                    from: placed[position - 1],
                    along: route.joints[position - 1].axis,
                    to: placed[position],
                    along: joint.axis
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
        guard stops.allSatisfy({ rects[$0] != nil && addresses[$0] != nil }) else {
            return nil
        }

        // Every hop chooses its own edges, so a line with a waypoint in it
        // leaves aimed at the waypoint rather than at where it ends up.
        let hops = zip(stops, stops.dropFirst()).map {
            edges(from: addresses[$0]!, to: addresses[$1]!)
        }

        // A stop is the start of one hop, the end of another, or — at a
        // waypoint — in the middle of both, taking no edge at all.
        let stopEdges: [NodeEdge?] = stops.indices.map { position in
            switch position {
            case 0: hops[0].start
            case stops.count - 1: hops[position - 1].end
            default: nil
            }
        }

        let bases = zip(stops, stopEdges).map { node, edge in
            let rect = rects[node]!
            return edge?.point(in: rect) ?? CGPoint(x: rect.midX, y: rect.midY)
        }

        return stops.indices.map { position in
            Joint(
                line: index,
                node: stops[position],
                edge: stopEdges[position],
                axis: stopEdges[position]?.axis ?? waypointAxes[stops[position]] ?? .vertical,
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
}
