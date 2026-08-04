import Foundation
import XCTest

@testable import SwiftDex

final class ActionTimelineTests: XCTestCase {
    // Two beats: [FakeAction(el0) & FakeAction1(el1)], [FakeAction(el0)]
    private func createActionContainer() -> ActionContainer {
        @ActionContainerBuilder func build() -> ActionContainer {
            FakeAction(elementID: .element(0)) & FakeAction1(elementID: .element(1))
            FakeAction(elementID: .element(0))
        }
        return build()
    }

    func test_beatDurations_unregistered() {
        let container = createActionContainer()
        XCTAssertEqual(container.beatDurations(clickCounts: [:]), [1, 1])
        XCTAssertEqual(container.totalClicks(clickCounts: [:]), 2)
    }

    func test_beatDurations_useMaximumOfParallelActions() {
        let container = createActionContainer()
        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction1.self): 4,
            ClickCountKey(elementID: .element(0), actionType: FakeAction.self): 2,
        ]
        // Beat 0 = max(2, 4); beat 1 = 2 (same key as beat 0's FakeAction).
        XCTAssertEqual(container.beatDurations(clickCounts: clickCounts), [4, 2])
        XCTAssertEqual(container.totalClicks(clickCounts: clickCounts), 6)
    }

    func test_serialComposition_addsDurations() {
        let fade = FakeAction(elementID: .element(0))
        let flip = FakeAction1(elementID: .element(0))
        let bullets = FakeAction2(elementID: .element(1))

        @ActionContainerBuilder func build() -> ActionContainer {
            bullets & fade.then(flip)
        }
        let container = build()

        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction2.self): 4,
            ClickCountKey(elementID: .element(0), actionType: FakeAction1.self): 3,
        ]
        // Serial branch = 1 + 3 = 4; parallel with bullets(4) -> beat = 4.
        XCTAssertEqual(container.beatDurations(clickCounts: clickCounts), [4])

        // Click 1: fade runs, flip has not started.
        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction.self,
                at: 1,
                clickCounts: clickCounts
            ),
            current: fade,
            step: 1
        )
        assertIdle(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction1.self,
                at: 1,
                clickCounts: clickCounts
            ),
            previous: nil,
            next: flip
        )

        // Clicks 2...4: fade completed (its beat still runs), flip sub-steps 1...3.
        assertCompleted(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction.self,
                at: 2,
                clickCounts: clickCounts
            ),
            current: fade
        )
        for click in 2...4 {
            assertActive(
                progress: container.actionProgress(
                    for: .element(0),
                    type: FakeAction1.self,
                    at: click,
                    clickCounts: clickCounts
                ),
                current: flip,
                step: click - 1
            )
        }

        // The parallel bullets run across the whole beat.
        assertActive(
            progress: container.actionProgress(
                for: .element(1),
                type: FakeAction2.self,
                at: 4,
                clickCounts: clickCounts
            ),
            current: bullets,
            step: 4
        )
    }

    func test_beatIndex() {
        let container = createActionContainer()
        let clickCounts = [
            ClickCountKey(elementID: .element(1), actionType: FakeAction1.self): 3
        ]
        // Durations: [3, 1]

        XCTAssertEqual(container.beatIndex(at: 0, clickCounts: clickCounts), 0)
        XCTAssertEqual(container.beatIndex(at: 1, clickCounts: clickCounts), 1)
        XCTAssertEqual(container.beatIndex(at: 3, clickCounts: clickCounts), 1)
        XCTAssertEqual(container.beatIndex(at: 4, clickCounts: clickCounts), 2)
        // Beyond the end.
        XCTAssertEqual(container.beatIndex(at: 5, clickCounts: clickCounts), 2)
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
        XCTAssertEqual(container.beatIndex(at: 0, clickCounts: [:]), 0)
    }
}
