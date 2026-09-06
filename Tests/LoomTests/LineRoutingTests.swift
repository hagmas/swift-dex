import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let source = NodeID("source")
    static let below = NodeID("below")
    static let offset = NodeID("offset")
    static let tie = NodeID("tie")
}

/// One line, straight down onto a node that sits off to the left.
private struct Descent: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { Box(.source, title: "Source") }
            Row { Box(.offset, title: "Offset") }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .offset, label: "owns")
    }
}

/// One line onto a node directly underneath, so the turns have nothing to do.
private struct Aligned: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { Box(.source, title: "Source") }
            Row { Box(.below, title: "Below") }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .below)
    }
}

/// One line through a tie, which faces across the edge it sets off from.
private struct Detour: Figure {
    var arrangement: some FigureElement {
        Column {
            Row {
                Box(.source, title: "Source")
                Tie(.tie, axis: .vertical)
            }
            Row { Box(.offset, title: "Offset") }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .offset, through: .tie)
    }
}

private let rects: [NodeID: CGRect] = [
    // Bottom edge at (150, 50).
    .source: CGRect(x: 100, y: 0, width: 100, height: 50),
    // Top edge at (150, 150) — directly below.
    .below: CGRect(x: 100, y: 150, width: 100, height: 50),
    // Top edge at (50, 150) — off to the left.
    .offset: CGRect(x: 0, y: 150, width: 100, height: 50),
    .tie: CGRect(x: 260, y: 25, width: 0, height: 0),
]

private func routes(_ figure: some Figure, routing: LineRouting) -> [RoutedLine] {
    let placements = figure.arrangement.placements
    return LineRouter.routes(
        for: figure.lines,
        rects: rects,
        addresses: Placement.addresses(in: placements),
        tieAxes: Placement.tieAxes(in: placements),
        routing: routing,
        spacing: 10
    )
}

private func isAxisAligned(_ points: [CGPoint]) -> Bool {
    zip(points, points.dropFirst()).allSatisfy {
        abs($0.x - $1.x) < 0.01 || abs($0.y - $1.y) < 0.01
    }
}

final class LineRoutingTests: XCTestCase {
    func test_straightRoutingJoinsTheEndsDirectly() {
        let points = routes(Descent(), routing: .straight)[0].points

        XCTAssertEqual(points, [CGPoint(x: 150, y: 50), CGPoint(x: 50, y: 150)])
    }

    func test_orthogonalRoutingStepsAcrossHalfway() {
        let points = routes(Descent(), routing: .orthogonal)[0].points

        // Down from the source, across at the midpoint between the two rows,
        // then down onto the target.
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

    func test_orthogonalRoutingOnlyEverTurnsAtRightAngles() {
        for figure in [routes(Descent(), routing: .orthogonal), routes(Detour(), routing: .orthogonal)] {
            XCTAssertTrue(isAxisAligned(figure[0].points))
        }
    }

    func test_turnsCollapseWhenTheEndsAlreadyLineUp() {
        let points = routes(Aligned(), routing: .orthogonal)[0].points

        XCTAssertEqual(points, [CGPoint(x: 150, y: 50), CGPoint(x: 150, y: 150)])
    }

    func test_aLineCanOverrideTheFiguresRouting() {
        struct Stubborn: Figure {
            var arrangement: some FigureElement {
                Column {
                    Row { Box(.source, title: "Source") }
                    Row { Box(.offset, title: "Offset") }
                }
            }
            var lines: [Line] {
                Line(from: .source, to: .offset, routing: .straight)
            }
        }

        XCTAssertEqual(routes(Stubborn(), routing: .orthogonal)[0].points.count, 2)
    }

    func test_theLabelIsCarriedThroughToTheDrawing() {
        XCTAssertEqual(routes(Descent(), routing: .straight)[0].label, "owns")
        XCTAssertNil(routes(Aligned(), routing: .straight)[0].label)
    }
}

final class PolylineTests: XCTestCase {
    func test_repeatedPointsAreDropped() {
        let points = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10)]

        XCTAssertEqual(points.simplified, [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10)])
    }

    func test_aPointInTheMiddleOfAStraightRunIsDropped() {
        // An arrowhead reads the last two points to find its direction, so a
        // redundant point is not merely untidy.
        let points = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 5), CGPoint(x: 0, y: 10)]

        XCTAssertEqual(points.simplified, [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10)])
    }

    func test_aRealCornerIsKept() {
        let points = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10), CGPoint(x: 10, y: 10)]

        XCTAssertEqual(points.simplified, points)
    }

    func test_theMiddleIsMeasuredAlongTheLine() {
        // An L of 10 down and 30 across: halfway by distance is 20 along, which
        // is on the long arm, not at the corner.
        let points = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10), CGPoint(x: 30, y: 10)]

        XCTAssertEqual(points.middle, CGPoint(x: 10, y: 10))
    }

    func test_aSinglePointIsItsOwnMiddle() {
        XCTAssertEqual([CGPoint(x: 3, y: 4)].middle, CGPoint(x: 3, y: 4))
    }
}
