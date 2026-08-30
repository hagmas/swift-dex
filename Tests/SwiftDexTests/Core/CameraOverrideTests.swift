import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests for the presenter's own camera movement, and for the rule that decides
/// when the slide takes the camera back.
final class CameraOverrideTests: XCTestCase {
    private let viewport = CGSize(width: 1920, height: 1080)
    private let action = CGRect(x: 0, y: 0, width: 1920, height: 1080)

    /// Where a canvas point lands on screen, for a given camera rectangle.
    private func onScreen(_ point: CGPoint, camera: CGRect) -> CGPoint {
        let scale = min(viewport.width / camera.width, viewport.height / camera.height)
        return CGPoint(
            x: viewport.width / 2 + (point.x - camera.midX) * scale,
            y: viewport.height / 2 + (point.y - camera.midY) * scale
        )
    }

    // MARK: - Applying a movement

    func test_identity_leavesTheActionsRectangleAlone() {
        XCTAssertEqual(CameraOverride(anchorClick: 0).apply(to: action), action)
        XCTAssertTrue(CameraOverride(anchorClick: 0).isIdentity)
    }

    func test_translation_movesWithoutResizing() {
        var override = CameraOverride(anchorClick: 0)
        override.translation = CGSize(width: 600, height: -200)

        let moved = override.apply(to: action)
        XCTAssertEqual(moved, CGRect(x: 600, y: -200, width: 1920, height: 1080))
    }

    func test_scale_shrinksTheRectangleAboutItsCentre() {
        var override = CameraOverride(anchorClick: 0)
        override.scale = 2

        let zoomed = override.apply(to: action)
        XCTAssertEqual(zoomed, CGRect(x: 480, y: 270, width: 960, height: 540))
        XCTAssertEqual(zoomed.midX, action.midX, "magnifying must not move the camera")
        XCTAssertEqual(zoomed.midY, action.midY)
    }

    // MARK: - Magnifying about a pivot

    func test_magnify_keepsThePivotWhereItIsOnScreen() {
        let pivot = CGPoint(x: 1500, y: 300)
        var override = CameraOverride(anchorClick: 0)
        let before = onScreen(pivot, camera: override.apply(to: action))

        override.magnify(by: 1.5, about: pivot, in: action)
        let after = onScreen(pivot, camera: override.apply(to: action))

        XCTAssertEqual(after.x, before.x, accuracy: 0.001)
        XCTAssertEqual(after.y, before.y, accuracy: 0.001)
        XCTAssertEqual(override.scale, 1.5, accuracy: 0.001)
    }

    func test_magnify_keepsThePivotAcrossSuccessiveEvents() {
        // A pinch arrives as a stream of small magnifications; each one has to
        // hold the pivot, not just the first.
        let pivot = CGPoint(x: 400, y: 800)
        var override = CameraOverride(anchorClick: 0)
        let before = onScreen(pivot, camera: override.apply(to: action))

        for _ in 0..<20 {
            override.magnify(by: 1.05, about: pivot, in: action)
        }

        let after = onScreen(pivot, camera: override.apply(to: action))
        XCTAssertEqual(after.x, before.x, accuracy: 0.001)
        XCTAssertEqual(after.y, before.y, accuracy: 0.001)
        XCTAssertGreaterThan(override.scale, 2)
    }

    func test_magnify_isClampedAtBothEnds() {
        var override = CameraOverride(anchorClick: 0)
        for _ in 0..<200 {
            override.magnify(by: 1.5, about: CGPoint(x: 960, y: 540), in: action)
        }
        XCTAssertEqual(override.scale, CameraOverride.scaleLimits.upperBound)

        for _ in 0..<400 {
            override.magnify(by: 0.5, about: CGPoint(x: 960, y: 540), in: action)
        }
        XCTAssertEqual(override.scale, CameraOverride.scaleLimits.lowerBound)
    }

    // MARK: - When the script takes the camera back

    private func createState() -> SlideState {
        @ActionContainerBuilder func build() -> ActionContainer {
            Camera(.pan(to: .element(0)))
            FakeAction(elementID: .element(1))
            Camera(.reset)
        }
        return SlideState(actionContainer: build())
    }

    func test_override_appliesOnTheClickItWasMadeOn() {
        var state = createState()
        state.position = .click(1)
        state.cameraOverride = CameraOverride(scale: 2, translation: .zero, anchorClick: 1)

        XCTAssertNotNil(
            state.effectiveCameraOverride,
            "moving the camera after a click must not immediately undo itself"
        )
    }

    func test_override_isDroppedByAdvancing() {
        var state = createState()
        state.position = .click(1)
        state.cameraOverride = CameraOverride(scale: 2, translation: .zero, anchorClick: 1)

        state.position = .click(2)

        // Advancing is how the presenter says they are done exploring, whatever
        // the next click happens to do. No exception for actions that are not
        // about the camera: a rule with clauses is one a presenter cannot hold
        // in their head while talking.
        XCTAssertNil(state.effectiveCameraOverride)
    }

    func test_override_isDroppedByRewindingToo() {
        var state = createState()
        state.position = .click(2)
        state.cameraOverride = CameraOverride(scale: 2, translation: .zero, anchorClick: 2)

        state.position = .click(1)
        XCTAssertNil(state.effectiveCameraOverride)
    }
}
