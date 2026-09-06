import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let source = NodeID("source")
    static let left = NodeID("left")
    static let right = NodeID("right")
    static let tie = NodeID("tie")
}

/// ```
///      [ source ]
/// [ left ]  [ right ]
/// ```
private struct Fork: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { Box(.source, title: "Source") }
            Row {
                Box(.left, title: "Left")
                Box(.right, title: "Right")
            }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .right)
        Line(from: .source, to: .left)
    }
}

/// ```
/// [ source ] (tie)
/// [ left ]
/// ```
private struct Detour: Figure {
    var arrangement: some FigureElement {
        Column {
            Row {
                Box(.source, title: "Source")
                Tie(.tie)
            }
            Row { Box(.left, title: "Left") }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .left, through: .tie)
    }
}

private let rects: [NodeID: CGRect] = [
    .source: CGRect(x: 100, y: 0, width: 100, height: 50),
    .left: CGRect(x: 0, y: 150, width: 100, height: 50),
    .right: CGRect(x: 200, y: 150, width: 100, height: 50),
    .tie: CGRect(x: 250, y: 25, width: 0, height: 0),
]

private func routes(_ figure: some Figure, spacing: CGFloat = 10) -> [RoutedLine] {
    LineRouter.routes(
        for: figure.lines,
        rects: rects,
        paths: Placement.paths(in: figure.arrangement.placements),
        spacing: spacing
    )
}

final class LineBundlingTests: XCTestCase {
    func test_linesLeavingTheSameEdgeAreHeldApart() {
        let routes = routes(Fork())

        let departures = routes.map(\.points[0])
        XCTAssertEqual(Set(departures).count, 2, "both lines left from the same point")
    }

    func test_aBundleIsCentredOnTheEdge() {
        let routes = routes(Fork(), spacing: 20)

        // `source` spans x 100...200, so its bottom edge is at x = 150. Two
        // lines, twenty apart, sit either side of it.
        XCTAssertEqual(Set(routes.map(\.points[0].x)), [140, 160])
        XCTAssertEqual(Set(routes.map(\.points[0].y)), [50])
    }

    func test_aBundleIsOrderedByWhereEachLineIsHeaded() {
        // The lines are written right-then-left, so declaration order alone
        // would cross them.
        let routes = routes(Fork(), spacing: 20)
        let toRight = routes[0]
        let toLeft = routes[1]

        XCTAssertLessThan(toLeft.points[0].x, toRight.points[0].x)
    }

    func test_aLineThroughATieBendsAtIt() {
        let routes = routes(Detour())

        XCTAssertEqual(routes.count, 1)
        XCTAssertEqual(routes[0].points.count, 3)
        XCTAssertEqual(routes[0].points[1], CGPoint(x: 250, y: 25))
    }

    func test_aTiePassesTheLineThroughWithoutAKink() {
        // Arriving at a tie and leaving it is one point, not two, so a bundle
        // cannot pull the two halves apart.
        let routes = routes(Detour())

        XCTAssertEqual(routes[0].points.count, 3)
    }

    func test_aLineNamingAMissingNodeIsDropped() {
        struct Dangling: Figure {
            var arrangement: some FigureElement {
                Row { Box(.source, title: "Source") }
            }
            var lines: [Line] {
                Line(from: .source, to: NodeID("absent"))
            }
        }

        XCTAssertEqual(routes(Dangling()).count, 0)
    }
}

final class TieSpanTests: XCTestCase {
    func test_aTieCarryingOneLineIsAPoint() {
        let spans = TieSpans.spans(for: [Line(from: .source, to: .left, through: .tie)], spacing: 10)

        XCTAssertEqual(spans[.tie], 0)
    }

    func test_aTieWidensWithEveryExtraLine() {
        let lines = [
            Line(from: .source, to: .left, through: .tie),
            Line(from: .source, to: .right, through: .tie),
            Line(from: .left, to: .right, through: .tie),
        ]

        XCTAssertEqual(TieSpans.spans(for: lines, spacing: 10)[.tie], 20)
    }

    func test_aTieNoLineUsesHasNoSpan() {
        XCTAssertNil(TieSpans.spans(for: [Line(from: .source, to: .left)], spacing: 10)[.tie])
    }
}
