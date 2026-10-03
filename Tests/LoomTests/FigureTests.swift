import XCTest

@testable import Loom

private extension NodeID {
    static let first = NodeID("first")
    static let second = NodeID("second")
    static let third = NodeID("third")
    static let absent = NodeID("absent")
}

private struct WellFormedFigure: Figure {
    var arrangement: some FigureElement {
        Column {
            Row {
                Box(.first, title: "First")
                Box(.second, title: "Second")
            }
            Row {
                Empty()
                Box(.third, title: "Third")
            }
        }
    }

    var lines: [Line] {
        Line(from: .first, to: .third)
        Line(from: .second, to: .third)
    }
}

private struct FigureWithADuplicate: Figure {
    var arrangement: some FigureElement {
        Row {
            Box(.first, title: "First")
            Box(.first, title: "First again")
        }
    }
}

private struct FigureWithADanglingLine: Figure {
    var arrangement: some FigureElement {
        Row {
            Box(.first, title: "First")
        }
    }

    var lines: [Line] {
        Line(from: .first, to: .absent)
    }
}

final class FigureTests: XCTestCase {
    func test_nodeIDs_areCollectedInArrangementOrder() {
        XCTAssertEqual(
            WellFormedFigure().nodeIDs,
            [.first, .second, .third]
        )
    }

    func test_emptyDoesNotCountAsANode() {
        XCTAssertFalse(WellFormedFigure().nodeIDs.contains(NodeID("")))
        XCTAssertEqual(WellFormedFigure().nodeIDs.count, 3)
    }

    func test_aWellFormedFigureHasNoIssues() {
        XCTAssertEqual(WellFormedFigure().issues(), [])
    }

    func test_aRepeatedIdentityIsReported() {
        XCTAssertEqual(
            FigureWithADuplicate().issues(),
            [.duplicateNodeID(.first)]
        )
    }

    func test_aLineToAMissingNodeIsNotAMistake() {
        // It is simply not drawn. Which node the arrangement holds is a
        // question about what the figure is showing, not about whether it is
        // well formed — and the figure may well be showing it a moment later.
        XCTAssertEqual(FigureWithADanglingLine().issues(), [])
    }

    func test_aFigureWithoutLinesIsAllowed() {
        XCTAssertEqual(FigureWithADuplicate().lines.count, 0)
    }
}
