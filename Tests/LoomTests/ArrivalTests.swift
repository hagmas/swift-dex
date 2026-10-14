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
final class ArrivalTests: XCTestCase {
    /// Lines a change brings in wait for that change to settle; lines already
    /// there are not held back by it.
    func test_newLinesWaitForTheChangeThatBroughtThemIn() {
        let watch = ArrivalWatch()

        watch.note([ab])
        XCTAssertEqual(watch.takeUnannounced(), 1)

        watch.note([ab, bc])
        XCTAssertEqual(watch.takeUnannounced(), 2)
        XCTAssertEqual(watch.settling(for: ab), 1)
        XCTAssertEqual(watch.settling(for: bc), 2)
    }

    /// A change that brings in no lines has nothing to announce, however often
    /// the figure is read.
    func test_aChangeWithoutNewLinesAnnouncesNothing() {
        let watch = ArrivalWatch()
        watch.note([ab])
        _ = watch.takeUnannounced()

        watch.note([ab])
        watch.note([ab])

        XCTAssertNil(watch.takeUnannounced())
    }

    /// A line that goes and comes back waits all over again.
    func test_aLineThatComesBackWaitsAgain() {
        let watch = ArrivalWatch()
        watch.note([ab])
        watch.note([])
        watch.note([ab])

        XCTAssertEqual(watch.settling(for: ab), 2)
    }

    /// Which lines a figure has follows from which nodes are there, with no
    /// geometry at all.
    func test_drawableLinesFollowFromTheNodesPresent() {
        let lines = [Line(from: .a, to: .b), Line(from: .b, to: .c)]

        XCTAssertEqual(LineRouter.drawnIDs(for: lines, present: [NodeID.a, .b].contains), [ab])
        XCTAssertEqual(LineRouter.drawnIDs(for: lines, present: [NodeID.a, .b, .c].contains), [ab, bc])
    }
}
