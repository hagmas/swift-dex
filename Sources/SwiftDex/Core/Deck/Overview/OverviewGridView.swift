import SwiftUI

/// The scrollable grid of slide thumbnails.
///
/// The cells are placed by `OverviewGridLayout` from `OverviewGeometry`, so
/// the grid and the slide travelling in and out of it agree on where a cell is
/// without either of them measuring the other. Scrolling itself is left to
/// `ScrollView`, which is what makes the rubber band, the momentum and the
/// indicators the ones the platform draws everywhere else.
struct OverviewGridView: View {
    let controller: DeckController
    let geometry: OverviewGeometry

    /// How far the grid is scrolled, published for the travelling slide.
    @Binding var scrollY: CGFloat

    /// Where the grid should be when it next opens, and which slide that was
    /// decided for.
    ///
    /// Opening re-aims the scroll only when the slide no longer matches — that
    /// is, when the presentation moved on while the overview was closed.
    /// Coming straight back from a cell the presenter picked leaves the grid
    /// exactly where they left it.
    @Binding var scrollAnchor: OverviewScrollAnchor?

    let onSelect: (Int) -> Void

    /// The offset the grid is put at when it opens.
    @State private var position = ScrollPosition()

    var body: some View {
        ScrollView {
            OverviewGridLayout(geometry: geometry) {
                ForEach(0..<controller.slideCount, id: \.self) { index in
                    OverviewCell(
                        index: index,
                        image: controller.thumbnails[index],
                        isCurrent: index == controller.slideNumber,
                        geometry: geometry,
                        onSelect: onSelect
                    )
                }
            }
        }
        .scrollPosition($position)
        // Scrolling on macOS moves the clip view without running a SwiftUI
        // layout pass, so the offset has to be asked for rather than measured:
        // a `GeometryReader` in a named coordinate space keeps reporting where
        // the content was laid out and never hears about the scroll at all.
        .onScrollGeometryChange(for: CGFloat.self) { scrollGeometry in
            scrollGeometry.contentOffset.y
        } action: { _, offset in
            scrollY = offset
        }
        .onAppear {
            open()
        }
        .onDisappear {
            // Remember where the grid ended up, while the number still means
            // something: the next ScrollView reports its own zero before
            // anything else runs, so this cannot be read on the way back in.
            scrollAnchor?.offset = scrollY
        }
    }
}

/// The grid's position, kept across the overview being closed.
struct OverviewScrollAnchor: Equatable {
    /// The slide the offset was decided for.
    var slideNumber: Int
    var offset: CGFloat
}

private extension OverviewGridView {
    /// Puts the grid where it should be for the slide being presented.
    ///
    /// The grid exists only while the overview does, so appearing is the moment
    /// it opens — and the ScrollView that appears with it is always a new one,
    /// starting at zero. The offset therefore has to be *applied* every time,
    /// even when the rule says it has not changed: remembering a position is
    /// not the same as the grid still being at it.
    ///
    /// That new ScrollView also announces its zero before this runs, which is
    /// why the position worth keeping lives in the anchor rather than in the
    /// live readout — the readout has already been overwritten by then.
    func open() {
        if scrollAnchor?.slideNumber != controller.slideNumber {
            scrollAnchor = OverviewScrollAnchor(
                slideNumber: controller.slideNumber,
                offset: geometry.topRowScroll(for: controller.slideNumber)
            )
        }
        let offset = scrollAnchor?.offset ?? 0
        // The travelling slide needs the number this very frame, and it is not
        // whatever the fresh ScrollView has already reported.
        scrollY = offset
        // Unanimated: the grid is fading in, and the presenter should never see
        // it travel to where it starts.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            position.scrollTo(y: offset)
        }
    }
}

enum OverviewMetrics {
    /// The corner radius of a cell, in slide units.
    static let cornerRadius: CGFloat = 16

    /// The size a cell's number is set at, in slide units.
    static let numberFontSize: CGFloat = 28

    /// The gap between a number and the cell it labels.
    ///
    /// Measured to the cell, so it has to clear the backing the current slide
    /// wears as well — which reaches `currentInset` above the cell.
    static let numberGap: CGFloat = 22

    /// The height a number's line occupies at the given size.
    ///
    /// Measured rather than guessed: it is added to the row's period, so a
    /// wrong value here shifts every row's breathing space.
    static func numberLineHeight(size: CGFloat) -> CGFloat {
        let font = NSFont.monospacedSystemFont(ofSize: size, weight: .semibold)
        return font.ascender - font.descender
    }
}
