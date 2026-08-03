import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class DynamicSlideViewModelTests: XCTestCase {
    func test_canBeAnimated() {
        var value = SlideState()
        value.latestUserOperation = .forward
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

        XCTAssertTrue(viewModel.canBeAnimated)

        value.latestUserOperation = .backward
        XCTAssertFalse(viewModel.canBeAnimated)

        value.latestUserOperation = .randomAccess
        XCTAssertFalse(viewModel.canBeAnimated)
    }

    func test_register() {
        var value = SlideState()
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction.self)

        let key = ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        XCTAssertEqual(value.clickCounts[key], 3)
    }

    func test_actionProgress_nil() {
        var value = SlideState()
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

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
        var value = SlideState()
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

        // Before everything.
        assertIdle(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            previous: nil,
            next: FakeAction(elementID: .element(0))
        )

        // After everything: three unregistered lines resolve to three clicks.
        value.position = .click(3)
        let progress: ActionProgress<FakeAction>? = viewModel.actionProgress(
            for: .element(0),
            type: FakeAction.self
        )
        // The last line's action is still on its own line at the final click.
        assertActive(progress: progress, current: FakeAction(elementID: .element(0)), step: 1)
    }

    func test_actionProgress_active_substeps() {
        var value = SlideState()
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction.self)

        // Line 0 now spans clicks 1...3.
        value.position = .click(1)
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0)),
            step: 1
        )

        value.position = .click(3)
        assertActive(
            progress: viewModel.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0)),
            step: 3
        )

        // Click 4 is the second line's first click.
        value.position = .click(4)
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

        var value = SlideState()
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: actionContainer())

        viewModel.register(clicks: 3, for: .element(0), type: FakeAction1.self)

        // Click 2: FakeAction (one click) has completed; FakeAction1 is on its second sub-step.
        value.position = .click(2)
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
        var value = SlideState(position: .end)
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: createActionContainer())

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
