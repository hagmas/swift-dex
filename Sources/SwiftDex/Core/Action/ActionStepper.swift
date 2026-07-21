import SwiftUI

/// A view that drives the lifecycle of an `Action` and renders content from its `ActionProgress`.
///
/// `ActionStepper` owns the entire lifecycle of an action: it advances the current sub-step
/// each time the slide moves forward, follows `ActionState` changes, and notifies the slide
/// that the action is complete once all sub-steps have been shown. A custom `View` only
/// needs to render its content from the `ActionProgress` it receives.
///
/// A step-driven action (`count > 1`) progresses through `active(current:step:)` with the
/// sub-step counting from `1` to `count`, then completes. A one-shot action (`count == 1`)
/// completes immediately upon activation.
public struct ActionStepper<A: Action, Content: View>: View {
    @EnvironmentObject private var eventDispatcher: EventDispatcher
    @ActionContext(A.self) private var actionContext
    @State private var step = 1

    private let count: Int
    private let content: (ActionProgress<A>) -> Content
    private let animation: ((ActionProgress<A>) -> Animation?)?

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - type: The `Action` type this view responds to.
    ///   - count: The number of sub-steps required to complete the action.
    ///   - content: A closure that renders the content for the current `ActionProgress`.
    ///   - animation: An optional closure that resolves the `Animation` used when the
    ///     progress changes. The animation is suppressed when the slide state does not
    ///     allow animations.
    public init(
        _ type: A.Type,
        count: Int,
        @ViewBuilder content: @escaping (ActionProgress<A>) -> Content,
        animation: ((ActionProgress<A>) -> Animation?)? = nil
    ) {
        self.count = count
        self.content = content
        self.animation = animation
    }

    /// The content and behavior of the view.
    public var body: some View {
        content(progress)
            .onReceive(eventDispatcher.forward) { _ in
                if isActive {
                    // `withAnimation` is required for insertion/removal transitions
                    // (e.g. Flipper's `.id` swap); the `.animation(_:value:)` modifier
                    // below only reliably animates value changes, not structural ones.
                    withAnimation(resolvedAnimation) {
                        step += 1
                    }
                }
            }
            .onChange(of: step) { _, step in
                if isActive, step >= count, let actionID = actionContext.state?.actionID {
                    actionContext.deactivate(actionID: actionID)
                }
            }
            .onChange(of: actionContext.state, initial: true) { _, state in
                // Outside the activated state, `step` is kept at 1 so that the first
                // render of a fresh activation never sees a stale sub-step.
                step = 1
                if case .activated(let value) = state, count <= 1 {
                    actionContext.deactivate(actionID: value.actionID)
                }
            }
            .animation(resolvedAnimation, value: AnimationKey(state: actionContext.state, step: step))
    }
}

private extension ActionStepper {
    struct AnimationKey: Equatable {
        let state: ActionState<A>?
        let step: Int
    }

    var progress: ActionProgress<A> {
        switch actionContext.state {
        case .static(let value):
            .idle(previous: value.previous, next: value.next)

        case .activated(let value):
            .active(current: value.current, step: step)

        case .deactivated(let value):
            .completed(current: value.current)

        case nil:
            .idle(previous: nil, next: nil)
        }
    }

    var isActive: Bool {
        actionContext.state?.isActivated ?? false
    }

    var resolvedAnimation: Animation? {
        guard actionContext.canBeAnimated else {
            return nil
        }
        return animation?(progress)
    }
}
