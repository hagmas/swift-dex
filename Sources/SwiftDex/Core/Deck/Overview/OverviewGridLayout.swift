import SwiftUI

/// Places the overview's cells at the frames `OverviewGeometry` computes.
///
/// A `Layout` rather than `.position` or `.offset`, because those leave the
/// layout frame untouched: every cell would claim the whole grid, and a cell
/// that does not occupy the rectangle it is drawn in is one nothing else can
/// reason about — hit testing and accessibility included. Placing the cells
/// for real keeps the frames ours and honest at the same time.
struct OverviewGridLayout: Layout {
    let geometry: OverviewGeometry

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        geometry.contentSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (index, subview) in subviews.enumerated() {
            let frame = geometry.placementFrame(at: index)
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
}
