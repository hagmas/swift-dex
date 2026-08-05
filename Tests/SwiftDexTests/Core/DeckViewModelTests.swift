import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class DeckViewModelTests: XCTestCase {
    func test_initialize() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 0)
    }

    func test_initialize_with_slideNumber() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: 1)
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.state.latestUserOperation, .none)
        XCTAssertEqual(viewModel.slideNumber, 1)
    }

    func test_forward() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)

        // Slide 0 has two lines; unregistered actions consume one click each.
        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(1))
        XCTAssertEqual(viewModel.state.latestUserOperation, .forward)
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(2))
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 1)

        // Slide 1 has no actions.
        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(1))
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(2))
        XCTAssertEqual(viewModel.slideNumber, 2)

        // No change because it is the end of the deck.
        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(2))
        XCTAssertEqual(viewModel.slideNumber, 2)
    }

    func test_forward_with_registered_clicks() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)

        // A view on slide 0 registers a three-click action for line 0.
        viewModel.state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )

        for expected in 1...4 {
            viewModel.forward()
            XCTAssertEqual(viewModel.state.position, .click(expected))
            XCTAssertEqual(viewModel.slideNumber, 0)
        }

        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 1)
    }

    func test_backward() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: 2)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .end)
        XCTAssertEqual(viewModel.state.latestUserOperation, .backward)
        XCTAssertEqual(viewModel.slideNumber, 1)

        // Slide 1 has no actions, so .end resolves to click 0.
        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .end)
        XCTAssertEqual(viewModel.slideNumber, 0)

        // Slide 0's .end resolves to click 2; rewinding is click-granular.
        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .click(1))
        XCTAssertEqual(viewModel.slideNumber, 0)

        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 0)

        // No change because it is the head of the deck.
        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 0)
    }

    func test_backward_rewinds_substeps() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)
        viewModel.state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )

        viewModel.forward()
        viewModel.forward()
        XCTAssertEqual(viewModel.state.position, .click(2))

        // Backward steps through sub-steps, not whole lines.
        viewModel.backward()
        XCTAssertEqual(viewModel.state.position, .click(1))
        XCTAssertEqual(viewModel.slideNumber, 0)
    }

    func test_randomAccess() {
        let viewModel = DeckViewModel(deck: MyDeck(), slideNumber: nil)

        viewModel.randomAccess(slideNumber: 2)
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.state.latestUserOperation, .randomAccess)
        XCTAssertEqual(viewModel.slideNumber, 2)

        viewModel.randomAccess(slideNumber: 1)
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 1)
        // The action container follows the slide.
        XCTAssertEqual(viewModel.state.actionContainer.capacity, 0)

        viewModel.randomAccess(slideNumber: 0)
        XCTAssertEqual(viewModel.state.position, .click(0))
        XCTAssertEqual(viewModel.slideNumber, 0)
        XCTAssertEqual(viewModel.state.actionContainer.capacity, 2)
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
