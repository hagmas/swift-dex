import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let one = NodeID("one")
    static let two = NodeID("two")
}

private struct Pair<Lines: Sequence<Line>>: Figure {
    let drawn: Lines

    var arrangement: some FigureElement {
        Column {
            Row { Box(.one, title: "One") }
            Row { Box(.two, title: "Two") }
        }
    }

    var lines: [Line] { Array(drawn) }
}

private let rects: [NodeID: CGRect] = [
    .one: CGRect(x: 100, y: 0, width: 100, height: 50),
    .two: CGRect(x: 100, y: 150, width: 100, height: 50),
]

private func routes(routing: Line.Routing = .orthogonal, _ lines: Line...) -> [RoutedLine] {
    let figure = Pair(drawn: lines)
    let placements = figure.arrangement.placements
    return LineRouter.routes(
        for: figure.lines,
        rects: rects,
        addresses: Placement.addresses(in: placements),
        waypointAxes: Placement.waypointAxes(in: placements),
        routing: routing,
        spacing: 10
    )
}

final class SelfLoopTests: XCTestCase {
    func test_aLoopHangsOffTheSideItNames() {
        // `one` spans x 100...200, y 0...50, so its trailing side is at x = 200
        // and its middle at y = 25. The loop takes three fifths of the node's
        // shorter side — 30 of its 50 — and reaches as far out as it is tall.
        let points = routes(Line(looping: .one.trailing))[0].points

        XCTAssertEqual(
            points,
            [
                CGPoint(x: 200, y: 10),
                CGPoint(x: 230, y: 10),
                CGPoint(x: 230, y: 40),
                CGPoint(x: 200, y: 40),
            ]
        )
    }

    func test_aLoopCanHangOffAnySide() {
        let points = routes(Line(looping: .one.bottom))[0].points

        XCTAssertEqual(
            points,
            [
                CGPoint(x: 135, y: 50),
                CGPoint(x: 135, y: 80),
                CGPoint(x: 165, y: 80),
                CGPoint(x: 165, y: 50),
            ]
        )
    }

    func test_aLoopNeverLeavesTheNodeItHangsOff() {
        for side in [NodeID.one.top, .one.bottom, .one.leading, .one.trailing] {
            let points = routes(Line(looping: side))[0].points
            let box = rects[.one]!

            for point in points where box.insetBy(dx: 0.01, dy: 0.01).contains(point) {
                XCTFail("\(side) put \(point) inside the node")
            }
        }
    }

    func test_aLoopGoesRoundEvenWhenTheFigureIsStraight() {
        // There is no straight reading of coming back to where you started.
        let round = routes(routing: .orthogonal, Line(looping: .one.trailing))[0].points
        let straight = routes(routing: .straight, Line(looping: .one.trailing))[0].points

        XCTAssertEqual(straight, round)
    }

    func test_aLoopComesOutTheSameWayEveryTime() {
        // Both ends of a loop are headed the same way, so nothing but the
        // tie-break decides which of them takes the near lane.
        let drawn = (0..<20).map { _ in routes(Line(looping: .one.trailing))[0].points }

        XCTAssertEqual(Set(drawn.map(\.description)).count, 1)
    }

    func test_aLoopKeepsItsSpanWhenAnotherLineSharesTheSide() {
        // Lanes separate ends that would land on the same point. The loop's two
        // already sit apart, so the line leaving for elsewhere takes the middle
        // between them rather than pushing them outwards.
        let drawn = routes(
            Line(looping: .one.trailing),
            Line(from: .one.trailing, to: .two)
        )
        let onTheSide = drawn.flatMap(\.points).filter { $0.x == 200 }

        XCTAssertEqual(Set(onTheSide.map(\.y)), [10, 25, 40])
    }

    func test_endsThatWouldLandTogetherStillTakeLanes() {
        let drawn = routes(
            Line(from: .one.trailing, to: .two),
            Line(from: .one.trailing, to: .two.leading)
        )
        let onTheSide = drawn.map(\.points[0])

        XCTAssertEqual(Set(onTheSide.map(\.y)), [20, 30])
    }

    func test_aLoopThatNamesNoSideIsReported() {
        XCTAssertEqual(
            Pair(drawn: [Line(from: .one, to: .one)]).issues(),
            [.loopWithoutASide(.one)]
        )
    }

    func test_aLoopAcrossTwoSidesIsReported() {
        XCTAssertEqual(
            Pair(drawn: [Line(from: .one.trailing, to: .one.leading)]).issues(),
            [.loopWithoutASide(.one)]
        )
    }

    func test_aLoopOnOneSideIsNotAMistake() {
        XCTAssertEqual(Pair(drawn: [Line(looping: .one.trailing)]).issues(), [])
    }

    func test_aLineBetweenTwoNodesIsNotALoop() {
        XCTAssertEqual(Pair(drawn: [Line(from: .one, to: .two)]).issues(), [])
    }
}
