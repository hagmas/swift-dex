import SwiftUI

/// A view that displays multiple views split into steps.
///
/// Used in combination with the `FlipByItem` Action, it allows displaying multiple views provided as `content` in a "flip" manner.
public struct Flipper: View {
    @Environment(AnySlideViewModel.self) private var slideViewModel
    @State private var index: Int?

    private let content: [AnyView]
    private let transition: AnyTransition
    private let animation: Animation?

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///     - transition: A `transition` applied to each items.
    ///     - animation: An animation that is applied to the specified `transition`.
    ///     - content: A `@FlipperBuilder` closure returning an array of views to be displayed.
    public init(
        transition: AnyTransition = .identity,
        animation: Animation? = nil,
        @FlipperBuilder content: @escaping () -> [AnyView]
    ) {
        self.content = content()
        self.transition = transition
        self.animation = animation
    }

    /// The content and behavior of the view.
    ///
    /// The first item is the resting state, so `FlipByItem` consumes one click per
    /// *transition*: N items flip in N − 1 clicks, and every click produces a
    /// visible change.
    ///
    /// The displayed index mirrors the model-derived index through local state so the
    /// change happens inside a `withAnimation` transaction — insertion/removal
    /// transitions do not animate reliably from `.animation(_:value:)` alone.
    /// Contexts that never fire `onChange` (thumbnail rendering) fall back to the
    /// derived index directly.
    public var body: some View {
        ActionReader(FlipByItem.self, clicks: max(1, content.count - 1)) { progress in
            let targetIndex = currentIndex(for: progress)
            let displayIndex = index ?? targetIndex
            content[displayIndex]
                .id(displayIndex)
                .transition(transition)
                .onChange(of: targetIndex, initial: true) { _, newIndex in
                    withAnimation(slideViewModel.canBeAnimated ? animation : nil) {
                        index = newIndex
                    }
                }
        }
    }
}

private extension Flipper {
    func currentIndex(for progress: ActionProgress<FlipByItem>) -> Int {
        switch progress {
        case .idle(let previous, _):
            previous != nil ? content.count - 1 : 0

        case .active(_, let step):
            min(step, content.count - 1)

        case .completed:
            content.count - 1
        }
    }
}
