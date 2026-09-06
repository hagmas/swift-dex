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
}

/// One line's meeting with one node.
private struct Joint {
    let line: Int
    let node: NodeID

    /// The edge the line uses, or `nil` at a tie, which it only passes through.
    let edge: NodeEdge?

    /// Where the joint would sit if it were the only one.
    let base: CGPoint

    /// The next joint along, which says which way this one is headed.
    var neighbour: CGPoint

    /// Where the joint sits once the bundle has been spread out.
    var point: CGPoint

    /// What this joint shares with the ones beside it.
    ///
    /// A tie is keyed by itself rather than by an edge, so a line arriving and
    /// leaving is one point rather than two and the bundle passes through
    /// without a kink.
    var bundle: Bundle {
        if let edge {
            .edge(node, edge)
        }
        else {
            .tie(node)
        }
    }

    /// The direction a bundle spreads in here.
    var tangent: CGVector {
        switch edge {
        case .top, .bottom:
            CGVector(dx: 1, dy: 0)
        case .leading, .trailing:
            CGVector(dx: 0, dy: 1)
        case nil:
            // A tie: lines spread across the run, not along it.
            abs(neighbour.x - base.x) > abs(neighbour.y - base.y)
                ? CGVector(dx: 0, dy: 1)
                : CGVector(dx: 1, dy: 0)
        }
    }
}

/// Something several lines have to share.
private enum Bundle: Hashable {
    /// One edge of one node. Lines meeting it spread along it.
    case edge(NodeID, NodeEdge)

    /// One tie. Lines through it spread across its width.
    case tie(NodeID)
}

extension LineRouter {
    /// Every line, reduced to the points it is drawn through.
    ///
    /// Lines that meet the same edge, or pass through the same tie, are held
    /// apart rather than laid on top of one another. Which edge a line uses is
    /// still decided by the arrangement; only the order lines take within a
    /// bundle is decided by where each is headed, because a line crossing its
    /// neighbours to reach the far side is the one arrangement that always
    /// looks wrong.
    ///
    /// Lines naming a node the arrangement does not hold are dropped — the same
    /// condition ``Figure/issues()`` reports.
    static func routes(
        for lines: [Line],
        rects: [NodeID: CGRect],
        addresses: [NodeID: NodeAddress],
        spacing: CGFloat
    ) -> [RoutedLine] {
        var routes: [(arrow: Line.Arrow, joints: [Joint])] = []

        for (index, line) in lines.enumerated() {
            guard let joints = joints(for: line, line: index, rects: rects, addresses: addresses) else {
                continue
            }
            routes.append((line.arrow, joints))
        }

        spread(&routes, spacing: spacing)

        return routes.map { RoutedLine(points: $0.joints.map(\.point), arrow: $0.arrow) }
    }

    private static func joints(
        for line: Line,
        line index: Int,
        rects: [NodeID: CGRect],
        addresses: [NodeID: NodeAddress]
    ) -> [Joint]? {
        let stops = line.stops
        guard stops.allSatisfy({ rects[$0] != nil && addresses[$0] != nil }) else {
            return nil
        }

        // Every hop chooses its own edges, so a line with a tie in it leaves
        // aimed at the tie rather than at where it eventually ends up.
        let hops = zip(stops, stops.dropFirst()).map { edges(from: addresses[$0]!, to: addresses[$1]!) }

        var joints = stops.enumerated().map { position, node in
            let rect = rects[node]!
            let edge: NodeEdge? =
                if position == 0 {
                    hops[0].start
                }
                else if position == stops.count - 1 {
                    hops[position - 1].end
                }
                else {
                    nil
                }
            let base = edge?.point(in: rect) ?? CGPoint(x: rect.midX, y: rect.midY)
            return Joint(line: index, node: node, edge: edge, base: base, neighbour: base, point: base)
        }

        for index in joints.indices {
            let neighbour = index == joints.count - 1 ? index - 1 : index + 1
            joints[index].neighbour = joints[neighbour].base
        }

        return joints
    }

    /// Holds the lines sharing an edge or a tie apart from one another.
    private static func spread(
        _ routes: inout [(arrow: Line.Arrow, joints: [Joint])],
        spacing: CGFloat
    ) {
        var bundles: [Bundle: [(route: Int, joint: Int)]] = [:]
        for (route, entry) in routes.enumerated() {
            for (joint, value) in entry.joints.enumerated() {
                bundles[value.bundle, default: []].append((route, joint))
            }
        }

        for members in bundles.values where members.count > 1 {
            let tangent = routes[members[0].route].joints[members[0].joint].tangent

            // Order by where each line is headed along the spreading direction,
            // falling back to the order the lines were written so that a tie
            // never depends on the traversal order of a dictionary.
            let ordered = members.sorted { left, right in
                let a = routes[left.route].joints[left.joint]
                let b = routes[right.route].joints[right.joint]
                let alongA = a.neighbour.x * tangent.dx + a.neighbour.y * tangent.dy
                let alongB = b.neighbour.x * tangent.dx + b.neighbour.y * tangent.dy
                return alongA == alongB ? a.line < b.line : alongA < alongB
            }

            let middle = CGFloat(ordered.count - 1) / 2
            for (position, member) in ordered.enumerated() {
                let offset = (CGFloat(position) - middle) * spacing
                let joint = routes[member.route].joints[member.joint]
                routes[member.route].joints[member.joint].point = CGPoint(
                    x: joint.base.x + tangent.dx * offset,
                    y: joint.base.y + tangent.dy * offset
                )
            }
        }
    }
}
