import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class DeckViewModelTests: XCTestCase {
    func test_initialize() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.slideNumber, 0)
    }

    func test_initialize_with_slideNumber() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: 1)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .none)
        XCTAssertEqual(viewModel.slideNumber, 1)
    }

    func test_forward() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)
        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 1)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 1)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 2)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 1)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 1)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 1)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 1)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 2)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 1)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 2)

        // No change because it is the end of the deck
        viewModel.forward()
        XCTAssertEqual(viewModel.state.step, 2)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 1)
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 2)
    }

    func test_backward() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: 2)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .none)
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 1)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.step, 2)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.step, 1)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        // No change because it is the head of the deck
        viewModel.backward()
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 0)
    }

    func test_randomAccess() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)

        viewModel.randomAccess(slideNumber: 2)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .randomAccess)
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.randomAccess(slideNumber: 1)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .randomAccess)
        XCTAssertEqual(viewModel.slideNumber, 1)

        viewModel.randomAccess(slideNumber: 0)
        XCTAssertEqual(viewModel.state.step, 0)
        XCTAssertEqual(viewModel.state.activeActionIDs.count, 0)
        XCTAssertEqual(viewModel.state.latestUserOperation, .randomAccess)
        XCTAssertEqual(viewModel.slideNumber, 0)
    }
}

private struct MyDeck: Deck {
    var flow: some Flow {
        Slide01()
            .next(Slide02())
            .next(Slide03())
    }
}

private struct Slide01: Slide {
    var content: some View {
        EmptyView()
            .elementID(.element(0))
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        FakeAction(elementID: .element(0))
        FakeAction1(elementID: .element(0))
    }
}

private struct Slide02: Slide {
    var content: some View {
        EmptyView()
            .elementID(.element(0))
    }
}

private struct Slide03: Slide {
    var content: some View {
        EmptyView()
            .elementID(.element(0))
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        FakeAction(elementID: .element(0))
        FakeAction1(elementID: .element(0))
    }
}
