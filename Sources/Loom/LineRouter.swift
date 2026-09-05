import CoreGraphics

/// One side of a node's bounds.
enum NodeEdge: CaseIterable {
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
/// With both anchors given explicitly there is nothing to decide, so the
/// interesting case is the automatic one: try every pair of edge midpoints —
/// sixteen of them — and keep the shortest. Leaving from the middle of an edge
/// rather than from wherever a centre-to-centre ray happens to cross is what
/// makes a run of boxes read as a diagram rather than as a web.
enum LineRouter {
    /// The points at which a line between two nodes meets each of them.
    ///
    /// Ties are broken by ``NodeEdge/allCases`` order, so the same pair of
    /// rectangles always routes the same way.
    static func endpoints(from: CGRect, to: CGRect) -> (start: CGPoint, end: CGPoint) {
        var best: (start: CGPoint, end: CGPoint) = (from.center, to.center)
        var shortest = CGFloat.infinity

        for startEdge in NodeEdge.allCases {
            for endEdge in NodeEdge.allCases {
                let start = startEdge.point(in: from)
                let end = endEdge.point(in: to)
                let distance = start.distance(to: end)
                if distance < shortest {
                    shortest = distance
                    best = (start, end)
                }
            }
        }

        return best
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return (dx * dx + dy * dy).squareRoot()
    }
}
