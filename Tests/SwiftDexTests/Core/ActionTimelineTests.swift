import Foundation
import XCTest

@testable import SwiftDex

final class ActionTimelineTests: XCTestCase {
    // Two lines: [FakeAction & FakeAction1], [FakeAction]
    private func createActionContainer() -> ActionContainer {
        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            FakeAction(elementID: .element(0)) & FakeAction1(elementID: .element(1))
            FakeAction(elementID: .element(0))
        }
        return actionContainer()
    }

    func test_lineDurations_unregistered() {
        let container = createActionContainer()
        XCTAssertEqual(container.lineDurations(clickCounts: [:]), [1, 1])
        XCTAssertEqual(container.totalClicks(clickCounts: [:]), 2)
    }

    func test_lineDurations_useMaximumOfParallelActions() {
        let container = createActionContainer()
        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction1.self): 4,
            ClickCountKey(elementID: .element(0), actionType: FakeAction.self): 2,
        ]
        // Line 0 = max(2, 4); line 1 = 2 (same key as line 0's FakeAction).
        XCTAssertEqual(container.lineDurations(clickCounts: clickCounts), [4, 2])
        XCTAssertEqual(container.totalClicks(clickCounts: clickCounts), 6)
    }

    func test_position() {
        let container = createActionContainer()
        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction1.self): 3
        ]
        // Durations: [3, 1]

        XCTAssertEqual(
            container.position(at: 0, clickCounts: clickCounts),
            ActionContainer.TimelinePosition(index: 0, offset: 0)
        )
        XCTAssertEqual(
            container.position(at: 1, clickCounts: clickCounts),
            ActionContainer.TimelinePosition(index: 1, offset: 0)
        )
        XCTAssertEqual(
            container.position(at: 3, clickCounts: clickCounts),
            ActionContainer.TimelinePosition(index: 1, offset: 2)
        )
        XCTAssertEqual(
            container.position(at: 4, clickCounts: clickCounts),
            ActionContainer.TimelinePosition(index: 2, offset: 0)
        )
        // Beyond the end: everything is completed.
        XCTAssertEqual(
            container.position(at: 5, clickCounts: clickCounts).index,
            2
        )
    }

    func test_click_atBoundary() {
        let container = createActionContainer()
        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction1.self): 3
        ]
        // Durations: [3, 1]

        XCTAssertEqual(container.click(atBoundary: 0, clickCounts: clickCounts), 0)
        XCTAssertEqual(container.click(atBoundary: 1, clickCounts: clickCounts), 3)
        XCTAssertEqual(container.click(atBoundary: 2, clickCounts: clickCounts), 4)
    }

    func test_emptyContainer() {
        let container = ActionContainer.empty
        XCTAssertEqual(container.totalClicks(clickCounts: [:]), 0)
        XCTAssertEqual(
            container.position(at: 0, clickCounts: [:]),
            ActionContainer.TimelinePosition(index: 0, offset: 0)
        )
    }
}
