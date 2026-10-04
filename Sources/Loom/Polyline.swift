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
    /// The point, coarse enough to be used as a key.
    ///
    /// Ends that were worked out by the same arithmetic land on exactly the
    /// same point, but rounding keeps a stray fraction from splitting them up.
    var rounded: CGPoint {
        CGPoint(x: (x * 100).rounded() / 100, y: (y * 100).rounded() / 100)
    }

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
        point(along: length / 2)
    }

    /// How far the line travels from end to end.
    var length: CGFloat {
        zip(self, dropFirst()).map { $0.distance(to: $1) }.reduce(0, +)
    }

    /// The point `distance` along the line from its first point.
    func point(along distance: CGFloat) -> CGPoint? {
        guard count >= 2, distance > 0 else {
            return first
        }

        var travelled: CGFloat = 0
        for (start, end) in zip(self, dropFirst()) {
            let length = start.distance(to: end)
            if length > 0, travelled + length >= distance {
                let along = (distance - travelled) / length
                return CGPoint(
                    x: start.x + (end.x - start.x) * along,
                    y: start.y + (end.y - start.y) * along
                )
            }
            travelled += length
        }

        return last
    }

    /// The line with its first `distance` cut away.
    func dropping(_ distance: CGFloat) -> [CGPoint] {
        guard distance > 0, let start = point(along: distance) else {
            return self
        }

        var travelled: CGFloat = 0
        var rest = [start]
        for (from, to) in zip(self, dropFirst()) {
            travelled += from.distance(to: to)
            if travelled > distance + 0.01 {
                rest.append(to)
            }
        }
        return rest
    }

    /// How far this line and `other` run together from their first points
    /// before they part.
    ///
    /// Measured along the run rather than by matching corners: a branch that
    /// goes straight on and one that turns off it share the first stretch even
    /// though only one of them has a corner where the other leaves.
    func sharedLength(with other: [CGPoint]) -> CGFloat {
        guard let start = first, let otherStart = other.first, start.isClose(to: otherStart) else {
            return 0
        }

        var shared: CGFloat = 0
        var here = 1
        var there = 1
        var position = start

        while here < count, there < other.count {
            let ahead = self[here]
            let otherAhead = other[there]
            let reach = position.distance(to: ahead)
            let otherReach = position.distance(to: otherAhead)
            guard reach > 0, otherReach > 0 else {
                if reach == 0 { here += 1 }
                if otherReach == 0 { there += 1 }
                continue
            }

            // Both heading the same way from here, or they have parted.
            let direction = CGVector(dx: (ahead.x - position.x) / reach, dy: (ahead.y - position.y) / reach)
            let otherDirection = CGVector(
                dx: (otherAhead.x - position.x) / otherReach,
                dy: (otherAhead.y - position.y) / otherReach
            )
            guard abs(direction.dx - otherDirection.dx) < 0.001, abs(direction.dy - otherDirection.dy) < 0.001 else {
                break
            }

            let step = Swift.min(reach, otherReach)
            shared += step
            position = CGPoint(x: position.x + direction.dx * step, y: position.y + direction.dy * step)
            if reach <= otherReach { here += 1 }
            if otherReach <= reach { there += 1 }
        }

        return shared
    }
}
