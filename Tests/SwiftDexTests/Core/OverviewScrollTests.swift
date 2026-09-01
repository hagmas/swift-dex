import AppKit
import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests the two things the overview asks of `ScrollView`, both of which fail
/// silently rather than loudly if they stop holding.
@MainActor
final class OverviewScrollTests: XCTestCase {
    private let slideNumber = 5

    /// The grid must be aimable by identity even though a `Layout` places the
    /// cells: `scrollTo` works off layout frames, which is the whole reason the
    /// cells are placed rather than offset.
    func test_openingAimsTheCurrentSlidesRowAtTheTop() throws {
        let harness = try Harness(slideNumber: slideNumber)

        // And it agrees with the arithmetic: the travelling slide is positioned
        // from `topRowScroll`, so a disagreement would land it off its cell.
        let expected = harness.geometry.rowPitch
        XCTAssertEqual(harness.geometry.topRowScroll(for: slideNumber), expected)
        XCTAssertEqual(harness.clipView.bounds.origin.y, expected)
        XCTAssertEqual(harness.reportedScrollY, expected)
    }

    /// A cell that is taller than the box it was placed in pushes its thumbnail
    /// down, because the layout places cells by their top-left corner — and the
    /// travelling slide, which aims at `cellFrame`, then lands short of it.
    func test_aCellIsExactlyTheBoxItIsPlacedIn() {
        let geometry = OverviewGeometry(slideSize: ScrollDeckStyle.slideSize, slideCount: 20)
        let cell = OverviewCell(
            index: 0,
            image: nil,
            isCurrent: false,
            geometry: geometry,
            onSelect: { _ in }
        )
        let hostingView = NSHostingView(rootView: AnyView(cell))

        XCTAssertEqual(hostingView.fittingSize.width, geometry.cellSize.width)
        XCTAssertEqual(hostingView.fittingSize.height, geometry.placementFrame(at: 0).height)
    }

    /// The offset has to be read through AppKit.
    ///
    /// Scrolling on macOS moves the clip view without a SwiftUI layout pass, so
    /// a `GeometryReader` in a named coordinate space keeps reporting the offset
    /// the content was laid out at. This test is what catches that.
    func test_scrollingIsReported() throws {
        let harness = try Harness(slideNumber: slideNumber)

        harness.scroll(to: 300)

        XCTAssertEqual(harness.clipView.bounds.origin.y, 300)
        XCTAssertEqual(harness.reportedScrollY, 300)
    }
}

/// The grid in a real window, which is the only place a `ScrollView` scrolls.
@MainActor
private final class Harness {
    let geometry: OverviewGeometry
    let clipView: NSClipView

    private let hostingView: NSHostingView<AnyView>
    private let window: NSWindow
    private let state = State()

    var reportedScrollY: CGFloat {
        state.scrollY
    }

    private final class State {
        var scrollY: CGFloat = 0
        var anchor: Int?
    }

    init(slideNumber: Int) throws {
        let size = ScrollDeckStyle.slideSize
        let controller = DeckController(deck: ScrollDeck())
        controller.randomAccess(slideNumber: slideNumber)
        geometry = OverviewGeometry(slideSize: size, slideCount: controller.slideCount)

        let state = self.state
        let grid = OverviewGridView(
            controller: controller,
            geometry: geometry,
            scrollY: Binding(get: { state.scrollY }, set: { state.scrollY = $0 }),
            scrollAnchorSlide: Binding(get: { state.anchor }, set: { state.anchor = $0 }),
            onSelect: { _ in }
        )
        .frame(width: size.width, height: size.height)
        .environment(\.colorStyle, ScrollDeckStyle.colorStyle)
        .environment(\.slideSize, size)

        hostingView = NSHostingView(rootView: AnyView(grid))
        hostingView.frame = CGRect(origin: .zero, size: size)
        window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        hostingView.layoutSubtreeIfNeeded()
        Harness.settle()

        guard let scrollView = Harness.findScrollView(in: hostingView) else {
            throw XCTSkip("SwiftUI's ScrollView is not backed by an NSScrollView here")
        }
        clipView = scrollView.contentView
    }

    func scroll(to offset: CGFloat) {
        clipView.scroll(to: CGPoint(x: 0, y: offset))
        clipView.enclosingScrollView?.reflectScrolledClipView(clipView)
        hostingView.layoutSubtreeIfNeeded()
        Harness.settle()
    }

    /// Lets the window server lay the hierarchy out and the notifications land.
    private static func settle() {
        let deadline = Date().addingTimeInterval(0.5)
        while Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
        }
    }

    private static func findScrollView(in view: NSView) -> NSScrollView? {
        if let scrollView = view as? NSScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let found = findScrollView(in: subview) {
                return found
            }
        }
        return nil
    }
}

private struct ScrollDeckStyle: DeckStyle {}

/// Twenty slides: five rows, which is more than the viewport holds.
private struct ScrollDeck: Deck {
    typealias Style = ScrollDeckStyle

    var flow: some Flow {
        ScrollSlide().next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide())
            .next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide())
            .next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide())
            .next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide()).next(ScrollSlide())
    }
}

private struct ScrollSlide: Slide {
    var content: some View {
        Color.clear
    }
}
