import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let above = NodeID("above")
    static let below = NodeID("below")
    static let beside = NodeID("beside")
    static let absent = NodeID("absent")
}

/// ```
///      [ above ]
/// [ below ] [ beside ]
/// ```
private struct Stacked<Lines: Sequence<Line>>: Figure {
    let drawn: Lines

    var arrangement: some FigureElement {
        Column {
            Row { Box(.above, title: "Above") }
            Row {
                Box(.below, title: "Below")
                Box(.beside, title: "Beside")
            }
        }
    }

    var lines: [Line] { Array(drawn) }
}

private let rects: [NodeID: CGRect] = [
    .above: CGRect(x: 100, y: 0, width: 100, height: 50),
    .below: CGRect(x: 0, y: 150, width: 100, height: 50),
    .beside: CGRect(x: 200, y: 150, width: 100, height: 50),
]

private func routes(routing: Line.Routing = .straight, _ lines: Line...) -> [RoutedLine] {
    let figure = Stacked(drawn: lines)
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

final class ExplicitAnchorTests: XCTestCase {
    func test_withoutOneTheArrangementDecides() {
        let points = routes(Line(from: .above, to: .below))[0].points

        // Different rows, so bottom to top.
        XCTAssertEqual(points, [CGPoint(x: 150, y: 50), CGPoint(x: 50, y: 150)])
    }

    func test_aNamedSideOverrulesTheArrangement() {
        let points = routes(Line(from: .above.trailing, to: .below.leading))[0].points

        XCTAssertEqual(points, [CGPoint(x: 200, y: 25), CGPoint(x: 0, y: 175)])
    }

    func test_oneEndMayBeNamedAndTheOtherLeftAlone() {
        let points = routes(Line(from: .above.trailing, to: .below))[0].points

        XCTAssertEqual(points[0], CGPoint(x: 200, y: 25), "the named end")
        XCTAssertEqual(points[1], CGPoint(x: 50, y: 150), "the end still worked out")
    }

    func test_aNamedSideAndOneMerelyArrivedAtAreTheSameBundle() {
        // `above`'s bottom is where the first line ends up anyway, so the two
        // are after the same place and must be held apart.
        let drawn = routes(
            Line(from: .above, to: .below),
            Line(from: .above.bottom, to: .beside)
        )

        let departures = drawn.map(\.points[0])
        XCTAssertEqual(Set(departures).count, 2, "both lines left from the same point")
        XCTAssertEqual(Set(departures.map(\.x)), [145, 155])
    }

    func test_aNamedSideIsNotThePlainIdentity() {
        XCTAssertNotEqual(NodeID.above, NodeID.above.top)
        XCTAssertNotEqual(NodeID.above.top, NodeID.above.bottom)
        XCTAssertEqual(NodeID.above.top.node, NodeID.above)
        XCTAssertEqual(NodeID.above.node, NodeID.above)
    }

    func test_aMissingNodeIsReportedByItsPlainIdentity() {
        let figure = Stacked(drawn: [Line(from: .above.bottom, to: .absent.top)])

        XCTAssertEqual(figure.issues(), [.lineToUnknownNode(.absent)])
    }

    func test_aNamedSideOnAKnownNodeIsNotAMistake() {
        let figure = Stacked(drawn: [Line(from: .above.bottom, to: .below.top)])

        XCTAssertEqual(figure.issues(), [])
    }

    func test_endsFacingTheSameWayGoRoundTheOutside() {
        // Both sides face right, so stepping across halfway between them would
        // run the line back through `below`.
        let points = routes(
            routing: .orthogonal,
            Line(from: .above.trailing, to: .below.trailing)
        )[0].points

        // Margin is twice the lane width, beyond whichever side reaches
        // further — here `above`'s, at x = 200.
        XCTAssertEqual(
            points,
            [
                CGPoint(x: 200, y: 25),
                CGPoint(x: 220, y: 25),
                CGPoint(x: 220, y: 175),
                CGPoint(x: 100, y: 175),
            ]
        )
    }

    func test_theDetourClearsBothNodes() {
        let points = routes(
            routing: .orthogonal,
            Line(from: .above.trailing, to: .below.trailing)
        )[0].points

        let furthest = points.map(\.x).max() ?? 0
        XCTAssertGreaterThan(furthest, rects[.above]!.maxX)
        XCTAssertGreaterThan(furthest, rects[.below]!.maxX)
    }

    func test_endsFacingEachOtherStillStepAcrossHalfway() {
        // Unchanged by the detour: these two do face each other.
        let points = routes(routing: .orthogonal, Line(from: .above, to: .below))[0].points

        XCTAssertEqual(
            points,
            [
                CGPoint(x: 150, y: 50),
                CGPoint(x: 150, y: 100),
                CGPoint(x: 50, y: 100),
                CGPoint(x: 50, y: 150),
            ]
        )
    }

    func test_aNodeDeclaredWithASideIsReported() {
        struct Sided: Figure {
            var arrangement: some FigureElement {
                Row { Box(.above.top, title: "Above") }
            }
        }

        XCTAssertEqual(Sided().issues(), [.nodeNamedWithASide(.above.top)])
    }
}
