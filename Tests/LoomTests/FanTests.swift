import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let top = NodeID("top")
    static let left = NodeID("left")
    static let right = NodeID("right")
    static let absent = NodeID("absent")
}

/// One node above two, whatever lines are asked for between them.
private struct Tree: Figure {
    let lines: [Line]

    var arrangement: some FigureElement {
        Column {
            Row { Box(.top, title: "Top") }
            Row {
                Box(.left, title: "Left")
                Box(.right, title: "Right")
            }
        }
    }
}

private let rects: [NodeID: CGRect] = [
    // Bottom edge at (150, 50).
    .top: CGRect(x: 100, y: 0, width: 100, height: 50),
    // Top edges at (50, 150) and (250, 150).
    .left: CGRect(x: 0, y: 150, width: 100, height: 50),
    .right: CGRect(x: 200, y: 150, width: 100, height: 50),
]

private func routes(_ lines: [Line]) -> [RoutedLine] {
    let figure = Tree(lines: lines)
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

final class FanTests: XCTestCase {
    /// One line out to two nodes leaves as a single trunk and splits where it
    /// turns.
    func test_aFanLeavesAsOneTrunk() {
        let drawn = routes([Line(from: .top, to: .left, .right)])

        XCTAssertEqual(drawn.count, 2)
        XCTAssertEqual(
            drawn[0].points,
            [CGPoint(x: 150, y: 50), CGPoint(x: 150, y: 100), CGPoint(x: 50, y: 100), CGPoint(x: 50, y: 150)]
        )
        // The second branch starts where it leaves the first, so the trunk is
        // drawn once and a dashed line keeps its dashes.
        XCTAssertEqual(
            drawn[1].points,
            [CGPoint(x: 150, y: 100), CGPoint(x: 250, y: 100), CGPoint(x: 250, y: 150)]
        )
    }

    /// The same two connections written as two lines are two relationships,
    /// and are held apart where they leave.
    func test_separateLinesStayApart() {
        let drawn = routes([Line(from: .top, to: .left), Line(from: .top, to: .right)])

        XCTAssertEqual(drawn.map { $0.points[0] }, [CGPoint(x: 145, y: 50), CGPoint(x: 155, y: 50)])
    }

    /// Several nodes into one meet at a single point, under one arrowhead.
    func test_aGatheringArrivesAsOneTrunk() {
        let drawn = routes([Line(from: .left, .right, to: .top)])

        XCTAssertEqual(drawn[0].points.last, CGPoint(x: 150, y: 50))
        XCTAssertEqual(drawn[0].arrow, .end)

        // The second branch stops where it joins the first, and leaves the
        // arrowhead to it.
        XCTAssertEqual(drawn[1].points.last, CGPoint(x: 150, y: 100))
        XCTAssertEqual(drawn[1].arrow, .none)
    }

    /// The words belong to the line, so they are written once, on the trunk.
    func test_aFanIsLabelledOnceOnItsTrunk() {
        let drawn = routes([Line(from: .top, to: .left, .right, label: "owns")])

        XCTAssertEqual(drawn.compactMap(\.label), ["owns"])
        XCTAssertEqual(drawn.compactMap(\.labelPoint), [CGPoint(x: 150, y: 75)])
    }

    /// The trunk of a gathering is at its far end, and so are its words.
    func test_aGatheringIsLabelledOnItsTrunk() {
        let drawn = routes([Line(from: .left, .right, to: .top, label: "is a")])

        XCTAssertEqual(drawn.compactMap(\.labelPoint), [CGPoint(x: 150, y: 75)])
    }

    /// A branch to a node that is not there is dropped on its own, so a fan
    /// can grow a branch at a time.
    func test_aMissingBranchLeavesTheRest() {
        let drawn = routes([Line(from: .top, to: .left, .absent)])

        XCTAssertEqual(drawn.count, 1)
        XCTAssertEqual(drawn[0].points.last, CGPoint(x: 50, y: 150))
    }
}
