import SwiftUI

/// A view that drives the step-by-step lifecycle of an `Action` that completes over multiple sub-steps.
///
/// `ActionStepper` owns the entire lifecycle of a step-driven action: it advances the current
/// step each time the slide moves forward, follows `ActionState` changes (resetting or
/// fast-forwarding the step as needed), and notifies the slide that the action is complete
/// once all sub-steps have been shown. A custom `View` only needs to render its content
/// from the current step and `ActionState`.
///
/// The step starts at `0` (nothing shown), advances to `1` when the action is activated,
/// and completes when it reaches `count`.
public struct ActionStepper<A: Action, Content: View>: View {
    @EnvironmentObject private var eventDispatcher: EventDispatcher
    @ActionContext(A.self) private var actionContext
    @State private var step = 0

    private let count: Int
    private let content: (_ step: Int, _ state: ActionState<A>?) -> Content
    private let animation: ((ActionState<A>?) -> Animation?)?

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - type: The `Action` type this view responds to.
    ///   - count: The number of sub-steps required to complete the action.
    ///   - content: A closure that renders the content for the current step and `ActionState`.
    ///   - animation: An optional closure that resolves the `Animation` used when the step
    ///     changes. The animation is suppressed when the slide state does not allow animations.
    public init(
        _ type: A.Type,
        count: Int,
        @ViewBuilder content: @escaping (_ step: Int, _ state: ActionState<A>?) -> Content,
        animation: ((ActionState<A>?) -> Animation?)? = nil
    ) {
        self.count = count
        self.content = content
        self.animation = animation
    }

    /// The content and behavior of the view.
    public var body: some View {
        content(step, actionContext.state)
            .onReceive(eventDispatcher.forward) { _ in
                if isActivated {
                    step += 1
                }
            }
            .onChange(of: step) { _, step in
                if isActivated, step == count, let actionID = actionContext.state?.actionID {
                    actionContext.deactivate(actionID: actionID)
                }
            }
            .onChange(of: actionContext.state, initial: true) { _, state in
                switch state {
                case .static:
                    step = state?.previous != nil ? count : 0

                case .activated(let value):
                    step = 1
                    if count == 1 {
                        actionContext.deactivate(actionID: value.actionID)
                    }

                case .deactivated:
                    step = count

                default:
                    break
                }
            }
            .animation(resolvedAnimation, value: step)
    }
}

private extension ActionStepper {
    var isActivated: Bool {
        actionContext.state?.isActivated ?? false
    }

    var resolvedAnimation: Animation? {
        guard actionContext.canBeAnimated else {
            return nil
        }
        return animation?(actionContext.state)
    }
}
