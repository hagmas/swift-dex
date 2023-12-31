import SwiftUI

/// A view that displays multiple views split into steps.
///
/// Used in combination with the `FlipByItem` Action, it allows displaying multiple views provided as `content` in a "flip" manner.
public struct Flipper: View {
    @EnvironmentObject var eventDispatcher: EventDispatcher
    @StateObject var viewModel: FlipperViewModel
    @ActionContext(FlipByItem.self) var actionContext

    private let numberOfItems: Int
    private let content: [AnyView]

    /// Creates a new instance.
    ///
    /// - Parameter content: A `@FlipperBuilder` closure returning an array of views to be displayed.
    public init(
        @FlipperBuilder content: @escaping () -> [AnyView]
    ) {
        self.content = content()
        self.numberOfItems = self.content.count

        let viewModel = FlipperViewModel(numberOfItems: numberOfItems)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// The content and behavior of the view.
    public var body: some View {
        content[viewModel.step]
            .onReceive(eventDispatcher.forward) { _ in
                if isDynamic {
                    viewModel.forward()
                }
            }
            .onChange(of: viewModel.step) { _, step in
                if isDynamic, viewModel.isReachedEnd, let actionID = actionContext.state?.actionID {
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
    var isDynamic: Bool {
        actionContext.state?.isDynamic ?? false
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
