import SwiftUI

/// One line, drawn through the points it was routed along.
struct LineView: View {
    let route: RoutedLine
    let style: LineStyle

    /// How much of the line has appeared, from none of it to all.
    let appeared: CGFloat

    private var width: CGFloat {
        style.width
    }

    private var head: CGFloat {
        style.arrowHead.size ?? width * 5
    }

    var body: some View {
        let own = ownPart(of: route.points)
        let points = shown(own)

        ZStack {
            Path { path in
                path.addRoundedLines(stroked(points), radius: style.cornerRadius)
            }
            .stroke(style.color, style: StrokeStyle(lineWidth: width, dash: style.dash))

            if route.arrow.tipsEnd, points.count >= 2 {
                arrowHead(at: points[points.count - 1], from: heading(into: points))
            }

            if route.arrow.tipsStart, points.count >= 2 {
                arrowHead(at: points[0], from: heading(into: points.reversed()))
            }

            if let label = route.label, let point = route.labelPoint {
                let words = Text(label)
                    .font(.system(size: style.labelFontSize))
                    .foregroundStyle(style.labelColor)
                    .padding(.horizontal, style.labelPadding)
                    // Opaque, so the line reads as split by the words rather
                    // than running under them. On a background that is not a
                    // flat colour, the line shows through.
                    .background(style.labelBackground)
                    // Where they end up, for the figure to know how far what
                    // it draws reaches: on the words themselves, since words
                    // hung off a point lie outside the point they hang from.
                    .anchorPreference(key: LabelBoundsPreference.self, value: .bounds) { [$0] }

                Group {
                    if let side = route.labelSide {
                        // A point with nothing in it, the words hung off its
                        // edge on that side: they keep clear of the line
                        // however long or short they come out. Fixed in size,
                        // since an overlay offers them the point's no room.
                        Color.clear
                            .frame(width: 0, height: 0)
                            .overlay(alignment: Self.alignment(away: side)) { words.fixedSize() }
                            .position(
                                x: point.x + side.dx * style.labelPadding,
                                y: point.y + side.dy * style.labelPadding
                            )
                    }
                    else {
                        words.position(point)
                    }
                }
                .opacity(labelShown(at: point, along: own))
            }
        }
        .opacity(style.appear == .fade ? appeared : 1)
    }

    /// The edge of the words that goes against a point, for them to lie on
    /// `side` of it.
    private static func alignment(away side: CGVector) -> Alignment {
        if side.dx > 0 { return .leading }
        if side.dx < 0 { return .trailing }
        return side.dy > 0 ? .top : .bottom
    }

    @ViewBuilder
    private func arrowHead(at tip: CGPoint, from: CGPoint) -> some View {
        // An outline is stroked centred on its path, so its rounded tip
        // reaches half a width past the point it is drawn to. Drawn that much
        // short, it ends where a filled head would.
        let drawnTip = pulled(tip, towards: from, by: width / 2)

        switch style.arrowHead.shape {
        case .filled:
            ArrowHeadShape(tip: tip, from: from, size: head, closed: true)
                .fill(style.color)

        case .hollow:
            ArrowHeadShape(tip: drawnTip, from: from, size: head, closed: true)
                .stroke(style.color, style: StrokeStyle(lineWidth: width, lineJoin: .round))

        case .open:
            ArrowHeadShape(tip: drawnTip, from: from, size: head, closed: false)
                .stroke(style.color, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
    }
}

private extension LineView {
    /// How far short of a tipped end the stroke stops.
    ///
    /// A stroke ends square across its full width. Run up to the point of a
    /// filled head it pokes out either side, so it stops halfway in, where the
    /// head is still twice the line's width. A hollow head must not have the
    /// line showing inside it, so the stroke stops at its base. An open head
    /// is two strokes meeting at a point, and the line meets them there.
    var inset: CGFloat {
        switch style.arrowHead.shape {
        case .filled: head / 2
        case .hollow: width / 2 + head
        case .open: width / 2
        }
    }

    /// As much of the line as has appeared.
    ///
    /// A line that is drawn in grows from where it leaves, and is cut short at
    /// the tip rather than trimmed as a shape, so that everything which reads
    /// the end of the line — the arrowhead, and the stroke stopping short of
    /// it — finds it at the tip as the tip moves.
    func shown(_ points: [CGPoint]) -> [CGPoint] {
        guard style.appear == .draw, appeared < 1 else {
            return points
        }
        return points.keeping(points.length * appeared)
    }

    /// How much of the label shows, given how far the line has been drawn.
    ///
    /// None until the tip reaches it, so the words never hang in the air
    /// ahead of the line, then quickly all of it once the tip is past.
    func labelShown(at point: CGPoint, along points: [CGPoint]) -> CGFloat {
        guard style.appear == .draw, appeared < 1 else {
            return 1
        }
        let drawn = points.length * appeared
        let passed = drawn - points.distance(alongTo: point)
        let fade = style.labelFontSize * 2
        return Swift.min(Swift.max(passed / fade, 0), 1)
    }

    /// The points this branch draws itself, leaving out the stretch an earlier
    /// branch of the same line draws instead.
    ///
    /// It sets off from that stretch a corner's radius early, so a rounded
    /// corner where it leaves the trunk curves off the trunk rather than
    /// starting beside it. Square corners have no radius, and it sets off from
    /// the very point the route turns at.
    func ownPart(of points: [CGPoint]) -> [CGPoint] {
        guard let overlap = route.drawnElsewhere else {
            return points
        }

        let cut = Swift.max(overlap.length - style.cornerRadius, 0)
        return overlap.atStart ? points.dropping(cut) : Array(Array(points.reversed()).dropping(cut).reversed())
    }

    /// Where an arrowhead at the last point is aimed from: as far back along
    /// the line as the head is long, unless the line turns a corner first.
    ///
    /// Not simply the point before the last, which on a curve is so close
    /// that it gives the direction at the very tip: a curve still turning
    /// there would have the head pointing one way and the line meeting its
    /// base from another. A corner is different, and a head just past one
    /// points along the run it is on.
    func heading(into points: [CGPoint]) -> CGPoint {
        points[approach(into: points)]
    }

    /// The index of the point ``heading(into:)`` aims from.
    func approach(into points: [CGPoint]) -> Int {
        var travelled = points[points.count - 1].distance(to: points[points.count - 2])
        var index = points.count - 2
        while travelled < head, index > 0 {
            let next = points[index - 1]
            let turn = abs(angle(from: points[index], to: points[index + 1]) - angle(from: next, to: points[index]))
            // Gentler than this from one point to the next is a curve.
            guard Swift.min(turn, 2 * .pi - turn) < .pi / 12 else {
                break
            }
            travelled += next.distance(to: points[index])
            index -= 1
        }
        return index
    }

    private func angle(from start: CGPoint, to end: CGPoint) -> CGFloat {
        atan2(end.y - start.y, end.x - start.x)
    }

    /// The points the stroke runs through, stopped short of any arrowhead.
    func stroked(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 2 else {
            return points
        }

        var points = points
        if route.arrow.tipsEnd {
            points = stoppedShort(points)
        }
        if route.arrow.tipsStart {
            points = Array(stoppedShort(Array(points.reversed())).reversed())
        }
        return points
    }

    /// `points`, stopped short of an arrowhead at the last of them.
    ///
    /// The head is aimed from as far back as it is long, and inside it the
    /// stroke runs straight along that aim rather than following the line: a
    /// curve still turning there would wander off the middle of the head, and
    /// its square end, set across the curve rather than the head, would poke
    /// out of one side.
    private func stoppedShort(_ points: [CGPoint]) -> [CGPoint] {
        let tip = points[points.count - 1]
        let index = approach(into: points)
        let from = points[index]
        guard from.distance(to: tip) > inset else {
            // A corner closer to the tip than the stroke stops: cut back
            // along the line, round the corner if need be.
            return points.keeping(Swift.max(points.length - inset, 0))
        }
        return Array(points[...index]) + [pulled(tip, towards: from, by: inset)]
    }

    /// `point`, moved `distance` towards `target` but never past it.
    func pulled(_ point: CGPoint, towards target: CGPoint, by distance: CGFloat) -> CGPoint {
        let dx = target.x - point.x
        let dy = target.y - point.y
        let length = (dx * dx + dy * dy).squareRoot()
        guard length > 0 else {
            return point
        }
        let step = min(distance, length) / length
        return CGPoint(x: point.x + dx * step, y: point.y + dy * step)
    }
}

private extension Path {
    /// Lines through `points`, eased round each corner by up to `radius`.
    ///
    /// Each corner gets as much of the runs either side of it as it can have
    /// without taking any from the next corner: a run between two corners is
    /// split between them, and a run to an end of the line belongs wholly to
    /// the one corner it has.
    mutating func addRoundedLines(_ points: [CGPoint], radius: CGFloat) {
        guard radius > 0, points.count > 2 else {
            addLines(points)
            return
        }

        move(to: points[0])
        for index in 1..<(points.count - 1) {
            let before = points[index].distance(to: points[index - 1])
            let after = points[index].distance(to: points[index + 1])
            let room = Swift.min(
                index == 1 ? before : before / 2,
                index == points.count - 2 ? after : after / 2
            )
            // An arc leaves the run as far from the corner as the radius over
            // the tangent of half the angle inside the corner — exactly the
            // radius at a right angle, further at a sharper turn. So the room
            // caps that distance, not the radius itself.
            let inside = angle(at: points[index], between: points[index - 1], and: points[index + 1])
            let rounding = Swift.min(radius, room * tan(inside / 2))
            if rounding > 0.01 {
                addArc(tangent1End: points[index], tangent2End: points[index + 1], radius: rounding)
            }
            else {
                addLine(to: points[index])
            }
        }
        addLine(to: points[points.count - 1])
    }

    /// The angle at `corner` between the runs to `before` and to `after`.
    private func angle(at corner: CGPoint, between before: CGPoint, and after: CGPoint) -> CGFloat {
        let one = atan2(before.y - corner.y, before.x - corner.x)
        let other = atan2(after.y - corner.y, after.x - corner.x)
        let difference = abs(one - other)
        return difference > .pi ? 2 * .pi - difference : difference
    }
}

/// A triangle at `tip`, pointing away from `from` — or, left open, just the
/// two sides that meet at the tip.
private struct ArrowHeadShape: Shape {
    let tip: CGPoint
    let from: CGPoint
    let size: CGFloat
    let closed: Bool

    func path(in rect: CGRect) -> Path {
        let dx = tip.x - from.x
        let dy = tip.y - from.y
        let length = (dx * dx + dy * dy).squareRoot()

        var path = Path()
        guard length > 0 else {
            return path
        }

        // Unit vector along the line, and its perpendicular.
        let ux = dx / length
        let uy = dy / length
        let base = CGPoint(x: tip.x - ux * size, y: tip.y - uy * size)
        let half = size * 0.4
        let left = CGPoint(x: base.x - uy * half, y: base.y + ux * half)
        let right = CGPoint(x: base.x + uy * half, y: base.y - ux * half)

        if closed {
            path.move(to: tip)
            path.addLine(to: left)
            path.addLine(to: right)
            path.closeSubpath()
        }
        else {
            path.move(to: left)
            path.addLine(to: tip)
            path.addLine(to: right)
        }
        return path
    }
}
