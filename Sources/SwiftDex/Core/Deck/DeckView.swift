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
    @Binding var slideNumberBinding: Int

    private let externalController: DeckController?
    @State private var ownedController: DeckController?

    @Namespace var overviewNamespace

    @State private var isDummyLayerVisible = true
    @State private var isPresentationVisible = true

    var controller: DeckController {
        externalController ?? ownedController ?? DeckController(deck: deck)
    }

    /// Initializes a `DeckView` with the specified deck.
    public init(deck: T) {
        self.init(deck: deck, slideNumberBinding: Binding(get: { 0 }, set: { _ in }))
    }

    /// Initializes a `DeckView` driven by the given controller.
    public init(deck: T, controller: DeckController) {
        self.deck = deck
        self.externalController = controller
        self._ownedController = State(initialValue: nil)
        self._slideNumberBinding = Binding(get: { 0 }, set: { _ in })
    }

    init(deck: T, slideNumberBinding: Binding<Int>) {
        self.deck = deck
        _slideNumberBinding = slideNumberBinding
        self.externalController = nil
        self._ownedController = State(
            initialValue: DeckController(
                deck: deck,
                slideNumber: slideNumberBinding.wrappedValue
            )
        )
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
            ZStack {
                DeckOverviewView<T>(
                    controller: controller,
                    namespace: overviewNamespace
                ) { index in
                    controller.select(slideNumber: index)
                }

                // While the overview is closed the cells all carry inactive
                // ids, so this is a source with no followers — completely
                // inert during normal slide navigation.
                dummyLayer
                    .matchedGeometryEffect(
                        id: OverviewMatchID.slide(controller.slideNumber),
                        in: overviewNamespace,
                        isSource: !controller.isOverviewPresented
                    )
                    .allowsHitTesting(!controller.isOverviewPresented)
                    .opacity(isDummyLayerVisible ? 1 : 0)
            }
            .onChange(of: controller.isOverviewPresented) { _, isPresented in
                if isPresented {
                    // Slide → Overview: let MGE animate, then hide dummy
                    withAnimation(controller.overviewAnimation) {
                        isPresentationVisible = false
                    } completion: {
                        withAnimation {
                            isDummyLayerVisible = false
                        }
                    }
                }
                else {
                    // Overview → Slide: show dummy (thumbnail visible,
                    // presentation still alpha 0), then fade presentation in
                    isDummyLayerVisible = true
                    isPresentationVisible = false
                    withAnimation(controller.overviewAnimation) {
                        isPresentationVisible = true
                    }
                }
            }
            .background {
                Button("") {
                    controller.toggleOverview()
                }
                .keyboardShortcut("g", modifiers: [])
                if controller.isOverviewPresented {
                    Button("") {
                        controller.toggleOverview()
                    }
                    .keyboardShortcut(.cancelAction)
                    Button("") {
                        controller.randomAccess(slideNumber: controller.slideNumber - 1)
                    }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    Button("") {
                        controller.randomAccess(slideNumber: controller.slideNumber + 1)
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
            }
        }
    }

    var dummyLayer: some View {
        ZStack {
            if let image = controller.thumbnails[controller.slideNumber] {
                Image(nsImage: image)
                    .resizable()
            }
            presentation
                .opacity(isPresentationVisible ? 1 : 0)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: controller.isOverviewPresented ? 12 : 0)
        )
    }

    var presentation: some View {
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
