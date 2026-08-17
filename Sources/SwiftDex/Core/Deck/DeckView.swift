import SwiftUI

/// `DeckView` is a View for displaying a Deck.
///
/// It renders the deck's slides and handles input from the user. The presentation
/// state lives in a `DeckController`: pass your own instance to share one
/// presentation between multiple views (or windows), or use the convenience
/// initializer to let the view create a private controller.
public struct DeckView<T: Deck>: View {
    var deck: T
    @Namespace var deckNamespace

    // A view's init runs on every parent body evaluation, so a privately owned
    // controller must live in @State to survive; an external one is held as a
    // plain reference.
    private let externalController: DeckController?
    @State private var ownedController: DeckController?

    var controller: DeckController {
        externalController ?? ownedController ?? DeckController(deck: deck)
    }

    /// Initializes a `DeckView` with the specified deck.
    ///
    /// This initializer creates a `DeckView` instance with a private controller.
    /// - Parameter deck: The deck to be displayed in this view.
    @MainActor
    public init(deck: T) {
        self.deck = deck
        self.externalController = nil
        self._ownedController = State(initialValue: DeckController(deck: deck))
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
        self.externalController = controller
        self._ownedController = State(initialValue: nil)
    }

    /// The body of the `DeckView` view.
    public var body: some View {
        ScaleEffectView(size: T.deckStyle.slideSize) {
            OverviewStage(controller: controller) {
                presentation
            }
        }
        .environment(\.namespaceID, deckNamespace)
        .environment(\.matchProperties, matchedProperties)
        .environment(\.fontStyle, T.deckStyle.fontStyle)
        .environment(\.colorStyle, T.deckStyle.colorStyle)
        .environment(\.slideSize, T.deckStyle.slideSize)
    }
}

// MARK: - Slide rendering

private extension DeckView {
    /// The live presentation surface: the current slide with tap and arrow-key
    /// navigation, transitioning between slides.
    var presentation: some View {
        ScaleEffectView(size: T.deckStyle.slideSize) {
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
        @Bindable var controller = controller
        return flow[controller.slideNumber].0.createView(state: $controller.state)
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
