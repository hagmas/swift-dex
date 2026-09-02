import AppKit
import SwiftUI
import XCTest

@testable import SwiftDex

/// Tests the two things the overview asks of `ScrollView`, both of which fail
/// silently rather than loudly if they stop holding.
@MainActor
final class OverviewScrollTests: XCTestCase {
    private let slideNumber = 5

    /// Opening puts the current slide's row at the top of the viewport.
    func test_openingAimsTheCurrentSlidesRowAtTheTop() throws {
        let harness = try Harness(slideNumber: slideNumber)

        // And it agrees with the arithmetic: the travelling slide is positioned
        // from `topRowScroll`, so a disagreement would land it off its cell.
        let expected = harness.geometry.rowPitch
        XCTAssertEqual(harness.geometry.topRowScroll(for: slideNumber), expected)
        XCTAssertEqual(try harness.clipView.bounds.origin.y, expected)
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

    /// Reopening on the same slide must put the grid back where it was.
    ///
    /// Closing the overview unmounts the grid, so the ScrollView that comes
    /// back is a new one starting at zero. Leaving the position alone because
    /// the slide has not changed leaves it at zero, and the travelling slide —
    /// which aims at a cell in the grid's own coordinates — then flies to
    /// wherever that cell really is, which is off the surface entirely.
    func test_reopeningOnTheSameSlideRestoresTheOffset() throws {
        let harness = try Harness(slideNumber: slideNumber)
        let expected = harness.geometry.rowPitch
        XCTAssertEqual(try harness.clipView.bounds.origin.y, expected)

        harness.closeAndReopen()

        XCTAssertEqual(try harness.clipView.bounds.origin.y, expected)
        XCTAssertEqual(harness.reportedScrollY, expected)
    }

    /// What the presenter scrolled to is what they come back to.
    ///
    /// The rule keeps the position, not the row it was derived from, so a grid
    /// left part-way through a row opens part-way through that row.
    func test_reopeningRestoresWhereThePresenterScrolledTo() throws {
        let harness = try Harness(slideNumber: slideNumber)
        try harness.scroll(to: 120)

        harness.closeAndReopen()

        XCTAssertEqual(try harness.clipView.bounds.origin.y, 120)
        // And the number the travelling slide aims with is where the grid is.
        XCTAssertEqual(harness.reportedScrollY, try harness.clipView.bounds.origin.y)
    }

    /// The offset has to be read through AppKit.
    ///
    /// Scrolling on macOS moves the clip view without a SwiftUI layout pass, so
    /// a `GeometryReader` in a named coordinate space keeps reporting the offset
    /// the content was laid out at. This test is what catches that.
    func test_scrollingIsReported() throws {
        let harness = try Harness(slideNumber: slideNumber)

        try harness.scroll(to: 300)

        XCTAssertEqual(try harness.clipView.bounds.origin.y, 300)
        XCTAssertEqual(harness.reportedScrollY, 300)
    }
}

/// The grid in a real window, which is the only place a `ScrollView` scrolls.
///
/// The grid is mounted and unmounted the way the overview does it, because the
/// grid's second appearance behaves differently from its first and that is
/// where the interesting failures live.
@MainActor
private final class Harness {
    let geometry: OverviewGeometry
    let controller: DeckController

    private let hostingView: NSHostingView<AnyView>
    private let window: NSWindow
    fileprivate let state = HarnessState()

    var reportedScrollY: CGFloat {
        state.scrollY
    }

    /// The clip view of whichever ScrollView is on screen now.
    ///
    /// Looked up each time rather than held: closing the overview destroys the
    /// ScrollView, and reopening builds another one.
    var clipView: NSClipView {
        get throws {
            guard let scrollView = Harness.findScrollView(in: hostingView) else {
                throw XCTSkip("SwiftUI's ScrollView is not backed by an NSScrollView here")
            }
            return scrollView.contentView
        }
    }

    init(slideNumber: Int) throws {
        let size = ScrollDeckStyle.slideSize
        controller = DeckController(deck: ScrollDeck())
        controller.randomAccess(slideNumber: slideNumber)
        geometry = OverviewGeometry(slideSize: size, slideCount: controller.slideCount)

        let root = HarnessRoot(controller: controller, geometry: geometry, state: state)
            .frame(width: size.width, height: size.height)
            .environment(\.colorStyle, ScrollDeckStyle.colorStyle)
            .environment(\.slideSize, size)

        hostingView = NSHostingView(rootView: AnyView(root))
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
        _ = try clipView
    }

    func scroll(to offset: CGFloat) throws {
        let clipView = try clipView
        clipView.scroll(to: CGPoint(x: 0, y: offset))
        clipView.enclosingScrollView?.reflectScrolledClipView(clipView)
        hostingView.layoutSubtreeIfNeeded()
        Harness.settle()
    }

    /// Closes the overview and opens it again, as pressing `g` twice does.
    func closeAndReopen() {
        for isOpen in [false, true] {
            state.isOpen = isOpen
            hostingView.layoutSubtreeIfNeeded()
            Harness.settle()
        }
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

private final class HarnessState: ObservableObject {
    @Published var isOpen = true
    var scrollY: CGFloat = 0
    var anchor: OverviewScrollAnchor?
}

/// Mirrors how `OverviewTransitionLayer` holds the grid: present only while
/// the overview is open, so closing really does destroy the ScrollView.
private struct HarnessRoot: View {
    let controller: DeckController
    let geometry: OverviewGeometry
    @ObservedObject var state: HarnessState

    var body: some View {
        ZStack {
            if state.isOpen {
                OverviewGridView(
                    controller: controller,
                    geometry: geometry,
                    scrollY: Binding(get: { state.scrollY }, set: { state.scrollY = $0 }),
                    scrollAnchor: Binding(get: { state.anchor }, set: { state.anchor = $0 }),
                    onSelect: { _ in }
                )
            }
        }
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
