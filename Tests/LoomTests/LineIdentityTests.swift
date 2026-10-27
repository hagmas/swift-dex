import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let top = NodeID("top")
    static let left = NodeID("left")
    static let right = NodeID("right")
    static let gap = NodeID("gap")
}

/// One node above two, with a waypoint beside them, whatever lines are asked
/// for between them.
private struct Tree: Figure {
    let lines: [Line]

    var arrangement: some FigureElement {
        Column {
            Row {
                TextNode(.top, title: "Top")
                Waypoint(.gap)
            }
            Row {
                TextNode(.left, title: "Left")
                TextNode(.right, title: "Right")
            }
        }
    }
}

private let rects: [NodeID: CGRect] = [
    .top: CGRect(x: 100, y: 0, width: 100, height: 50),
    .gap: CGRect(x: 300, y: 25, width: 0, height: 0),
    .left: CGRect(x: 0, y: 150, width: 100, height: 50),
    .right: CGRect(x: 200, y: 150, width: 100, height: 50),
]

private func ids(_ lines: [Line]) -> [DrawnLineID] {
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
    .map(\.id)
}

final class LineIdentityTests: XCTestCase {
    /// A line written ahead of another does not make the other a new line,
    /// which numbering them in order would.
    func test_aLineAddedAheadLeavesTheRestAlone() {
        let before = ids([Line(from: .top, to: .right)])
        let after = ids([Line(from: .top, to: .left), Line(from: .top, to: .right)])

        XCTAssertEqual(after.last, before.first)
    }

    /// A fan that gains a branch keeps the branches it had.
    func test_aFanThatGrowsKeepsItsBranches() {
        let before = ids([Line(from: .top, to: .left)])
        let after = ids([Line(from: .top, to: .left, .right)])

        XCTAssertEqual(after.first, before.first)
        XCTAssertEqual(after.count, 2)
    }

    /// Going round by another way is another line.
    func test_aDifferentRouteIsADifferentLine() {
        let direct = ids([Line(from: .top, to: .right)])
        let detour = ids([Line(from: .top, to: .right, through: .gap)])

        XCTAssertNotEqual(direct, detour)
    }

    /// Two lines over one route with different words on them are two lines.
    func test_labelsTellARouteSharedApart() {
        let lines = [
            Line(from: .top, to: .right, label: "timeout"),
            Line(from: .top, to: .right, label: "error"),
        ]

        XCTAssertEqual(Set(ids(lines)).count, 2)
        XCTAssertEqual(Tree(lines: lines).issues(), [])
    }

    /// Two lines nothing tells apart are reported, and still drawn without
    /// colliding.
    func test_linesNothingTellsApartAreReported() {
        let lines = [Line(from: .top, to: .right), Line(from: .top, to: .right)]

        XCTAssertEqual(Tree(lines: lines).issues(), [.indistinguishableLines([.top, .right])])
        XCTAssertEqual(Set(ids(lines)).count, 2)
    }

    /// A name settles it, and a named line keeps its identity when its words
    /// change.
    func test_aNamedLineIsKnownByItsName() {
        let lines = [Line(from: .top, to: .right), Line(from: .top, to: .right, id: "backup")]

        XCTAssertEqual(Tree(lines: lines).issues(), [])
        XCTAssertEqual(
            ids([Line(from: .top, to: .right, label: "old", id: "backup")]),
            ids([Line(from: .top, to: .right, label: "new", id: "backup")])
        )
    }
}
