import SwiftUI

/// Every rectangle the grid overview draws.
///
/// The overview lives inside `ScaleEffectView(size: slideSize)`, so it is laid
/// out in the deck's own units and scaled to the window exactly once, at the
/// very outside. A cell and a full-screen slide therefore differ only by a
/// scale factor and a position, and both are arithmetic on the slide size.
///
/// Nothing here is measured. The grid is placed from `cellFrame(at:)` and the
/// slide flying between the two states is placed from `transitionFrame(at:)`,
/// so the two agree by construction rather than by a measurement arriving in
/// time.
struct OverviewGeometry: Equatable {
    /// The deck's slide size, which is also the size of the overview's viewport.
    var slideSize: CGSize
    var slideCount: Int
    var columnCount: Int = 4

    /// The air between columns, which also sets how wide a cell is.
    var columnSpacing: CGFloat = 64

    /// The air between rows.
    ///
    /// Deliberately less than the column spacing. A row is separated from the
    /// next by this *plus* the number strip, and a small grey numeral does not
    /// fill its strip the way a thumbnail fills a column — so matching the two
    /// numbers makes the rows read as the looser of the two.
    var rowSpacing: CGFloat = 48

    /// The grid's side and bottom margins.
    ///
    /// The top margin is `headroom`, which carries a row's number with it.
    var margin: CGFloat = 64

    /// The size a cell's number is set at.
    var numberFontSize: CGFloat = OverviewMetrics.numberFontSize

    /// The gap between a number and the cell it labels.
    var numberGap: CGFloat = OverviewMetrics.numberGap

    /// How far the current slide's backing extends beyond its cell.
    ///
    /// It has to clear the number above it: the number's gap is measured to the
    /// cell, and the backing takes part of that gap back. Half the row spacing
    /// at most, so two rows' backings cannot meet.
    var currentInset: CGFloat = 16

    /// The strip above a cell that its number is written in.
    ///
    /// Added to the row's period rather than taken out of the row spacing: a
    /// number sharing the spacing would eat two thirds of it, and the rows
    /// would close up as soon as the numbers appeared.
    ///
    /// Rounded up to a whole unit, because the grid is laid out in one system
    /// of coordinates and scrolled in another: AppKit rounds the offset it
    /// scrolls to, and a fractional row period would leave the travelling
    /// slide aiming a fraction away from where its cell actually is.
    var numberHeight: CGFloat {
        (OverviewMetrics.numberLineHeight(size: numberFontSize) + numberGap).rounded(.up)
    }

    /// What a cell is placed with above it: its number, and the spacing.
    ///
    /// It doubles as the grid's top margin, so a row sent to the top of the
    /// viewport sits exactly as the first row sits at the top of the grid.
    var headroom: CGFloat {
        rowSpacing + numberHeight
    }

    /// The frame a slide occupies while it is being presented.
    var presentedFrame: CGRect {
        CGRect(origin: .zero, size: slideSize)
    }

    var cellSize: CGSize {
        let available = slideSize.width - 2 * margin - CGFloat(columnCount - 1) * columnSpacing
        let width = max(0, available / CGFloat(columnCount))
        let height = slideSize.width > 0 ? width * slideSize.height / slideSize.width : 0
        return CGSize(width: width, height: height)
    }

    /// How far down the grid one row is from the next.
    var rowPitch: CGFloat {
        cellSize.height + headroom
    }

    var rowCount: Int {
        guard slideCount > 0 else {
            return 0
        }
        return (slideCount + columnCount - 1) / columnCount
    }

    /// The size of the scrollable grid, of which the viewport shows `slideSize`.
    var contentSize: CGSize {
        guard rowCount > 0 else {
            return CGSize(width: slideSize.width, height: 0)
        }
        return CGSize(width: slideSize.width, height: CGFloat(rowCount) * rowPitch + margin)
    }

    /// A cell's frame in the grid's own (scrollable) coordinates.
    func cellFrame(at index: Int) -> CGRect {
        let column = index % columnCount
        let row = index / columnCount
        let size = cellSize
        return CGRect(
            x: margin + CGFloat(column) * (size.width + columnSpacing),
            y: headroom + CGFloat(row) * rowPitch,
            width: size.width,
            height: size.height
        )
    }

    /// The frame a cell is *placed* at, which is its own frame plus its headroom.
    ///
    /// `scrollTo(_:anchor: .top)` can only align a view's top edge with the
    /// viewport's top edge, so the headroom is what carries the number and the
    /// margin along with the row that lands there.
    func placementFrame(at index: Int) -> CGRect {
        let frame = cellFrame(at: index)
        return CGRect(
            x: frame.minX,
            y: frame.minY - headroom,
            width: frame.width,
            height: frame.height + headroom
        )
    }

    /// A cell's frame as it appears in the viewport, given how far the grid is scrolled.
    func viewportFrame(at index: Int, scrollY: CGFloat) -> CGRect {
        cellFrame(at: index).offsetBy(dx: 0, dy: -scrollY)
    }

    /// Where the grid scrolls to when the overview opens on a given slide.
    ///
    /// The rule is one line: put that slide's row at the top, as far as the
    /// grid can actually scroll. The clamp is not a special case for the end of
    /// the deck — it *is* the "there is nothing left below" behaviour.
    func topRowScroll(for index: Int) -> CGFloat {
        let maxScroll = max(0, contentSize.height - slideSize.height)
        return min(max(0, placementFrame(at: index).minY), maxScroll)
    }

    /// Where the slide travelling between the two states sits.
    ///
    /// `progress` is 0 while presenting and 1 once the overview has settled;
    /// the whole transition is this one number moving.
    func transitionFrame(at index: Int, scrollY: CGFloat, progress: Double) -> CGRect {
        let target = viewportFrame(at: index, scrollY: scrollY)
        let start = presentedFrame
        return CGRect(
            x: start.minX.lerp(to: target.minX, progress),
            y: start.minY.lerp(to: target.minY, progress),
            width: start.width.lerp(to: target.width, progress),
            height: start.height.lerp(to: target.height, progress)
        )
    }
}

extension CGFloat {
    fileprivate func lerp(to other: CGFloat, _ t: Double) -> CGFloat {
        self + (other - self) * t
    }
}
