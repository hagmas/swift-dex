import XCTest

@testable import Loom

private extension NodeID {
    static let first = NodeID("first")
    static let second = NodeID("second")
    static let third = NodeID("third")
}

private struct StyledFigure: Figure {
    var arrangement: some FigureElement {
        Column {
            Row {
                TextNode(.first, title: "First")
                    .nodeStyle(NodeStyle(fill: .blue))
                TextNode(.second, title: "Second")
            }
            .nodeStyle(NodeStyle(fill: .orange))
            Row {
                Empty()
                TextNode(.third, title: "Third")
            }
        }
    }
}

final class NodeStyleTests: XCTestCase {
    /// A style is how a node looks, not where it is or what it is called, so
    /// styling an element leaves the arrangement exactly as it was.
    func test_aStyleLeavesTheTreeAlone() {
        XCTAssertEqual(
            StyledFigure().arrangement.placements,
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
}
