import Foundation
import XCTest

@testable import SwiftDex

/// Behavior tests for building an `ActionContainer` and deriving progress from it.
final class ActionContainerTests: XCTestCase {
    func test_sequentialActions() {
        let first = FakeAction2(id: "first", elementID: .element(0))
        let second = FakeAction2(id: "second", elementID: .element(0))

        @ActionContainerBuilder func build() -> ActionContainer {
            first
            second
        }
        let container = build()

        XCTAssertEqual(container.capacity, 2)

        // Click 0: before everything.
        assertIdle(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 0,
                clickCounts: [:]
            ),
            previous: nil,
            next: first
        )

        // Click 1: the first action runs.
        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 1,
                clickCounts: [:]
            ),
            current: first,
            step: 1
        )

        // Click 2: the second action runs; `first` is its previous neighbor
        // when idle in between (verified via a three-line container below).
        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 2,
                clickCounts: [:]
            ),
            current: second,
            step: 1
        )
    }

    func test_idleBetweenActions_carriesNeighbors() {
        let first = FakeAction2(id: "first", elementID: .element(0))
        let second = FakeAction2(id: "second", elementID: .element(0))
        let other = FakeAction1(elementID: .element(1))

        @ActionContainerBuilder func build() -> ActionContainer {
            first
            other
            second
        }
        let container = build()

        // Click 2 runs `other`; element 0 is idle between its two actions.
        assertIdle(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 2,
                clickCounts: [:]
            ),
            previous: first,
            next: second
        )

        // Click 3: past everything, idle after the last action.
        assertActive(
            progress: container.actionProgress(
                for: .element(1),
                type: FakeAction1.self,
                at: 2,
                clickCounts: [:]
            ),
            current: other,
            step: 1
        )
    }

    func test_parallelActions_differentTypesAndElements() {
        let fake = FakeAction(elementID: .element(0))
        let fake1 = FakeAction1(elementID: .element(1))

        @ActionContainerBuilder func build() -> ActionContainer {
            fake & fake1
        }
        let container = build()

        XCTAssertEqual(container.capacity, 1)

        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction.self,
                at: 1,
                clickCounts: [:]
            ),
            current: fake,
            step: 1
        )
        assertActive(
            progress: container.actionProgress(
                for: .element(1),
                type: FakeAction1.self,
                at: 1,
                clickCounts: [:]
            ),
            current: fake1,
            step: 1
        )
    }

    func test_duplicateActionAtSameStructuralPosition_isIgnored() {
        let first = FakeAction2(id: "kept", elementID: .element(0))
        let duplicate = FakeAction2(id: "dropped", elementID: .element(0))

        @ActionContainerBuilder func build() -> ActionContainer {
            first & duplicate
        }
        let container = build()

        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 1,
                clickCounts: [:]
            ),
            current: first,
            step: 1
        )
        // The dropped duplicate does not linger anywhere on the timeline.
        assertIdle(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 2,
                clickCounts: [:]
            ),
            previous: first,
            next: nil
        )
    }

    func test_sameActionType_atDifferentStructuralPositions_isAllowed() {
        let first = FakeAction2(id: "first", elementID: .element(0))
        let second = FakeAction2(id: "second", elementID: .element(0))

        @ActionContainerBuilder func build() -> ActionContainer {
            first.then(second)
        }
        let container = build()

        XCTAssertEqual(container.capacity, 1)
        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 1,
                clickCounts: [:]
            ),
            current: first,
            step: 1
        )
        assertActive(
            progress: container.actionProgress(
                for: .element(0),
                type: FakeAction2.self,
                at: 2,
                clickCounts: [:]
            ),
            current: second,
            step: 1
        )
    }

    func test_emptyContainer() {
        let container = ActionContainer.empty
        XCTAssertEqual(container.capacity, 0)
        XCTAssertNil(
            container.actionProgress(
                for: .element(0),
                type: FakeAction.self,
                at: 0,
                clickCounts: [:]
            )
        )
    }
}
