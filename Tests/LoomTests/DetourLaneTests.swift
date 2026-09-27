import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let top = NodeID("top")
    static let near = NodeID("near")
    static let far = NodeID("far")
    static let further = NodeID("further")
}

/// Four boxes in a column, all the same width, so every trailing side is at the
/// same x and a line leaving one for another has to go round the outside.
private struct Stack<Lines: Sequence<Line>>: Figure {
    let drawn: Lines

    var arrangement: some FigureElement {
        Column(spacing: 40) {
            Row { Box(.top, title: "Top") }
            Row { Box(.near, title: "Near") }
            Row { Box(.far, title: "Far") }
            Row { Box(.further, title: "Further") }
        }
    }

    var lines: [Line] { Array(drawn) }
}

private let rects: [NodeID: CGRect] = [
    .top: CGRect(x: 0, y: 0, width: 140, height: 40),
    .near: CGRect(x: 0, y: 80, width: 140, height: 40),
    .far: CGRect(x: 0, y: 160, width: 140, height: 40),
    .further: CGRect(x: 0, y: 240, width: 140, height: 40),
]

private func routes(_ lines: Line...) -> [RoutedLine] {
    let figure = Stack(drawn: lines)
    let placements = figure.arrangement.placements
    return LineRouter.routes(
        for: figure.lines,
        rects: rects,
        addresses: Placement.addresses(in: placements),
        waypointAxes: Placement.waypointAxes(in: placements),
        routing: .orthogonal,
        spacing: 10
    )
}

/// How far out from the trailing sides a route reaches.
private func reach(_ route: RoutedLine) -> CGFloat {
    (route.points.map(\.x).max() ?? 0) - 140
}

final class DetourLaneTests: XCTestCase {
    func test_oneDetourReachesOneLaneOut() {
        XCTAssertEqual(reach(routes(Line(from: .top.trailing, to: .near.trailing))[0]), 20)
    }

    func test_detoursLeavingTogetherStackOutwards() {
        let drawn = routes(
            Line(from: .top.trailing, to: .near.trailing),
            Line(from: .top.trailing, to: .far.trailing),
            Line(from: .top.trailing, to: .further.trailing)
        )

        XCTAssertEqual(drawn.map(reach), [20, 40, 60])
    }

    func test_theFurtherALineTravelsTheFurtherOutItGoes() {
        // Written nearest-last, so declaration order alone would nest them the
        // wrong way round and each returning line would cross the ones outside
        // it.
        let drawn = routes(
            Line(from: .top.trailing, to: .further.trailing),
            Line(from: .top.trailing, to: .near.trailing)
        )

        XCTAssertGreaterThan(reach(drawn[0]), reach(drawn[1]))
    }

    func test_detoursNeverShareADepth() {
        let drawn = routes(
            Line(from: .top.trailing, to: .near.trailing),
            Line(from: .top.trailing, to: .far.trailing),
            Line(from: .top.trailing, to: .further.trailing)
        )

        XCTAssertEqual(Set(drawn.map(reach)).count, drawn.count)
    }

    func test_sidesAreCountedSeparately() {
        // One line on each side: neither is in the other's way, so neither is
        // pushed out to make room.
        let drawn = routes(
            Line(from: .top.trailing, to: .near.trailing),
            Line(from: .top.leading, to: .near.leading)
        )

        XCTAssertEqual(reach(drawn[0]), 20)
        XCTAssertEqual(drawn[1].points.map(\.x).min(), -20)
    }
}
