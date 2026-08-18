import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

@MainActor
final class SlideValueStoreTests: XCTestCase {
    func test_value_roundTrip() {
        let store = SlideValueStore()
        XCTAssertNil(store.value(of: Int.self, for: .element(0)))

        store.setValue(42, for: .element(0))
        XCTAssertEqual(store.value(of: Int.self, for: .element(0)), 42)
    }

    func test_keys_are_scoped_by_type_and_element() {
        let store = SlideValueStore()
        store.setValue(1, for: .element(0))
        store.setValue("a", for: .element(0))
        store.setValue(2, for: .element(1))

        XCTAssertEqual(store.value(of: Int.self, for: .element(0)), 1)
        XCTAssertEqual(store.value(of: String.self, for: .element(0)), "a")
        XCTAssertEqual(store.value(of: Int.self, for: .element(1)), 2)
    }

    func test_forward_within_slide_keeps_values() {
        let controller = DeckController(deck: StoreDeck())
        controller.slideValueStore.setValue(42, for: .element(0))

        // Slide 0 has two one-click actions; this forward stays on the slide.
        controller.forward()
        XCTAssertEqual(controller.slideNumber, 0)
        XCTAssertEqual(controller.slideValueStore.value(of: Int.self, for: .element(0)), 42)
    }

    func test_forward_across_slides_clears() {
        let controller = DeckController(deck: StoreDeck(), slideNumber: 1)
        controller.slideValueStore.setValue(42, for: .element(0))

        // Slide 1 has no actions, so this forward transitions to slide 2.
        controller.forward()
        XCTAssertEqual(controller.slideNumber, 2)
        XCTAssertNil(controller.slideValueStore.value(of: Int.self, for: .element(0)))
    }

    func test_backward_clears() {
        let controller = DeckController(deck: StoreDeck())
        controller.forward()
        controller.slideValueStore.setValue(42, for: .element(0))

        // Rewinding a click within the slide discards state.
        controller.backward()
        XCTAssertEqual(controller.slideNumber, 0)
        XCTAssertNil(controller.slideValueStore.value(of: Int.self, for: .element(0)))
    }

    func test_backward_across_slides_clears() {
        let controller = DeckController(deck: StoreDeck(), slideNumber: 1)
        controller.slideValueStore.setValue(42, for: .element(0))

        controller.backward()
        XCTAssertEqual(controller.slideNumber, 0)
        XCTAssertNil(controller.slideValueStore.value(of: Int.self, for: .element(0)))
    }

    func test_randomAccess_clears() {
        let controller = DeckController(deck: StoreDeck())
        controller.slideValueStore.setValue(42, for: .element(0))

        controller.randomAccess(slideNumber: 2)
        XCTAssertNil(controller.slideValueStore.value(of: Int.self, for: .element(0)))
    }
}

private struct StoreDeck: Deck {
    var flow: some Flow {
        ActionSlide()
            .next(PlainSlide())
            .next(PlainSlide())
    }
}

private struct ActionSlide: Slide {
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

private struct PlainSlide: Slide {
    var content: some View {
        EmptyView()
    }
}
