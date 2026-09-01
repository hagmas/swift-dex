import SwiftUI

/// Hosts a deck surface's two performance states — the live presentation and
/// the grid overview — and the travel between them.
///
/// The whole transition is one number. `progress` is 0 while presenting and 1
/// once the overview has settled, and every frame in between is arithmetic on
/// it: the live slide's rectangle is interpolated from the full surface to its
/// cell, and the grid exists only while the number is above zero. Nothing is
/// measured, nothing is cross-faded, and a closed overview costs one comparison.
struct OverviewStage<Presentation: View>: View {
    @Environment(\.slideSize) private var slideSize
    @Environment(\.colorStyle) private var colorStyle

    let controller: DeckController
    @ViewBuilder let presentation: () -> Presentation

    /// How far the grid is scrolled, in slide units.
    ///
    /// Written by the grid while the presenter scrolls, and written here when
    /// the overview opens — where the position is not read but decided.
    @State private var scrollY: CGFloat = 0
    @State private var scrollAnchorSlide: Int?

    var body: some View {
        OverviewTransitionLayer(
            progress: controller.isOverviewPresented ? 1 : 0,
            geometry: geometry,
            slideNumber: controller.slideNumber,
            scrollY: scrollY,
            backgroundColor: colorStyle.backgroundColor,
            thumbnail: controller.thumbnails[controller.slideNumber],
            grid: grid,
            presentation: presentation()
        )
        .background {
            keyboardControls
        }
    }
}

private extension OverviewStage {
    var geometry: OverviewGeometry {
        OverviewGeometry(slideSize: slideSize, slideCount: controller.slideCount)
    }

    var grid: some View {
        OverviewGridView(
            controller: controller,
            geometry: geometry,
            scrollY: $scrollY,
            scrollAnchorSlide: $scrollAnchorSlide,
            onSelect: select
        )
    }

    /// Jumps to a slide the presenter picked out of the grid.
    ///
    /// The scroll anchor moves with it, so the cell they tapped is still under
    /// their cursor if they open the overview again: coming straight back is
    /// the one case where the grid must not re-aim.
    func select(slideNumber: Int) {
        scrollAnchorSlide = slideNumber
        controller.select(slideNumber: slideNumber)
    }

    @ViewBuilder
    var keyboardControls: some View {
        Button("") {
            controller.toggleOverview()
        }
        .keyboardShortcut("g", modifiers: [])
        if controller.isOverviewPresented {
            Button("") {
                controller.toggleOverview()
            }
            .keyboardShortcut(.cancelAction)
        }
    }
}
