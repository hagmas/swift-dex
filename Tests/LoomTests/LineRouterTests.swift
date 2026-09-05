import CoreGraphics
import XCTest

@testable import Loom

final class LineRouterTests: XCTestCase {
    private let upper = CGRect(x: 0, y: 0, width: 100, height: 50)

    func test_stackedNodes_meetAtTheFacingEdges() {
        let lower = CGRect(x: 0, y: 100, width: 100, height: 50)

        let ends = LineRouter.endpoints(from: upper, to: lower)

        XCTAssertEqual(ends.start, CGPoint(x: 50, y: 50))
        XCTAssertEqual(ends.end, CGPoint(x: 50, y: 100))
    }

    func test_sideBySideNodes_meetAtTheFacingEdges() {
        let right = CGRect(x: 150, y: 0, width: 100, height: 50)

        let ends = LineRouter.endpoints(from: upper, to: right)

        XCTAssertEqual(ends.start, CGPoint(x: 100, y: 25))
        XCTAssertEqual(ends.end, CGPoint(x: 150, y: 25))
    }

    func test_directionIsRespected() {
        let lower = CGRect(x: 0, y: 100, width: 100, height: 50)

        let downward = LineRouter.endpoints(from: upper, to: lower)
        let upward = LineRouter.endpoints(from: lower, to: upper)

        XCTAssertEqual(downward.start, upward.end)
        XCTAssertEqual(downward.end, upward.start)
    }

    func test_theSameRectanglesAlwaysRouteTheSameWay() {
        // A square directly on the diagonal makes several edge pairs equally
        // short. The tie-break must not wander between calls.
        let diagonal = CGRect(x: 100, y: 100, width: 100, height: 50)

        let first = LineRouter.endpoints(from: upper, to: diagonal)
        let second = LineRouter.endpoints(from: upper, to: diagonal)

        XCTAssertEqual(first.start, second.start)
        XCTAssertEqual(first.end, second.end)
    }
}
