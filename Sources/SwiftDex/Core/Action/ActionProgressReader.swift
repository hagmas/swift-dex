import SwiftUI

/// Derives an action's progress from the slide timeline and registers the
/// clicks it consumes.
///
/// This is the whole of the timeline contract, with no opinion about how the
/// element looks. `ActionReader` composes it with `ElementAnimator` to give
/// the element `Apply` support; `ElementAnimator` is itself built on this
/// reader, which is what keeps the two from installing each other forever.
struct ActionProgressReader<A: Action, Content: View>: View {
    @Environment(AnySlideViewModel.self) private var slideViewModel

    let elementID: ElementID
    let clicks: Int
    let content: (ActionProgress<A>) -> Content
    let animation: ((ActionProgress<A>) -> Animation?)?

    init(
        _ type: A.Type,
        elementID: ElementID,
        clicks: Int,
        @ViewBuilder content: @escaping (ActionProgress<A>) -> Content,
        animation: ((ActionProgress<A>) -> Animation?)? = nil
    ) {
        self.elementID = elementID
        self.clicks = clicks
        self.content = content
        self.animation = animation
    }

    var body: some View {
        let progress =
            slideViewModel.actionProgress(for: elementID, type: A.self)
            ?? .idle(previous: nil, next: nil)
        content(progress)
            .onAppear {
                slideViewModel.register(clicks: clicks, for: elementID, type: A.self)
            }
            .animation(resolvedAnimation(for: progress), value: slideViewModel.currentClick)
    }
}

private extension ActionProgressReader {
    func resolvedAnimation(for progress: ActionProgress<A>) -> Animation? {
        guard slideViewModel.canBeAnimated else {
            return nil
        }
        return animation?(progress)
    }
}
