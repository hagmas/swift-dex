import SwiftUI

/// A view that displays multiple views split into steps.
///
/// Used in combination with the `FlipByItem` Action, it allows displaying multiple views provided as `content` in a "flip" manner.
public struct Flipper: View {
    @EnvironmentObject var eventDispatcher: EventDispatcher
    @State var viewModel: FlipperViewModel
    @ActionContext(FlipByItem.self) var actionContext

    private let numberOfItems: Int
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
        self.numberOfItems = self.content.count
        self.transition = transition
        self.animation = animation

        let viewModel = FlipperViewModel(numberOfItems: numberOfItems)
        _viewModel = State(wrappedValue: viewModel)
    }

    /// The content and behavior of the view.
    public var body: some View {
        content[viewModel.step]
            .id(viewModel.step)
            .transition(transition)
            .onReceive(eventDispatcher.forward) { _ in
                if isActivated {
                    withAnimation(animation) {
                        viewModel.forward()
                    }
                }
            }
            .onChange(of: viewModel.step) { _, step in
                if isActivated, viewModel.isReachedEnd, let actionID = actionContext.state?.actionID {
                    actionContext.deactivate(actionID: actionID)
                }
            }
            .onChange(of: actionContext.state, initial: true) { _, state in
                switch state {
                case .static:
                    if isAfterAction {
                        viewModel.setLastStep()
                    }
                    else {
                        viewModel.resetStep()
                    }

                case .activated(let value):
                    viewModel.resetStep()
                    if viewModel.numberOfItems == 1 {
                        actionContext.deactivate(actionID: value.actionID)
                    }

                case .deactivated:
                    viewModel.setLastStep()

                default:
                    break
                }
            }
    }
}

private extension Flipper {
    var isActivated: Bool {
        actionContext.state?.isActivated ?? false
    }

    var isAfterAction: Bool {
        switch actionContext.state {
        case .static(let value):
            value.previous != nil

        case .activated:
            false

        case .deactivated:
            true

        default:
            false
        }
    }
}
