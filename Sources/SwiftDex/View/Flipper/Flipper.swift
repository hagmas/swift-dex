import SwiftUI

/// A view that displays multiple views split into steps.
///
/// Used in combination with the `FlipByItem` Action, it allows displaying multiple views provided as `content` in a "flip" manner.
public struct Flipper: View {
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
    public var body: some View {
        ActionStepper(FlipByItem.self, count: content.count) { step, _ in
            content[max(step - 1, 0)]
                .id(max(step - 1, 0))
                .transition(transition)
        } animation: { _ in
            animation
        }
    }
}
