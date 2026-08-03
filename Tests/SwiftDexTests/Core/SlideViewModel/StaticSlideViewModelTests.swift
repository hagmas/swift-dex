import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class StaticSlideViewModelTests: XCTestCase {
    func test_canBeAnimated() {
        let viewModel = StaticSlideViewModel(index: 0, actionContainer: createActionContainer())
        XCTAssertFalse(viewModel.canBeAnimated)
    }

    func test_actionProgress() {
        let container = createActionContainer()

        // Index 0 is before every line.
        let before = StaticSlideViewModel(index: 0, actionContainer: container)
        assertIdle(
            progress: before.actionProgress(for: .element(0), type: FakeAction.self),
            previous: nil,
            next: FakeAction(elementID: .element(0))
        )

        // A line index renders its action as completed, never animating.
        let at = StaticSlideViewModel(index: 1, actionContainer: container)
        assertCompleted(
            progress: at.actionProgress(for: .element(0), type: FakeAction.self),
            current: FakeAction(elementID: .element(0))
        )
    }
}

private extension StaticSlideViewModelTests {
    func createActionContainer() -> ActionContainer {
        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            FakeAction(elementID: .element(0))
        }
        return actionContainer()
    }
}
