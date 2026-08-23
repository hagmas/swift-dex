import SwiftUI

/// A view that reads the progress of an `Action` and renders content from it.
///
/// `ActionReader` is the entry point for building a view that responds to an action.
/// It declares which element the action targets (`elementID`) and how many clicks it
/// consumes on the slide timeline (`clicks`), registers that count with the slide, and
/// hands the derived `ActionProgress` to the content closure. There is no lifecycle to
/// manage: progress is derived from the slide's click position, and completion is known
/// to the timeline up front.
///
/// A step-driven action (`clicks > 1`) progresses through `active(current:step:)` with
/// the sub-step counting from `1` to `clicks`, then completes. A one-shot action
/// (`clicks == 1`) completes on the click that activates it.
///
/// Carrying an `ElementID` also makes the element a target of the `Apply` action and
/// publishes its bounds for `Zoom` and `Highlight` — a view that consumes an action of
/// its own can be faded or moved without doing anything for it. A view takes the
/// identity in its initializer, so it is visible at the call site rather than inherited
/// from an ancestor:
///
/// ```swift
/// public struct Ticker: View {
///     private let elementID: ElementID
///
///     public init(elementID: ElementID = .none) {
///         self.elementID = elementID
///     }
///
///     public var body: some View {
///         ActionReader(Tick.self, elementID: elementID, clicks: 3) { progress in
///             // ...
///         }
///     }
/// }
/// ```
public struct ActionReader<A: Action, Content: View>: View {
    private let elementID: ElementID
    private let clicks: Int
    private let content: (ActionProgress<A>) -> Content
    private let animation: ((ActionProgress<A>) -> Animation?)?

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - type: The `Action` type this view responds to.
    ///   - elementID: The element the action targets. Pass `.none` — the default for a
    ///     view that was given no identity — when the reader is not bound to one
    ///     element, in which case no action of this type ever activates and the element
    ///     is neither an `Apply` target nor addressable by `Zoom` or `Highlight`.
    ///   - clicks: The number of clicks the action consumes on the slide timeline.
    ///   - content: A closure that renders the content for the current `ActionProgress`.
    ///   - animation: An optional closure that resolves the `Animation` used when the
    ///     progress changes. The animation is suppressed when the slide state does not
    ///     allow animations.
    public init(
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

    /// The content and behavior of the view.
    public var body: some View {
        ActionProgressReader(
            A.self,
            elementID: elementID,
            clicks: clicks,
            content: content,
            animation: animation
        )
        // Outermost, so this reader's own animation stays scoped to its content
        // and does not govern the `Apply` transition.
        .modifier(ElementAnimator(elementID: elementID))
    }
}
