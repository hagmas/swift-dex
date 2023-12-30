import SwiftUI

/// `DeckView` is a View for displaying a Deck.
///
/// It manages the state of the Deck and handles input from the user.
public struct DeckView<T: Deck>: View {
    var deck: T
    @Namespace var deckNameSpace
    @Bindable var viewModel: DeckViewModel
    @Binding var slideNumberBinding: Int

    /// Initializes a `DeckView` with the specified deck.
    ///
    /// This initializer creates a `DeckView` instance with the specified deck.
    /// - Parameter deck: The deck to be displayed in this view.
    public init(deck: T) {
        self.init(deck: deck, slideNumberBinding: Binding(get: { 0 }, set: { _ in }))
    }

    init(deck: T, slideNumberBinding: Binding<Int>) {
        self.deck = deck
        _slideNumberBinding = slideNumberBinding
        let viewModel = DeckViewModel(
            deck: deck,
            slideNumber: slideNumberBinding.wrappedValue
        )
        self._viewModel = Bindable(wrappedValue: viewModel)
    }

    /// The body of the `DeckView` view.
    public var body: some View {
        content
            .environmentObject(viewModel.eventDispatcher)
            .environment(\.namespaceID, deckNameSpace)
            .environment(\.matchProperties, matchedProperties)
            .environment(\.fontStyle, T.deckStyle.fontStyle)
            .environment(\.colorStyle, T.deckStyle.colorStyle)
            .onChange(of: viewModel.slideNumber) { _, newValue in
                slideNumberBinding = newValue
            }
            .onChange(of: slideNumberBinding) { _, newValue in
                viewModel.randomAccess(slideNumber: newValue)
            }
    }
}

private extension DeckView {
    var content: some View {
        ScaleEffectView(width: 1920, height: 1080) {
            TapHandlerView {
                currentView
                    .background {
                        T.deckStyle.colorStyle.backgroundColor
                    }
            } onLeftTap: {
                viewModel.backward()
            } onRightTap: {
                if viewModel.state.isActive {
                    viewModel.eventDispatcher.forward.send()
                }
                else {
                    viewModel.forward()
                }
            }
        }
    }

    var currentView: some View {
        flow[viewModel.slideNumber].0.createView(
            state: $viewModel.state,
            actionContainer: viewModel.actionContainer
        )
        .transition(transition)
        .id(viewModel.slideID)
    }

    var slideNumber: Int {
        viewModel.slideNumber
    }

    var flow: [(any Slide, SlideTransition)] {
        viewModel.flow
    }

    var transition: AnyTransition {
        let insertion = flow[slideNumber].1.transition
        let removal = slideNumber + 1 < flow.count ? flow[slideNumber + 1].1.transition : .identity
        return AnyTransition.asymmetric(
            insertion: insertion,
            removal: removal
        )
    }

    var matchedProperties: MatchProperties {
        MatchProperties(
            insertionID: insertionID,
            removalID: removalID
        )
    }

    var insertionID: String? {
        guard slideNumber + 1 < flow.endIndex else {
            return nil
        }

        return flow[slideNumber + 1].1.isMatched ? "\(slideNumber + 1)" : nil
    }

    var removalID: String? {
        return flow[slideNumber].1.isMatched ? "\(slideNumber)" : nil
    }
}
