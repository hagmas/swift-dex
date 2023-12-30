import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class StaticSlideViewModelTests: XCTestCase {
    func test_canBeAnimated() {
        let ac = createActionContainer()
        let viewModel = StaticSlideViewModel(step: 1, actionContainer: ac)

        // For StaticSlideViewModel, `canBeAnimated` should be always `false`
        XCTAssertFalse(viewModel.canBeAnimated)
    }
}

private extension StaticSlideViewModelTests {
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
