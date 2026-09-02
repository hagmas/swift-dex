import SwiftUI

/// The layer the transition travels on.
///
/// `Animatable` so that `progress` is interpolated frame by frame and the body
/// is rebuilt from it: that is what lets the grid be structurally absent while
/// the overview is closed, rather than merely invisible.
struct OverviewTransitionLayer<Grid: View, Presentation: View>: View, Animatable {
    var progress: Double

    let geometry: OverviewGeometry
    let slideNumber: Int
    let scrollY: CGFloat
    let backgroundColor: Color

    /// The current slide's thumbnail — the same image its cell draws.
    let thumbnail: NSImage?

    // Built by the caller and held as values: rebuilding this body every frame
    // must not rebuild the presentation inside it.
    let grid: Grid
    let presentation: Presentation

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isEngaged {
                ZStack {
                    backgroundColor
                    grid
                }
                .opacity(progress)
            }
            travellingSlide
        }
        .frame(width: geometry.slideSize.width, height: geometry.slideSize.height)
    }
}

extension OverviewTransitionLayer {
    /// Whether the overview is on screen at all.
    ///
    /// A threshold rather than `> 0` because a spring can settle through zero;
    /// crossing it is what mounts and unmounts the grid.
    var isEngaged: Bool {
        progress > 0.001
    }

    /// Whether the trip is over and the grid has the slide.
    ///
    /// By this point the travelling layer is showing the very image its cell is
    /// showing, at the very rectangle the cell occupies, so dropping it is not
    /// a visible event. Which is what lets the settled overview be an ordinary
    /// scrolling grid: the current slide is a cell like every other, scrolled
    /// and clipped with them, rather than a live layer that would have to chase
    /// the scroll and would keep drawing once its cell had left the viewport.
    var isHandedOver: Bool {
        progress >= 0.999
    }

    /// How visible the live slide is *within* the travelling layer.
    ///
    /// It gives way to its own thumbnail at the end of the trip. The two are
    /// stacked in the same layer, at the same rectangle, so the cross-fade has
    /// no geometry to disagree about. Fading the layer against the cell instead
    /// doubles the image: the layer is still larger than the cell right up
    /// until it lands.
    ///
    /// Late rather than early, because a thumbnail is only the size of a cell
    /// and is visibly soft when it is blown up to the whole surface.
    var liveOpacity: Double {
        let handover = 0.85
        guard progress > handover else {
            return 1
        }
        return max(0, 1 - (progress - handover) / (1 - handover))
    }

    var travellingSlide: some View {
        // Clamped: a spring can carry the number past its target, and the trip
        // has no meaning beyond its two ends.
        let trip = min(max(progress, 0), 1)
        let frame = geometry.transitionFrame(at: slideNumber, scrollY: scrollY, progress: trip)
        let scale = geometry.slideSize.width > 0 ? frame.width / geometry.slideSize.width : 1
        // The slide is clipped in its own coordinates and scaled afterwards, so
        // the radius has to be divided back out to land at the cell's.
        let cornerRadius = scale > 0 ? OverviewMetrics.cornerRadius * trip / scale : 0

        return
            presentation
            .opacity(liveOpacity)
            .background {
                // A slot of its own rather than a sibling in a stack, so that
                // mounting it cannot disturb the live slide's identity.
                if isEngaged, let thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                }
            }
            .frame(width: geometry.slideSize.width, height: geometry.slideSize.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(scale, anchor: .topLeading)
            .offset(x: frame.minX, y: frame.minY)
            .opacity(isHandedOver ? 0 : 1)
            // While the overview is up, taps belong to the cells underneath.
            .allowsHitTesting(!isEngaged)
    }
}
