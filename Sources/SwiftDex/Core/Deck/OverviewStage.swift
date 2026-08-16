import SwiftUI

/// Hosts a deck surface's two performance states — the live presentation and
/// the grid overview — and orchestrates the matched-geometry transition
/// between them.
///
/// The transition travels on a layer that stacks the live presentation over
/// the current slide's thumbnail. While presenting, the layer fills the
/// surface and the thumbnail is covered. Opening the overview shrinks the
/// layer onto the current slide's cell, cross-fading the live surface out so
/// the thumbnail lands pixel-aligned with the cell; the layer then hides
/// entirely. Closing runs the same choreography in reverse.
struct OverviewStage<Presentation: View>: View {
    let controller: DeckController
    @ViewBuilder let presentation: () -> Presentation

    @Namespace private var namespace

    // Visible except while the overview is settled open.
    @State private var isTransitionLayerVisible = true
    // The live surface, cross-faded against the thumbnail mid-transition.
    @State private var isPresentationVisible = true

    var body: some View {
        ZStack {
            DeckOverviewView(
                controller: controller,
                namespace: namespace
            ) { index in
                controller.select(slideNumber: index)
            }

            // While the overview is closed the cells all carry inactive ids,
            // so this is a source with no followers — completely inert during
            // normal slide navigation.
            transitionLayer
                .matchedGeometryEffect(
                    id: OverviewMatchID.slide(controller.slideNumber),
                    in: namespace,
                    isSource: !controller.isOverviewPresented
                )
                .allowsHitTesting(!controller.isOverviewPresented)
                .opacity(isTransitionLayerVisible ? 1 : 0)
        }
        .onChange(of: controller.isOverviewPresented) { _, isPresented in
            if isPresented {
                // Slide → Overview: let the matched geometry animate, then
                // hide the layer so the grid can scroll freely beneath it.
                withAnimation(controller.overviewAnimation) {
                    isPresentationVisible = false
                } completion: {
                    withAnimation {
                        isTransitionLayerVisible = false
                    }
                }
            }
            else {
                // Overview → Slide: reappear at the cell showing only the
                // thumbnail (identical to the cell), then fade the live
                // surface in while the layer expands.
                isTransitionLayerVisible = true
                isPresentationVisible = false
                withAnimation(controller.overviewAnimation) {
                    isPresentationVisible = true
                }
            }
        }
        .background {
            keyboardControls
        }
    }
}

private extension OverviewStage {
    var transitionLayer: some View {
        ZStack {
            if let image = controller.thumbnails[controller.slideNumber] {
                Image(nsImage: image)
                    .resizable()
            }
            presentation()
                .opacity(isPresentationVisible ? 1 : 0)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: controller.isOverviewPresented ? 12 : 0)
        )
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
            Button("") {
                controller.randomAccess(slideNumber: controller.slideNumber - 1)
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            Button("") {
                controller.randomAccess(slideNumber: controller.slideNumber + 1)
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
