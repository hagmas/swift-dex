import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class DeckControllerTests: XCTestCase {
    func test_initialize() {
        let controller = DeckController(deck: MyDeck())
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 0)
    }

    func test_initialize_with_slideNumber() {
        let controller = DeckController(deck: MyDeck(), slideNumber: 1)
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.state.latestUserOperation, .none)
        XCTAssertEqual(controller.slideNumber, 1)
    }

    func test_forward() {
        let controller = DeckController(deck: MyDeck())

        // Slide 0 has two lines; unregistered actions consume one click each.
        controller.forward()
        XCTAssertEqual(controller.state.position, .click(1))
        XCTAssertEqual(controller.state.latestUserOperation, .forward)
        XCTAssertEqual(controller.slideNumber, 0)

        controller.forward()
        XCTAssertEqual(controller.state.position, .click(2))
        XCTAssertEqual(controller.slideNumber, 0)

        controller.forward()
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 1)

        // Slide 1 has no actions.
        controller.forward()
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 2)

        controller.forward()
        XCTAssertEqual(controller.state.position, .click(1))
        XCTAssertEqual(controller.slideNumber, 2)

        controller.forward()
        XCTAssertEqual(controller.state.position, .click(2))
        XCTAssertEqual(controller.slideNumber, 2)

        // No change because it is the end of the deck.
        controller.forward()
        XCTAssertEqual(controller.state.position, .click(2))
        XCTAssertEqual(controller.slideNumber, 2)
    }

    func test_forward_with_registered_clicks() {
        let controller = DeckController(deck: MyDeck())

        // A view on slide 0 registers a three-click action for line 0.
        controller.state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )

        for expected in 1...4 {
            controller.forward()
            XCTAssertEqual(controller.state.position, .click(expected))
            XCTAssertEqual(controller.slideNumber, 0)
        }

        controller.forward()
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 1)
    }

    func test_backward() {
        let controller = DeckController(deck: MyDeck(), slideNumber: 2)

        controller.backward()
        XCTAssertEqual(controller.state.position, .end)
        XCTAssertEqual(controller.state.latestUserOperation, .backward)
        XCTAssertEqual(controller.slideNumber, 1)

        // Slide 1 has no actions, so .end resolves to click 0.
        controller.backward()
        XCTAssertEqual(controller.state.position, .end)
        XCTAssertEqual(controller.slideNumber, 0)

        // Slide 0's .end resolves to click 2; rewinding is click-granular.
        controller.backward()
        XCTAssertEqual(controller.state.position, .click(1))
        XCTAssertEqual(controller.slideNumber, 0)

        controller.backward()
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 0)

        // No change because it is the head of the deck.
        controller.backward()
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 0)
    }

    func test_backward_rewinds_substeps() {
        let controller = DeckController(deck: MyDeck())
        controller.state.register(
            clicks: 3,
            for: ClickCountKey(elementID: .element(0), actionType: FakeAction.self)
        )

        controller.forward()
        controller.forward()
        XCTAssertEqual(controller.state.position, .click(2))

        // Backward steps through sub-steps, not whole lines.
        controller.backward()
        XCTAssertEqual(controller.state.position, .click(1))
        XCTAssertEqual(controller.slideNumber, 0)
    }

    func test_randomAccess() {
        let controller = DeckController(deck: MyDeck())

        controller.randomAccess(slideNumber: 2)
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.state.latestUserOperation, .randomAccess)
        XCTAssertEqual(controller.slideNumber, 2)

        controller.randomAccess(slideNumber: 1)
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 1)
        // The action container follows the slide.
        XCTAssertEqual(controller.state.actionContainer.capacity, 0)

        controller.randomAccess(slideNumber: 0)
        XCTAssertEqual(controller.state.position, .click(0))
        XCTAssertEqual(controller.slideNumber, 0)
        XCTAssertEqual(controller.state.actionContainer.capacity, 2)
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
