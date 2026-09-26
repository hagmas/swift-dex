import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
}

/// A single joint on node A's bottom edge, headed towards a given x.
private func leavingBottom(_ line: Int, towards: CGFloat) -> Route {
    Route(
        arrow: .end,
        label: nil,
        routing: .straight,
        joints: [
            Joint(
                line: line,
                node: .a,
                edge: .bottom,
                axis: .vertical,
                base: CGPoint(x: 100, y: 50),
                neighbour: CGPoint(x: towards, y: 200)
            )
        ]
    )
}

private func point(_ routes: [Route], line: Int, spacing: CGFloat = 10) -> CGPoint? {
    LineRouter.spreadPoints(of: routes, spacing: spacing)[JointIndex(route: line, joint: 0)]
}

final class SpreadTests: XCTestCase {
    func test_aBundleOfOneSitsExactlyOnItsBase() {
        let routes = [leavingBottom(0, towards: 0)]

        XCTAssertEqual(point(routes, line: 0), CGPoint(x: 100, y: 50))
    }

    func test_aBundleIsCentredOnTheEdge() {
        let routes = [
            leavingBottom(0, towards: 0),
            leavingBottom(1, towards: 100),
            leavingBottom(2, towards: 200),
        ]
        let points = LineRouter.spreadPoints(of: routes, spacing: 10)

        // Three lanes ten apart, centred on x = 100.
        XCTAssertEqual(Set(points.values.map(\.x)), [90, 100, 110])
        XCTAssertEqual(Set(points.values.map(\.y)), [50])
    }

    func test_lanesFollowWhereEachLineIsHeaded() {
        // Written right to left, so declaration order alone would cross them.
        let routes = [
            leavingBottom(0, towards: 200),
            leavingBottom(1, towards: 0),
        ]

        XCTAssertEqual(point(routes, line: 0)?.x, 105)
        XCTAssertEqual(point(routes, line: 1)?.x, 95)
    }

    func test_linesHeadedTheSameWayFallBackToTheOrderTheyWereWritten() {
        let routes = [
            leavingBottom(0, towards: 100),
            leavingBottom(1, towards: 100),
        ]

        XCTAssertEqual(point(routes, line: 0)?.x, 95)
        XCTAssertEqual(point(routes, line: 1)?.x, 105)
    }

    func test_differentEdgesOfOneNodeAreDifferentBundles() {
        let bottom = leavingBottom(0, towards: 0)
        let trailing = Route(
            arrow: .end,
            label: nil,
            routing: .straight,
            joints: [
                Joint(
                    line: 1,
                    node: .a,
                    edge: .trailing,
                    axis: .horizontal,
                    base: CGPoint(x: 150, y: 25),
                    neighbour: CGPoint(x: 400, y: 25)
                )
            ]
        )

        // Neither has company, so neither moves.
        XCTAssertEqual(point([bottom, trailing], line: 0), CGPoint(x: 100, y: 50))
        XCTAssertEqual(point([bottom, trailing], line: 1), CGPoint(x: 150, y: 25))
    }

    func test_aWaypointBundlesByItselfRatherThanByAnEdge() {
        func through(_ line: Int, towards: CGFloat) -> Route {
            Route(
                arrow: .end,
                label: nil,
                routing: .straight,
                joints: [
                    Joint(
                        line: line,
                        node: .b,
                        edge: nil,
                        axis: .vertical,
                        base: CGPoint(x: 300, y: 80),
                        neighbour: CGPoint(x: towards, y: 300)
                    )
                ]
            )
        }
        let routes = [through(0, towards: 0), through(1, towards: 600)]

        // Spread across the travel: a vertical waypoint widens sideways.
        XCTAssertEqual(point(routes, line: 0), CGPoint(x: 295, y: 80))
        XCTAssertEqual(point(routes, line: 1), CGPoint(x: 305, y: 80))
    }
}
