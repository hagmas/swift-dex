import SwiftUI

/// A single cell: the slide's thumbnail, with its number in the headroom above.
///
/// The layout hands the cell a box one padding taller than the thumbnail. That
/// headroom is what `scrollTo(_:anchor: .top)` lands against, and it keeps the
/// number off the slide it belongs to.
///
/// The cell must be exactly that box: it is placed by its top-left corner, so
/// every point it takes beyond the box moves the thumbnail off the frame the
/// rest of the overview computes for it.
struct OverviewCell: View {
    @Environment(\.colorStyle) private var colorStyle

    let index: Int
    let image: NSImage?
    let isCurrent: Bool

    /// The same arithmetic the grid and the travelling slide are drawn from.
    let geometry: OverviewGeometry

    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("\(index + 1)")
                .font(.system(size: geometry.numberFontSize, weight: .semibold, design: .monospaced))
                .foregroundStyle(colorStyle.textColor(textStyle: .body).opacity(isCurrent ? 0.9 : 0.4))
                // The gap goes inside the headroom, never on top of it: any
                // height the cell takes beyond the box it was placed in pushes
                // the thumbnail down, and the travelling slide — which trusts
                // `cellFrame` — then lands short of it.
                .padding(.bottom, geometry.numberGap)
                .frame(width: size.width, height: geometry.headroom, alignment: .bottomLeading)
            thumbnail
        }
        // Stated, not derived: the cell is exactly the box the layout placed it
        // in, whatever its contents would rather be.
        .frame(width: size.width, height: size.height + geometry.headroom, alignment: .bottom)
        .background(alignment: .bottom) {
            currentBackground
        }
    }
}

extension OverviewCell {
    var size: CGSize {
        geometry.cellSize
    }

    /// Marks the slide the presentation is on.
    ///
    /// Behind the cell rather than on it: the live slide lands exactly on the
    /// thumbnail's rectangle, so anything drawn within that rectangle ends up
    /// underneath it. Only what sits outside the rectangle survives the landing.
    var currentBackground: some View {
        let inset = geometry.currentInset
        return RoundedRectangle(cornerRadius: OverviewMetrics.cornerRadius + inset)
            .fill(colorStyle.textColor(textStyle: .body).opacity(0.12))
            .frame(
                width: size.width + 2 * inset,
                height: size.height + 2 * inset
            )
            .offset(y: inset)
            .opacity(isCurrent ? 1 : 0)
    }

    var thumbnail: some View {
        Button {
            onSelect(index)
        } label: {
            Group {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                }
                else {
                    Color.clear
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: OverviewMetrics.cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: OverviewMetrics.cornerRadius))
            .shadow(radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
