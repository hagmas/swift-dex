import XCTest

@testable import Loom

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
    static let c = NodeID("c")
}

private let ab = DrawnLineID(key: LineKey(route: [.a, .b], name: .label(nil)), occurrence: 0)
private let bc = DrawnLineID(key: LineKey(route: [.b, .c], name: .label(nil)), occurrence: 0)

@MainActor
final class LinePhaseTrackerTests: XCTestCase {
    /// Lines a change brings in wait for that change's nodes' phase to finish;
    /// lines already there are not held back by it.
    func test_newLinesWaitForTheChangeThatBroughtThemIn() {
        let tracker = LinePhaseTracker()

        tracker.note([ab])
        XCTAssertEqual(tracker.takeUnannounced(), 1)

        tracker.note([ab, bc])
        XCTAssertEqual(tracker.takeUnannounced(), 2)
        XCTAssertEqual(tracker.phase(for: ab), 1)
        XCTAssertEqual(tracker.phase(for: bc), 2)
    }

    /// A change that brings in no lines has nothing to announce, however often
    /// the figure is read.
    func test_aChangeWithoutNewLinesAnnouncesNothing() {
        let tracker = LinePhaseTracker()
        tracker.note([ab])
        _ = tracker.takeUnannounced()

        tracker.note([ab])
        tracker.note([ab])

        XCTAssertNil(tracker.takeUnannounced())
    }

    /// A line that goes and comes back waits all over again.
    func test_aLineThatComesBackWaitsAgain() {
        let tracker = LinePhaseTracker()
        tracker.note([ab])
        tracker.note([])
        tracker.note([ab])

        XCTAssertEqual(tracker.phase(for: ab), 2)
    }

    /// Which lines a figure has follows from which nodes are there, with no
    /// geometry at all.
    func test_drawableLinesFollowFromTheNodesPresent() {
        let lines = [Line(from: .a, to: .b), Line(from: .b, to: .c)]

        XCTAssertEqual(LineRouter.drawnIDs(for: lines, present: [NodeID.a, .b].contains), [ab])
        XCTAssertEqual(LineRouter.drawnIDs(for: lines, present: [NodeID.a, .b, .c].contains), [ab, bc])
    }
}
