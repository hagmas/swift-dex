import Foundation
import XCTest

@testable import SwiftDex

/// Tests for the timeline math derived on `SlideState`.
final class ActionTimelineTests: XCTestCase {
    // Two beats: [FakeAction(el0) & FakeAction1(el1)], [FakeAction(el0)]
    private func createState() -> SlideState {
        @ActionContainerBuilder func build() -> ActionContainer {
            FakeAction(elementID: .element(0)) & FakeAction1(elementID: .element(1))
            FakeAction(elementID: .element(0))
        }
        return SlideState(actionContainer: build())
    }

    func test_beatDurations_unregistered() {
        let state = createState()
        XCTAssertEqual(state.beatDurations, [1, 1])
        XCTAssertEqual(state.totalClicks, 2)
    }

    func test_beatDurations_useMaximumOfParallelActions() {
        var state = createState()
        state.register(
            clicks: 4,
            for: ClickCountKey(elementID: .element(1), actionType: FakeAction1.self)
        )
        state.register(
            clicks: 2,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )

        // Beat 0 = max(2, 4); beat 1 = 2 (same key as beat 0's FakeAction).
        XCTAssertEqual(state.beatDurations, [4, 2])
        XCTAssertEqual(state.totalClicks, 6)
    }

    func test_serialComposition_addsDurations() {
        let fade = FakeAction(elementID: .element(0))
        let flip = FakeAction1(elementID: .element(0))
        let bullets = FakeAction2(elementID: .element(1))

        @ActionContainerBuilder func build() -> ActionContainer {
            bullets & fade.then(flip)
        }
        var state = SlideState(actionContainer: build())
        state.register(
            clicks: 4,
            for: ClickCountKey(elementID: .element(1), actionType: FakeAction2.self)
        )
        state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction1.self)
        )

        // Serial branch = 1 + 3 = 4; parallel with bullets(4) -> beat = 4.
        XCTAssertEqual(state.beatDurations, [4])

        // Click 1: fade runs, flip has not started.
        state.position = .click(1)
        assertActive(
            progress: state.actionProgress(for: .element(0), type: FakeAction.self),
            current: fade,
            step: 1
        )
        assertIdle(
            progress: state.actionProgress(for: .element(0), type: FakeAction1.self),
            previous: nil,
            next: flip
        )

        // Clicks 2...4: fade completed (its beat still runs), flip sub-steps 1...3.
        state.position = .click(2)
        assertCompleted(
            progress: state.actionProgress(for: .element(0), type: FakeAction.self),
            current: fade
        )
        for click in 2...4 {
            state.position = .click(click)
            assertActive(
                progress: state.actionProgress(for: .element(0), type: FakeAction1.self),
                current: flip,
                step: click - 1
            )
        }

        // The parallel bullets run across the whole beat.
        state.position = .click(4)
        assertActive(
            progress: state.actionProgress(for: .element(1), type: FakeAction2.self),
            current: bullets,
            step: 4
        )
    }

    func test_beatIndex() {
        var state = createState()
        state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(1), actionType: FakeAction1.self)
        )
        // Durations: [3, 1]

        XCTAssertEqual(state.beatIndex(at: 0), 0)
        XCTAssertEqual(state.beatIndex(at: 1), 1)
        XCTAssertEqual(state.beatIndex(at: 3), 1)
        XCTAssertEqual(state.beatIndex(at: 4), 2)
        // Beyond the end.
        XCTAssertEqual(state.beatIndex(at: 5), 2)
    }

    func test_click_atBoundary() {
        var state = createState()
        state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(1), actionType: FakeAction1.self)
        )
        // Durations: [3, 1]

        XCTAssertEqual(state.click(atBoundary: 0), 0)
        XCTAssertEqual(state.click(atBoundary: 1), 3)
        XCTAssertEqual(state.click(atBoundary: 2), 4)
    }

    func test_endPosition_resolvesToTotal() {
        var state = createState()
        state.position = .end
        XCTAssertEqual(state.currentClick, 2)

        state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )
        XCTAssertEqual(state.currentClick, 6)
    }

    func test_emptyContainer() {
        let state = SlideState()
        XCTAssertEqual(state.totalClicks, 0)
        XCTAssertEqual(state.beatIndex(at: 0), 0)
    }
}
