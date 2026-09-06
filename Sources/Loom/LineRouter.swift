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
        paths: [NodeID: NodePath]
    ) -> (start: NodeEdge, end: NodeEdge)? {
        guard let start = paths[from], let end = paths[to] else {
            return nil
        }
        return edges(from: start, to: end)
    }

    /// The edges a line between two placed nodes leaves and arrives on.
    static func edges(from: NodePath, to: NodePath) -> (start: NodeEdge, end: NodeEdge) {
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
