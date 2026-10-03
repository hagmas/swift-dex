import XCTest

@testable import Loom

private extension NodeID {
    static let first = NodeID("first")
    static let second = NodeID("second")
    static let third = NodeID("third")
}

private struct Growing: Figure {
    var showsSecond: Bool

    var arrangement: some FigureElement {
        Column {
            Row { Box(.first, title: "First") }
            if showsSecond {
                Row { Box(.second, title: "Second") }
            }
            Row { Box(.third, title: "Third") }
        }
    }

    var lines: [Line] {
        if showsSecond {
            Line(from: .first, to: .second)
            Line(from: .second, to: .third)
        }
        else {
            Line(from: .first, to: .third)
        }
    }
}

private struct Either: Figure {
    var swapped: Bool

    var arrangement: some FigureElement {
        Row {
            if swapped {
                Box(.second, title: "Second")
            }
            else {
                Box(.first, title: "First")
            }
        }
    }
}

final class ConditionalTests: XCTestCase {
    func test_whatTheIfReachedIsThere() {
        XCTAssertEqual(Growing(showsSecond: true).nodeIDs, [.first, .second, .third])
    }

    func test_whatItDidNotReachIsNotThere() {
        XCTAssertEqual(Growing(showsSecond: false).nodeIDs, [.first, .third])
    }

    func test_anAbsentElementLeavesNoGap() {
        // The arrangement closes up: `third` moves into the row that `second`
        // was going to take, rather than sitting below a hole.
        let shown = Placement.addresses(in: Growing(showsSecond: true).arrangement.placements)
        let hidden = Placement.addresses(in: Growing(showsSecond: false).arrangement.placements)

        // The step before the last is the row's place in the column.
        XCTAssertEqual(shown[.third]?.dropLast().last?.index, 2)
        XCTAssertEqual(hidden[.third]?.dropLast().last?.index, 1)
    }

    func test_linesFollowTheSameCondition() {
        XCTAssertEqual(Growing(showsSecond: true).lines.count, 2)
        XCTAssertEqual(Growing(showsSecond: false).lines.count, 1)
    }

    func test_bothBranchesOfAnElse() {
        XCTAssertEqual(Either(swapped: false).nodeIDs, [.first])
        XCTAssertEqual(Either(swapped: true).nodeIDs, [.second])
    }

    func test_aFigureThatChangesStaysWellFormed() {
        XCTAssertEqual(Growing(showsSecond: true).issues(), [])
        XCTAssertEqual(Growing(showsSecond: false).issues(), [])
    }
}
