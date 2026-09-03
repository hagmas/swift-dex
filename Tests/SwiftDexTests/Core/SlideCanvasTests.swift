import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests for the canvas a slide lays its content out in.
@MainActor
final class SlideCanvasTests: XCTestCase {
    private let slideSize = CGSize(width: 1920, height: 1080)

    // MARK: - Extents

    func test_slideExtent_takesTheViewportsLength() {
        XCTAssertEqual(CanvasExtent.slide.length(slide: slideSize.width), 1920)
    }

    func test_pointsExtent_takesTheGivenLength() {
        XCTAssertEqual(CanvasExtent.points(5760).length(slide: slideSize.width), 5760)
    }

    func test_contentExtent_imposesNoLength() {
        // `nil` is what leaves the axis unconstrained, so the content decides
        // it. The extent is never measured back.
        XCTAssertNil(CanvasExtent.content.length(slide: slideSize.width))
        XCTAssertTrue(CanvasExtent.content.isContent)
        XCTAssertFalse(CanvasExtent.slide.isContent)
        XCTAssertFalse(CanvasExtent.points(5760).isContent)
    }

    // MARK: - The canvas

    func test_canvas_defaultsToTheViewportOnBothAxes() {
        XCTAssertEqual(SlideCanvas(), .slide)
        XCTAssertEqual(SlideCanvas.slide.width, .slide)
        XCTAssertEqual(SlideCanvas.slide.height, .slide)
    }

    func test_canvas_axesAreIndependent() {
        let canvas = SlideCanvas(width: .points(5760))
        XCTAssertEqual(canvas.width, .points(5760))
        XCTAssertEqual(canvas.height, .slide, "an unspecified axis keeps the viewport's extent")
        XCTAssertNotEqual(canvas, .slide)
    }

    // MARK: - The slide

    private struct PlainSlide: Slide {
        var content: some View { EmptyView() }
    }

    private struct WideSlide: Slide {
        var canvas: SlideCanvas { .init(width: .points(5760)) }
        var content: some View { EmptyView() }
    }

    private struct TallSlide: Slide {
        var canvas: SlideCanvas { .init(height: .content) }
        var content: some View { EmptyView() }
    }

    func test_slide_canvasDefaultsToTheViewport() {
        // Every slide written before canvases existed keeps its behaviour.
        XCTAssertEqual(PlainSlide().canvas, .slide)
    }

    func test_cameraControl_followsWhetherThereIsSomewhereToGo() {
        // A slide with a canvas can be moved without the author having to
        // discover a second flag; one without a canvas gains nothing.
        XCTAssertEqual(PlainSlide().cameraControl, .scripted)
        XCTAssertEqual(WideSlide().cameraControl, .interactive)
        XCTAssertEqual(TallSlide().cameraControl, .interactive)
    }

    func test_cameraControl_canBeOverriddenInEitherDirection() {
        XCTAssertEqual(ScriptedTourSlide().cameraControl, .scripted)
        XCTAssertEqual(InteractivePlainSlide().cameraControl, .interactive)
    }

    private struct ScriptedTourSlide: Slide {
        var canvas: SlideCanvas { .init(width: .points(5760)) }
        var cameraControl: CameraControl { .scripted }
        var content: some View { EmptyView() }
    }

    private struct InteractivePlainSlide: Slide {
        var cameraControl: CameraControl { .interactive }
        var content: some View { EmptyView() }
    }

    func test_slide_declaredCanvasIsKept() {
        XCTAssertEqual(WideSlide().canvas, SlideCanvas(width: .points(5760), height: .slide))
        XCTAssertEqual(TallSlide().canvas, SlideCanvas(width: .slide, height: .content))
    }
}
