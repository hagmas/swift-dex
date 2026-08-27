import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests for the camera: the fold that turns a slide's `Camera` operations into
/// a rectangle, and the transform that maps that rectangle onto the viewport.
final class CameraTests: XCTestCase {
    private let home = CGRect(x: 0, y: 0, width: 1920, height: 1080)
    private let viewport = CGSize(width: 1920, height: 1080)

    private let rects: [ElementID: CGRect] = [
        .element(0): CGRect(x: 100, y: 100, width: 200, height: 200),
        .element(1): CGRect(x: 1000, y: 500, width: 100, height: 100),
    ]

    private func resolve(_ history: [Camera]) -> CGRect {
        CameraRect.resolve(history: history, home: home) { rects[$0] }
    }

    // MARK: - The fold

    func test_emptyHistory_isHome() {
        XCTAssertEqual(resolve([]), home)
    }

    func test_zoom_growsTheTargetToTheInverseOfTheRatio() {
        // A 200×200 target at ratio 0.5 fills half the viewport, so the camera
        // takes 400×400 around the target's centre (200, 200).
        XCTAssertEqual(
            resolve([Camera(.zoom(to: .element(0), ratio: 0.5))]),
            CGRect(x: 0, y: 0, width: 400, height: 400)
        )
    }

    func test_pan_keepsTheSizeTheZoomEstablished() {
        let rect = resolve([
            Camera(.zoom(to: .element(0), ratio: 0.5)),
            Camera(.pan(to: .element(1))),
        ])

        // Centred on element 1 (1050, 550), still 400×400: this is the whole
        // point of folding rather than reading the latest operation.
        XCTAssertEqual(rect, CGRect(x: 850, y: 350, width: 400, height: 400))
    }

    func test_pan_withoutAPrecedingZoom_keepsTheHomeSize() {
        XCTAssertEqual(
            resolve([Camera(.pan(to: .element(1)))]),
            CGRect(x: 90, y: 10, width: 1920, height: 1080)
        )
    }

    func test_reset_returnsHomeRegardlessOfHistory() {
        let rect = resolve([
            Camera(.zoom(to: .element(0), ratio: 0.5)),
            Camera(.pan(to: .element(1))),
            Camera(.reset),
        ])
        XCTAssertEqual(rect, home)
    }

    func test_unresolvableTarget_leavesTheCameraWhereItIs() {
        let zoomed = resolve([Camera(.zoom(to: .element(0), ratio: 0.5))])

        // An element with no published anchor — including every element on the
        // render before anchors arrive — must not move the camera.
        XCTAssertEqual(
            resolve([
                Camera(.zoom(to: .element(0), ratio: 0.5)),
                Camera(.pan(to: .element(9))),
            ]),
            zoomed
        )
        XCTAssertEqual(resolve([Camera(.pan(to: .element(9)))]), home)
    }

    func test_nonPositiveRatio_leavesTheCameraWhereItIs() {
        XCTAssertEqual(resolve([Camera(.zoom(to: .element(0), ratio: 0))]), home)
    }

    // MARK: - History on the timeline

    private func createState() -> SlideState {
        @ActionContainerBuilder func build() -> ActionContainer {
            Camera(.zoom(to: .element(0), ratio: 0.5))
            Camera(.pan(to: .element(1)))
            Camera(.reset)
        }
        return SlideState(actionContainer: build())
    }

    func test_actionHistory_growsWithTheClickPosition() {
        var state = createState()

        let expected = [home, CGRect(x: 0, y: 0, width: 400, height: 400), CGRect(x: 850, y: 350, width: 400, height: 400), home]

        for click in 0...3 {
            state.position = .click(click)
            let history = state.actionHistory(for: .none, type: Camera.self)
            XCTAssertEqual(history.count, click, "click \(click)")
            XCTAssertEqual(resolve(history), expected[click], "click \(click)")
        }
    }

    func test_actionHistory_isEmptyForAnActionTypeTheSlideDoesNotUse() {
        let state = createState()
        XCTAssertEqual(state.actionHistory(for: .none, type: FakeAction.self).count, 0)
    }

    // MARK: - The transform

    private func apply(_ transform: ProjectionTransform, to point: CGPoint) -> CGPoint {
        let x = point.x * transform.m11 + point.y * transform.m21 + transform.m31
        let y = point.x * transform.m12 + point.y * transform.m22 + transform.m32
        let w = point.x * transform.m13 + point.y * transform.m23 + transform.m33
        return CGPoint(x: x / w, y: y / w)
    }

    func test_effectValue_putsTheCameraCentreAtTheViewportCentre() {
        let rect = CGRect(x: 850, y: 350, width: 400, height: 400)
        let transform = CameraEffect(rect: rect, viewport: viewport)
            .effectValue(size: viewport)

        let centre = apply(transform, to: CGPoint(x: rect.midX, y: rect.midY))
        XCTAssertEqual(centre.x, 960, accuracy: 0.001)
        XCTAssertEqual(centre.y, 540, accuracy: 0.001)
    }

    func test_effectValue_ignoresTheSizeItIsHanded() {
        // The transformed view is the canvas, so `size` is the canvas — three
        // viewports wide here. Reading the viewport off it shifts the whole
        // slide out of frame and mis-scales every zoom.
        let rect = CGRect(x: 850, y: 350, width: 400, height: 400)
        let effect = CameraEffect(rect: rect, viewport: viewport)

        let onViewport = effect.effectValue(size: viewport)
        let onCanvas = effect.effectValue(size: CGSize(width: 5760, height: 1080))

        for point in [CGPoint.zero, CGPoint(x: 1050, y: 550), CGPoint(x: 5000, y: 900)] {
            let a = apply(onViewport, to: point)
            let b = apply(onCanvas, to: point)
            XCTAssertEqual(a.x, b.x, accuracy: 0.001)
            XCTAssertEqual(a.y, b.y, accuracy: 0.001)
        }
    }

    func test_effectValue_fitsOnTheTighterAxis() {
        // 400×400 in a 16:9 viewport fits by height: scale 1080/400 = 2.7.
        let transform = CameraEffect(
            rect: CGRect(x: 850, y: 350, width: 400, height: 400),
            viewport: viewport
        )
        .effectValue(size: viewport)

        let topLeft = apply(transform, to: CGPoint(x: 850, y: 350))
        let bottomRight = apply(transform, to: CGPoint(x: 1250, y: 750))
        XCTAssertEqual(bottomRight.y - topLeft.y, 1080, accuracy: 0.001)
        XCTAssertEqual(bottomRight.x - topLeft.x, 1080, accuracy: 0.001)
    }

    func test_effectValue_atHomeIsTheIdentity() {
        let transform = CameraEffect(rect: home, viewport: viewport).effectValue(size: viewport)

        for point in [CGPoint.zero, CGPoint(x: 1920, y: 1080), CGPoint(x: 640, y: 800)] {
            let mapped = apply(transform, to: point)
            XCTAssertEqual(mapped.x, point.x, accuracy: 0.001)
            XCTAssertEqual(mapped.y, point.y, accuracy: 0.001)
        }
    }

    func test_effectValue_degenerateRectIsTheIdentity() {
        let transform = CameraEffect(rect: .zero, viewport: viewport).effectValue(size: viewport)
        let mapped = apply(transform, to: CGPoint(x: 100, y: 200))
        XCTAssertEqual(mapped.x, 100, accuracy: 0.001)
        XCTAssertEqual(mapped.y, 200, accuracy: 0.001)
    }
}
