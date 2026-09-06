import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let top = NodeID("top")
    static let middle = NodeID("middle")
    static let left = NodeID("left")
    static let right = NodeID("right")
}

/// ```
///          [ top ]
///          [ middle ]
/// [ left ]          [ right ]
/// ```
private struct Stacked: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { Box(.top, title: "Top") }
            Row { Box(.middle, title: "Middle") }
            Row {
                Box(.left, title: "Left")
                Box(.right, title: "Right")
            }
        }
    }
}

final class LineRouterTests: XCTestCase {
    private func edges(
        _ figure: some Figure,
        from: NodeID,
        to: NodeID
    ) throws -> (start: NodeEdge, end: NodeEdge) {
        let addresses = Placement.addresses(in: figure.arrangement.placements)
        return try XCTUnwrap(LineRouter.edges(from: from, to: to, addresses: addresses))
    }

    func test_nodesInTheSameRow_joinSideToSide() throws {
        let edges = try edges(Stacked(), from: .left, to: .right)

        XCTAssertEqual(edges.start, .trailing)
        XCTAssertEqual(edges.end, .leading)
    }

    func test_nodesInDifferentRows_joinBottomToTop() throws {
        let edges = try edges(Stacked(), from: .top, to: .middle)

        XCTAssertEqual(edges.start, .bottom)
        XCTAssertEqual(edges.end, .top)
    }

    func test_aLineDrawnUpwardsLeavesTheTopEdge() throws {
        let edges = try edges(Stacked(), from: .middle, to: .top)

        XCTAssertEqual(edges.start, .top)
        XCTAssertEqual(edges.end, .bottom)
    }

    func test_aNodeOffToTheSideOfTheRowBelowStillJoinsBottomToTop() throws {
        // `middle` is centred and `right` sits off to the right, so the
        // geometrically shortest run leaves `middle`'s flank. The rows are what
        // the line means, though, so it goes down.
        let edges = try edges(Stacked(), from: .middle, to: .right)

        XCTAssertEqual(edges.start, .bottom)
        XCTAssertEqual(edges.end, .top)
    }

    func test_anUnknownNodeHasNoEdges() {
        let addresses = Placement.addresses(in: Stacked().arrangement.placements)

        XCTAssertNil(LineRouter.edges(from: .top, to: NodeID("absent"), addresses: addresses))
    }

    func test_edgeMidpoints() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)

        XCTAssertEqual(NodeEdge.top.point(in: rect), CGPoint(x: 60, y: 20))
        XCTAssertEqual(NodeEdge.bottom.point(in: rect), CGPoint(x: 60, y: 70))
        XCTAssertEqual(NodeEdge.leading.point(in: rect), CGPoint(x: 10, y: 45))
        XCTAssertEqual(NodeEdge.trailing.point(in: rect), CGPoint(x: 110, y: 45))
    }
}
