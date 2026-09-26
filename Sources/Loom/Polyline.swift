import CoreGraphics

/// One end of a hop: where it is, and which way it points.
struct HopEnd {
    /// Where the line meets the node.
    let point: CGPoint

    /// The direction the line travels here.
    let axis: Axis

    /// The way out of the node, or `nil` at a waypoint, which has no node to
    /// be outside of.
    let facing: CGVector?
}

extension Line.Routing {
    /// The corners between two ends of a hop.
    ///
    /// The ends themselves are the caller's; only what goes between them is
    /// returned.
    func corners(from start: HopEnd, to end: HopEnd, margin: CGFloat) -> [CGPoint] {
        guard self == .orthogonal else {
            return []
        }

        // Two ends can share an axis and still face the same way rather than at
        // each other — a line leaving one node's right side for another node's
        // right side, say. Stepping across halfway between them would then run
        // the line through whatever it is meant to be going around, so it has
        // to get clear of both first.
        if let facing = start.facing, facing == end.facing {
            return aroundTheOutside(from: start.point, to: end.point, facing: facing, margin: margin)
        }

        guard start.axis == end.axis else {
            // The ends face across each other, so one turn joins them: set off
            // the way the start faces, and arrive facing the other way.
            return switch start.axis {
            case .vertical: [CGPoint(x: start.point.x, y: end.point.y)]
            case .horizontal: [CGPoint(x: end.point.x, y: start.point.y)]
            }
        }

        // Facing each other along one axis, so the line steps sideways
        // somewhere between them. Halfway leaves equal room at both ends, and
        // is the one choice that favours neither node.
        return switch start.axis {
        case .vertical:
            [
                CGPoint(x: start.point.x, y: (start.point.y + end.point.y) / 2),
                CGPoint(x: end.point.x, y: (start.point.y + end.point.y) / 2),
            ]
        case .horizontal:
            [
                CGPoint(x: (start.point.x + end.point.x) / 2, y: start.point.y),
                CGPoint(x: (start.point.x + end.point.x) / 2, y: end.point.y),
            ]
        }
    }

    /// Out past whichever end reaches further, across, and back.
    ///
    /// Both ends sit on the outward boundary of their own node in this
    /// direction, so anything beyond the further of the two is beyond both.
    private func aroundTheOutside(
        from start: CGPoint,
        to end: CGPoint,
        facing: CGVector,
        margin: CGFloat
    ) -> [CGPoint] {
        if facing.dy == 0 {
            let x =
                facing.dx > 0
                ? Swift.max(start.x, end.x) + margin
                : Swift.min(start.x, end.x) - margin
            return [CGPoint(x: x, y: start.y), CGPoint(x: x, y: end.y)]
        }

        let y =
            facing.dy > 0
            ? Swift.max(start.y, end.y) + margin
            : Swift.min(start.y, end.y) - margin
        return [CGPoint(x: start.x, y: y), CGPoint(x: end.x, y: y)]
    }
}

extension [CGPoint] {
    /// The same line with its redundant corners removed.
    ///
    /// Turns collapse when the two ends of a hop already line up, leaving
    /// points sitting on top of one another or strung along a straight run.
    /// Both draw the same, but an arrowhead reads the last two points to find
    /// its direction, and a repeated point tells it nothing.
    var simplified: [CGPoint] {
        var result: [CGPoint] = []

        for point in self {
            if let last = result.last, last.isClose(to: point) {
                continue
            }
            if result.count >= 2, isCollinear(result[result.count - 2], result[result.count - 1], point) {
                result.removeLast()
            }
            result.append(point)
        }

        return result
    }
}

private func isCollinear(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
    let cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    return abs(cross) < 0.01
}

extension CGPoint {
    func isClose(to other: CGPoint) -> Bool {
        abs(x - other.x) < 0.01 && abs(y - other.y) < 0.01
    }

    func distance(to other: CGPoint) -> CGFloat {
        let dx = other.x - x
        let dy = other.y - y
        return (dx * dx + dy * dy).squareRoot()
    }
}

extension [CGPoint] {
    /// The point halfway along the line, measured by distance travelled.
    ///
    /// Halfway by distance rather than halfway between the ends, so a label on
    /// a line that turns sits on the run rather than beside it.
    var middle: CGPoint? {
        guard count >= 2 else {
            return first
        }

        let lengths = zip(self, dropFirst()).map { $0.distance(to: $1) }
        let half = lengths.reduce(0, +) / 2
        guard half > 0 else {
            return first
        }

        var travelled: CGFloat = 0
        for (index, length) in lengths.enumerated() {
            if travelled + length >= half {
                let along = (half - travelled) / length
                let start = self[index]
                let end = self[index + 1]
                return CGPoint(
                    x: start.x + (end.x - start.x) * along,
                    y: start.y + (end.y - start.y) * along
                )
            }
            travelled += length
        }

        return last
    }
}
