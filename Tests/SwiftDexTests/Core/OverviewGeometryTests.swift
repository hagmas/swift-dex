import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests for the arithmetic the grid overview is drawn from.
///
/// The point of the type is that the grid and the slide travelling in and out
/// of it read the same numbers, so the numbers themselves are what is worth
/// pinning down.
final class OverviewGeometryTests: XCTestCase {
    private let slideSize = CGSize(width: 1920, height: 1080)

    /// Two rows, and short enough that the grid does not scroll.
    private func shortGrid(slideCount: Int = 8) -> OverviewGeometry {
        OverviewGeometry(slideSize: slideSize, slideCount: slideCount)
    }

    /// Five rows, which overflow the viewport.
    private func tallGrid() -> OverviewGeometry {
        OverviewGeometry(slideSize: slideSize, slideCount: 20)
    }

    // MARK: - Cells

    func test_cellSize_dividesTheViewportAndKeepsTheSlidesAspect() {
        // 1920 less the two margins and the three gaps, over four columns.
        XCTAssertEqual(shortGrid().cellSize, CGSize(width: 400, height: 225))
    }

    func test_cellFrame_walksColumnsThenRows() {
        let geometry = shortGrid()
        XCTAssertEqual(geometry.cellFrame(at: 0).origin, CGPoint(x: 64, y: geometry.headroom))
        XCTAssertEqual(geometry.cellFrame(at: 3).origin, CGPoint(x: 1456, y: geometry.headroom))
        XCTAssertEqual(
            geometry.cellFrame(at: 4).origin,
            CGPoint(x: 64, y: geometry.headroom + geometry.rowPitch)
        )
        XCTAssertEqual(geometry.cellFrame(at: 4).size, geometry.cellSize)
    }

    func test_rowPitch_makesRoomForTheNumberOnTopOfTheSpacing() {
        // The number is added to the row's period rather than taken out of the
        // row spacing, so the air between rows survives the numbers appearing.
        let geometry = shortGrid()
        XCTAssertEqual(geometry.headroom - geometry.numberHeight, geometry.rowSpacing)
        XCTAssertEqual(geometry.rowPitch, geometry.cellSize.height + geometry.headroom)
        XCTAssertEqual(geometry.cellFrame(at: 4).minY - geometry.cellFrame(at: 0).maxY, geometry.headroom)
    }

    func test_numberStrip_isTheLineItIsSetOnPlusItsGap() {
        // Font-derived, so that changing the size or the gap moves the rows
        // rather than quietly eating into the spacing.
        let geometry = shortGrid()
        XCTAssertEqual(geometry.numberHeight, 55, "a 33pt line and a 22pt gap, rounded to a whole unit")
        XCTAssertEqual(geometry.headroom, 103)
        XCTAssertEqual(geometry.rowPitch, 328)
    }

    func test_contentSize_isTheRowsPlusTheBottomMargin() {
        let geometry = shortGrid()
        XCTAssertEqual(geometry.rowCount, 2)
        XCTAssertEqual(geometry.contentSize.width, 1920)
        XCTAssertEqual(geometry.contentSize.height, 2 * geometry.rowPitch + geometry.margin)
    }

    func test_emptyDeck_hasNoRows() {
        let geometry = shortGrid(slideCount: 0)
        XCTAssertEqual(geometry.rowCount, 0)
        XCTAssertEqual(geometry.contentSize.height, 0)
    }

    // MARK: - Scroll headroom

    func test_placementFrame_addsTheHeadroomAboveTheCell() {
        // What `scrollTo(_:anchor: .top)` aims at, so that the row landing at
        // the top of the viewport keeps the grid's margin above it.
        let geometry = shortGrid()
        XCTAssertEqual(
            geometry.placementFrame(at: 0),
            CGRect(x: 64, y: 0, width: 400, height: geometry.rowPitch)
        )
        XCTAssertEqual(
            geometry.placementFrame(at: 4),
            CGRect(x: 64, y: geometry.rowPitch, width: 400, height: geometry.rowPitch)
        )
    }

    func test_placementFrames_tileWithoutOverlapping() {
        let geometry = tallGrid()
        for row in 1..<geometry.rowCount {
            let previous = geometry.placementFrame(at: (row - 1) * geometry.columnCount)
            let current = geometry.placementFrame(at: row * geometry.columnCount)
            XCTAssertEqual(previous.maxY, current.minY)
        }
    }

    // MARK: - Where opening the overview scrolls to

    func test_topRowScroll_putsTheSlidesRowAtTheTop() {
        let geometry = tallGrid()
        XCTAssertEqual(geometry.topRowScroll(for: 0), 0)
        XCTAssertEqual(geometry.topRowScroll(for: 4), geometry.rowPitch)
        XCTAssertEqual(geometry.topRowScroll(for: 7), geometry.rowPitch, "the whole row travels together")
    }

    func test_topRowScroll_stopsAtTheEndOfTheGrid() {
        // The last rows cannot reach the top: there is nothing below to pull up.
        let geometry = tallGrid()
        let maxScroll = geometry.contentSize.height - slideSize.height
        XCTAssertEqual(maxScroll, 624)
        XCTAssertEqual(geometry.topRowScroll(for: 16), maxScroll)
        XCTAssertEqual(geometry.topRowScroll(for: 19), maxScroll)
    }

    func test_topRowScroll_isZeroWhenTheGridFitsTheViewport() {
        let geometry = shortGrid()
        XCTAssertLessThan(geometry.contentSize.height, slideSize.height)
        XCTAssertEqual(geometry.topRowScroll(for: 0), 0)
        XCTAssertEqual(geometry.topRowScroll(for: 7), 0)
    }

    // MARK: - The travelling slide

    func test_transitionFrame_startsOnTheFullSurface() {
        let geometry = tallGrid()
        XCTAssertEqual(
            geometry.transitionFrame(at: 7, scrollY: geometry.rowPitch, progress: 0),
            CGRect(origin: .zero, size: slideSize)
        )
    }

    func test_transitionFrame_endsOnTheCell() {
        let geometry = tallGrid()
        XCTAssertEqual(
            geometry.transitionFrame(at: 7, scrollY: geometry.rowPitch, progress: 1),
            geometry.viewportFrame(at: 7, scrollY: geometry.rowPitch)
        )
    }

    func test_viewportFrame_followsTheScroll() {
        let geometry = tallGrid()
        XCTAssertEqual(
            geometry.viewportFrame(at: 4, scrollY: geometry.rowPitch),
            CGRect(x: 64, y: geometry.headroom, width: 400, height: 225)
        )
    }

    func test_transitionFrame_interpolatesInBetween() {
        let geometry = tallGrid()
        let half = geometry.transitionFrame(at: 4, scrollY: geometry.rowPitch, progress: 0.5)
        XCTAssertEqual(half.minX, 32)
        XCTAssertEqual(half.minY, geometry.headroom / 2)
        XCTAssertEqual(half.width, 1160)
        XCTAssertEqual(half.height, 652.5)
    }
}
