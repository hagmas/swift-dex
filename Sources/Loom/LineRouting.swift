import CoreGraphics

/// How a line gets from one node to the next.
///
/// Set it once for a figure — a diagram wants one kind of line throughout, and
/// a single line drawn differently from its neighbours reads as a mistake
/// rather than as emphasis. Override it on a line only when it means something.
public enum LineRouting: Hashable, Sendable {
    /// Straight from one node to the other.
    case straight

    /// Along the axes, turning at right angles.
    ///
    /// A line leaves and arrives along the direction its edges face, so a hop
    /// between two rows goes down, across, and down again rather than cutting
    /// the corner. Where the two ends already line up the turns collapse and
    /// the line comes out straight.
    case orthogonal
}

extension LineRouting {
    /// The corners between two points, given the direction each end faces.
    ///
    /// Endpoints are the caller's; only what goes between them is returned.
    func corners(
        from start: CGPoint,
        along startAxis: Axis,
        to end: CGPoint,
        along endAxis: Axis
    ) -> [CGPoint] {
        guard self == .orthogonal else {
            return []
        }

        guard startAxis == endAxis else {
            // The two ends face across each other, so one turn joins them:
            // set off the way the start faces, and arrive facing the other way.
            return switch startAxis {
            case .vertical: [CGPoint(x: start.x, y: end.y)]
            case .horizontal: [CGPoint(x: end.x, y: start.y)]
            }
        }

        // Both ends face the same way, so the line has to step sideways
        // somewhere. Halfway leaves equal room at both ends, and is the one
        // choice that does not favour either node.
        return switch startAxis {
        case .vertical:
            [
                CGPoint(x: start.x, y: (start.y + end.y) / 2),
                CGPoint(x: end.x, y: (start.y + end.y) / 2),
            ]
        case .horizontal:
            [
                CGPoint(x: (start.x + end.x) / 2, y: start.y),
                CGPoint(x: (start.x + end.x) / 2, y: end.y),
            ]
        }
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
