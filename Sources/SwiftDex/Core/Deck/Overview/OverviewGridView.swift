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

    /// The slide the current scroll position was established for.
    ///
    /// Opening the overview re-aims the scroll only when this no longer
    /// matches the current slide — that is, when the slide moved on while the
    /// overview was closed. Coming straight back from a cell the presenter
    /// picked leaves the grid exactly where they left it.
    @Binding var scrollAnchorSlide: Int?

    let onSelect: (Int) -> Void

    var body: some View {
        ScrollViewReader { proxy in
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
                        .id(index)
                    }
                }
            }
            // Scrolling on macOS moves the clip view without running a
            // SwiftUI layout pass, so the offset has to be asked for rather
            // than measured: a `GeometryReader` in a named coordinate space
            // keeps reporting where the content was laid out and never hears
            // about the scroll at all.
            .onScrollGeometryChange(for: CGFloat.self) { scrollGeometry in
                scrollGeometry.contentOffset.y
            } action: { _, offset in
                scrollY = offset
            }
            .onAppear {
                // The grid exists only while the overview does, so appearing is
                // the moment it opens.
                guard scrollAnchorSlide != controller.slideNumber else {
                    return
                }
                scrollAnchorSlide = controller.slideNumber
                // Set the offset as well as asking for it. `scrollTo` moves the
                // ScrollView, but the travelling slide needs the number this
                // very frame, and the rule says exactly what it will be — so it
                // is computed rather than waited for.
                scrollY = geometry.topRowScroll(for: controller.slideNumber)
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    proxy.scrollTo(controller.slideNumber, anchor: .top)
                }
            }
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
