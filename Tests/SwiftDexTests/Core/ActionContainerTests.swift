import Foundation
import XCTest

@testable import SwiftDex

final class ActionContainerTests: XCTestCase {
    func test_three_actions() {
        let first = FakeAction(elementID: .element(0))
        let second = FakeAction(elementID: .element(0))
        let third = FakeAction(elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            first
            second
            third
        }

        let ac = actionContainer()
        let squence: ExpectedSequence<FakeAction> =
            .static(next: first)
            .addDynamic(current: first, next: second)
            .addDynamic(previous: first, current: second, next: third)
            .addDynamic(previous: second, current: third)

        XCTAssertEqual(ac.capacity, 3)
        XCTAssertEqual(ac.actionIDs(for: 0).count, 1)
        XCTAssertEqual(ac.actionIDs(for: 1).count, 1)
        XCTAssertEqual(ac.actionIDs(for: 2).count, 1)
        assertActionSequence(
            elementID: .element(0),
            actionContainer: ac,
            expectedSequence: squence
        )
    }

    func test_two_action_types() {
        let first = FakeAction(elementID: .element(0))
        let second = FakeAction1(elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            first & second
        }

        let ac = actionContainer()
        let sequence0: ExpectedSequence<FakeAction> =
            .static(next: first)
            .addDynamic(current: first)
        let sequence1: ExpectedSequence<FakeAction1> =
            .static(next: second)
            .addDynamic(current: second)

        XCTAssertEqual(ac.capacity, 1)
        XCTAssertEqual(ac.actionIDs(for: 0).count, 2)
        assertActionSequence(
            elementID: .element(0),
            actionContainer: ac,
            expectedSequence: sequence0
        )
        assertActionSequence(
            elementID: .element(0),
            actionContainer: ac,
            expectedSequence: sequence1
        )
    }

    func test_two_elements() {
        let first = FakeAction(elementID: .element(0))
        let second = FakeAction(elementID: .element(1))
        let third = FakeAction(elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            first
            second
            third
        }

        let ac = actionContainer()
        let squence0: ExpectedSequence<FakeAction> =
            .static(next: first)
            .addDynamic(current: first, next: third)
            .addStatic(previous: first, next: third)
            .addDynamic(previous: first, current: third)
        let squence1: ExpectedSequence<FakeAction> =
            .static(next: second)
            .addStatic(next: second)
            .addDynamic(current: second)
            .addStatic(previous: second)

        XCTAssertEqual(ac.capacity, 3)
        XCTAssertEqual(ac.actionIDs(for: 0).count, 1)
        XCTAssertEqual(ac.actionIDs(for: 1).count, 1)
        XCTAssertEqual(ac.actionIDs(for: 2).count, 1)
        assertActionSequence(
            elementID: .element(0),
            actionContainer: ac,
            expectedSequence: squence0
        )
        assertActionSequence(
            elementID: .element(1),
            actionContainer: ac,
            expectedSequence: squence1
        )
    }

    func test_duplicated_actions() {
        let first = FakeAction2(id: "first", elementID: .element(0))
        let second = FakeAction2(id: "second", elementID: .element(0))

        @ActionContainerBuilder func actionContainer() -> ActionContainer {
            first & second
        }

        let ac = actionContainer()
        let sequence: ExpectedSequence<FakeAction2> =
            .static(next: first)
            .addDynamic(current: first)

        XCTAssertEqual(ac.capacity, 1)
        XCTAssertEqual(ac.actionIDs(for: 0).count, 1)
        assertActionSequence(
            elementID: .element(0),
            actionContainer: ac,
            expectedSequence: sequence
        )
    }
}
