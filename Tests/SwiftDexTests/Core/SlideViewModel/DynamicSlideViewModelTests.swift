import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class DynamicSlideViewModelTests: XCTestCase {
    func test_canBeAnimated() {
        let ac = createActionContainer()
        var value = SlideState(step: 0, latestUserOperation: .forward)
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        XCTAssertTrue(viewModel.canBeAnimated)

        value.latestUserOperation = .backward
        XCTAssertFalse(viewModel.canBeAnimated)

        value.latestUserOperation = .randomAccess
        XCTAssertFalse(viewModel.canBeAnimated)
    }

    func test_deactivate() {
        let ac = createActionContainer()
        let uuid = UUID()
        let actionID = ActionID(rawValue: uuid)
        var value = SlideState(
            step: 0,
            activeActionIDs: [actionID],
            latestUserOperation: .forward
        )
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        XCTAssertTrue(value.isActive)
        viewModel.deactivate(actionID: actionID)
        XCTAssertFalse(value.isActive)
    }

    func test_actionState_nil() {
        let ac = createActionContainer()
        var value = SlideState(step: 0, latestUserOperation: nil)
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        let actionState0 = viewModel.actionState(for: .element(0), type: FakeAction1.self)
        XCTAssertNil(actionState0)

        let actionState1 = viewModel.actionState(for: .element(1), type: FakeAction.self)
        XCTAssertNil(actionState1)
    }

    func test_actionState_static() {
        let ac = createActionContainer()
        var value = SlideState(step: 0, latestUserOperation: nil)
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        let actionState = viewModel.actionState(for: .element(0), type: FakeAction.self)
        assertActionStateStatic(actionState: actionState, next: FakeAction(elementID: .element(0)))
    }

    func test_actionState_dynamic_activated() {
        let ac = createActionContainer()
        let step = 1
        let actionIDs = ac.actionIDs(for: step - 1)
        var value = SlideState(
            step: step,
            activeActionIDs: actionIDs,
            latestUserOperation: nil
        )
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        let actionState = viewModel.actionState(for: .element(0), type: FakeAction.self)
        assertActionStateActivated(
            actionState: actionState,
            previous: nil,
            current: FakeAction(elementID: .element(0)),
            next: FakeAction(elementID: .element(0))
        )
    }

    func test_actionState_dynamic_deactivated() {
        let ac = createActionContainer()
        let step = 1
        var value = SlideState(
            step: step,
            latestUserOperation: nil
        )
        let binding = Binding(get: { value }, set: { value = $0 })
        let viewModel = DynamicSlideViewModel(state: binding, actionContainer: ac)

        let actionState = viewModel.actionState(for: .element(0), type: FakeAction.self)
        assertActionStateDeactivated(
            actionState: actionState,
            previous: nil,
            current: FakeAction(elementID: .element(0)),
            next: FakeAction(elementID: .element(0))
        )
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
