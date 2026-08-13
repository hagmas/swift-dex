import SwiftUI

/// `DeckView` is a View for displaying a Deck.
///
/// It renders the deck's slides and handles input from the user. The presentation
/// state lives in a `DeckController`: pass your own instance to share one
/// presentation between multiple views (or windows), or use the convenience
/// initializer to let the view create a private controller.
public struct DeckView<T: Deck>: View {
    var deck: T
    @Namespace var deckNameSpace
    @Bindable var controller: DeckController
    @Binding var slideNumberBinding: Int

    /// Initializes a `DeckView` with the specified deck.
    ///
    /// This initializer creates a `DeckView` instance with a private controller.
    /// - Parameter deck: The deck to be displayed in this view.
    public init(deck: T) {
        self.init(deck: deck, slideNumberBinding: Binding(get: { 0 }, set: { _ in }))
    }

    /// Initializes a `DeckView` driven by the given controller.
    ///
    /// Multiple views observing the same controller stay in sync: advancing the
    /// presentation in one advances all of them.
    ///
    /// - Parameters:
    ///   - deck: The deck to be displayed in this view. Must be the deck the
    ///     controller was created with.
    ///   - controller: The presentation state to observe and drive.
    public init(deck: T, controller: DeckController) {
        self.deck = deck
        self._controller = Bindable(wrappedValue: controller)
        self._slideNumberBinding = Binding(get: { 0 }, set: { _ in })
    }

    init(deck: T, slideNumberBinding: Binding<Int>) {
        self.deck = deck
        _slideNumberBinding = slideNumberBinding
        let controller = DeckController(
            deck: deck,
            slideNumber: slideNumberBinding.wrappedValue
        )
        self._controller = Bindable(wrappedValue: controller)
    }

    /// The body of the `DeckView` view.
    public var body: some View {
        content
            .environment(\.namespaceID, deckNameSpace)
            .environment(\.matchProperties, matchedProperties)
            .environment(\.fontStyle, T.deckStyle.fontStyle)
            .environment(\.colorStyle, T.deckStyle.colorStyle)
            .onChange(of: controller.slideNumber) { _, newValue in
                slideNumberBinding = newValue
            }
            .onChange(of: slideNumberBinding) { _, newValue in
                controller.randomAccess(slideNumber: newValue)
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
                controller.backward()
            } onRightTap: {
                controller.forward()
            }
            .clipped()
        }
    }

    var currentView: some View {
        flow[controller.slideNumber].0.createView(state: $controller.state)
            .transition(transition)
            .id(controller.slideID)
    }

    var slideNumber: Int {
        controller.slideNumber
    }

    var flow: [(any Slide, SlideTransition)] {
        controller.flow
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
