import XCTest

@testable import Loom

private extension NodeID {
    static let start = NodeID("start")
    static let fetch = NodeID("fetch")
    static let back = NodeID("back")
}

private struct Aligned: Figure {
    var arrangement: some FigureElement {
        Column(alignment: .columnSpine) {
            Row { Box(.start, title: "Start") }
            Row {
                Box(.fetch, title: "Fetch").aligned(on: .columnSpine)
                Waypoint(.back)
            }
        }
    }
}

final class SpineTests: XCTestCase {
    /// Lining a node up moves it, and nothing else: the arrangement keeps its
    /// shape, so lines still leave and arrive by the same sides.
    func test_aGuideLeavesTheTreeAlone() {
        XCTAssertEqual(
            Aligned().arrangement.placements,
            [
                .group(
                    .vertical,
                    [
                        .group(.horizontal, [.node(.start)]),
                        .group(.horizontal, [.node(.fetch), .waypoint(.back, .vertical)]),
                    ]
                )
            ]
        )
    }
}
