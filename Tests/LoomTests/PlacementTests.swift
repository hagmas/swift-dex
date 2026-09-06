import XCTest

@testable import Loom

private extension NodeID {
    static let first = NodeID("first")
    static let second = NodeID("second")
    static let third = NodeID("third")
}

private struct OffsetFigure: Figure {
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
}

final class PlacementTests: XCTestCase {
    func test_theTreeKeepsItsShape() {
        XCTAssertEqual(
            OffsetFigure().arrangement.placements,
            [
                .group(
                    .vertical,
                    [
                        .group(.horizontal, [.node(.first), .node(.second)]),
                        .group(.horizontal, [.gap, .node(.third)]),
                    ]
                )
            ]
        )
    }

    func test_aGapHoldsItsPositionWithoutBeingANode() {
        let paths = Placement.paths(in: OffsetFigure().arrangement.placements)
        let second = try? XCTUnwrap(paths[.second])
        let third = try? XCTUnwrap(paths[.third])

        // `third` follows an `Empty`, so it sits second in its row, lining up
        // under `second` rather than under `first`.
        XCTAssertEqual(second?.last?.index, 1)
        XCTAssertEqual(third?.last?.index, 1)
    }

    func test_everyNodeIsReachable() {
        let paths = Placement.paths(in: OffsetFigure().arrangement.placements)

        XCTAssertEqual(Set(paths.keys), [.first, .second, .third])
    }
}
