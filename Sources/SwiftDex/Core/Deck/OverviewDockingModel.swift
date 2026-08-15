import SwiftUI

/// Geometry state for docking the live presentation layer onto its grid cell
/// while the overview is presented.
///
/// Lives in an `@Observable` box (rather than view `@State`) so that per-frame
/// geometry updates — tracking the cell while the grid scrolls — only invalidate
/// the views that read them, not the whole deck surface.
@Observable
final class OverviewDockingModel {
    /// Resolved frames of the overview's grid cells, in deck coordinates.
    ///
    /// Written from preference resolution; only read inside closures and the
    /// docked layer, so updates never invalidate the deck surface itself.
    @ObservationIgnored var cellFrames = [Int: CGRect]()

    /// The live layer's frame; `nil` means full screen.
    var presentationFrame: CGRect?

    /// Moves the live layer onto the given slide's cell, if its frame is known.
    func dock(to slideNumber: Int, animated: Bool) {
        guard let rect = cellFrames[slideNumber] else {
            return
        }
        if animated {
            withAnimation(dockingAnimation) {
                presentationFrame = rect
            }
        }
        else {
            presentationFrame = rect
        }
    }

    /// Returns the live layer to full screen.
    func undock() {
        withAnimation(dockingAnimation) {
            presentationFrame = nil
        }
    }

    private var dockingAnimation: Animation {
        .spring(duration: 0.35)
    }
}

/// Positions the live presentation content according to the docking model.
///
/// This is the only view that reads `presentationFrame`, so scroll-tracking
/// updates re-render just this layer.
struct DockedPresentationLayer<Content: View>: View {
    let docking: OverviewDockingModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        let frame = docking.presentationFrame ?? CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let isDocked = docking.presentationFrame != nil
        content()
            .clipShape(RoundedRectangle(cornerRadius: isDocked ? 12 : 0))
            .shadow(radius: isDocked ? 12 : 0, y: 4)
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
    }
}
