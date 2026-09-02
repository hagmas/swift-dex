import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

@MainActor
final class DynamicSlideViewModelTests: XCTestCase {
    func test_canBeAnimated() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer()))
        state.value.latestUserOperation = .forward
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        XCTAssertTrue(viewModel.canBeAnimated)

        state.value.latestUserOperation = .backward
        XCTAssertFalse(viewModel.canBeAnimated)

        state.value.latestUserOperation = .randomAccess
        XCTAssertFalse(viewModel.canBeAnimated)
    }

    func test_register() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer()))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction.self)

        let key = ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        XCTAssertEqual(state.value.clickCounts[key], 3)
    }

    func test_actionProgress_nil() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer()))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        let progress0: ActionProgress<FakeAction1>? = viewModel.actionProgress(
            for: .element(0),
            type: FakeAction1.self
        )
        XCTAssertNil(progress0)

        let progress1: ActionProgress<FakeAction>? = viewModel.actionProgress(
            for: .element(1),
            type: FakeAction.self
        )
        XCTAssertNil(progress1)
    }

    func test_actionProgress_idle_before_and_after() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer()))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        // Before everything.
        assertIdle(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            previous: nil,
            next: FakeAction(elementID: .element(0))
        )

        // After everything: three unregistered lines resolve to three clicks.
        state.value.position = .click(3)
        let progress: ActionProgress<FakeAction>? = viewModel.actionProgress(
            for: .element(0),
            type: FakeAction.self
        )
        // The last line's action is still on its own line at the final click.
        assertActive(progress: progress, current: FakeAction(elementID: .element(0)), step: 1)
    }

    func test_actionProgress_active_substeps() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer()))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction.self)

        // Line 0 now spans clicks 1...3.
        state.value.position = .click(1)
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0)),
            step: 1
        )

        state.value.position = .click(3)
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0)),
            step: 3
        )

        // Click 4 is the second line's first click.
        state.value.position = .click(4)
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0)),
            step: 1
        )
    }

    func test_actionProgress_completed_while_line_is_running() {
        // One line with two parallel actions of different click counts.
        let fake = FakeAction(elementID: .element(0))
        let fake1 = FakeAction1(elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            fake & fake1
        }

        let state = SlideStateBox(SlideState(actionContainer: actionContainer()))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction1.self)

        // Click 2: FakeAction (one click) has completed; FakeAction1 is on its second sub-step.
        state.value.position = .click(2)
        assertCompleted(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: fake
        )
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction1.self),
            current: fake1,
            step: 2
        )
    }

    func test_currentClick_resolvesEndPosition() {
        let state = SlideStateBox(SlideState(actionContainer: createActionContainer(), position: .end))
        let binding = state.binding
        let viewModel = DynamicSlideViewModel(state: binding)

        // Three unregistered lines -> three clicks in total.
        XCTAssertEqual(viewModel.currentClick, 3)

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction.self)
        XCTAssertEqual(viewModel.currentClick, 9)
    }
}

private extension DynamicSlideViewModelTests {
    func createActionContainer() -> ActionContainer {
        let first = FakeAction(elementID: .element(0))
        let second = FakeAction(elementID: .element(0))
        let third = FakeAction(elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            first
            second
            third
        }

        return actionContainer()
    }
}
