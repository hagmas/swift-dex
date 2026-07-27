import SwiftUI

/// A view that reads the progress of an `Action` and renders content from it.
///
/// `ActionReader` is the entry point for building a view that responds to an action.
/// It declares how many clicks the action consumes on the slide timeline (`clicks`),
/// registers that count with the slide, and hands the derived `ActionProgress` to the
/// content closure. There is no lifecycle to manage: progress is derived from the
/// slide's click position, and completion is known to the timeline up front.
///
/// A step-driven action (`clicks > 1`) progresses through `active(current:step:)` with
/// the sub-step counting from `1` to `clicks`, then completes. A one-shot action
/// (`clicks == 1`) completes on the click that activates it.
public struct ActionReader<A: Action, Content: View>: View {
    @Environment(\.elementID) private var elementID: ElementID
    @Environment(AnySlideViewModel.self) private var slideViewModel

    private let clicks: Int
    private let content: (ActionProgress<A>) -> Content
    private let animation: ((ActionProgress<A>) -> Animation?)?

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - type: The `Action` type this view responds to.
    ///   - clicks: The number of clicks the action consumes on the slide timeline.
    ///   - content: A closure that renders the content for the current `ActionProgress`.
    ///   - animation: An optional closure that resolves the `Animation` used when the
    ///     progress changes. The animation is suppressed when the slide state does not
    ///     allow animations.
    public init(
        _ type: A.Type,
        clicks: Int,
        @ViewBuilder content: @escaping (ActionProgress<A>) -> Content,
        animation: ((ActionProgress<A>) -> Animation?)? = nil
    ) {
        self.clicks = clicks
        self.content = content
        self.animation = animation
    }

    /// The content and behavior of the view.
    public var body: some View {
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

private extension ActionReader {
    func resolvedAnimation(for progress: ActionProgress<A>) -> Animation? {
        guard slideViewModel.canBeAnimated else {
            return nil
        }
        return animation?(progress)
    }
}
