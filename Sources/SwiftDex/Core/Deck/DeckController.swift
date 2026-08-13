import SwiftUI

/// The single source of truth for a running presentation.
///
/// A `DeckController` owns the current slide number and the click position within
/// it, and exposes the operations that move through the deck. Create one instance
/// and hand it to every view that should observe or drive the same presentation —
/// e.g. a `DeckView`, a slide navigator, or a presenter display in another window.
///
/// ```swift
/// @State private var controller = DeckController(deck: MyDeck())
///
/// var body: some View {
///     DeckView(deck: MyDeck(), controller: controller)
/// }
/// ```
@Observable
public final class DeckController {
    let flow: [(any Slide, SlideTransition)]

    var state = SlideState()
    private(set) var slideID = UUID()

    /// The index of the slide currently being presented.
    public private(set) var slideNumber: Int = 0

    /// Creates a controller for the given deck.
    ///
    /// - Parameters:
    ///   - deck: The deck to present.
    ///   - slideNumber: The slide to start on. Defaults to the first slide.
    public init<T: Deck>(deck: T, slideNumber: Int = 0) {
        self.flow = deck.flow.flatten()
        self.slideNumber = min(max(0, slideNumber), flow.count - 1)
        state = SlideState(actionContainer: flow[self.slideNumber].0.actionContainer)
    }

    /// The number of slides in the deck.
    public var slideCount: Int {
        flow.count
    }

    /// The resolved click position within the current slide.
    public var currentClick: Int {
        state.currentClick
    }

    /// The total number of clicks the current slide consumes, given current registrations.
    public var totalClicks: Int {
        state.totalClicks
    }

    /// Advances one click, moving to the next slide when the current one is exhausted.
    public func forward() {
        state.latestUserOperation = .forward

        if state.currentClick < state.totalClicks {
            state.position = .click(state.currentClick + 1)
        }
        else if slideNumber < flow.count - 1 {
            withAnimation(transitionAnimation) {
                slideNumber += 1
                slideID = UUID()
                state = SlideState(actionContainer: flow[slideNumber].0.actionContainer)
                state.latestUserOperation = .forward
            }
        }
    }

    /// Rewinds one click, moving to the end of the previous slide at the beginning.
    public func backward() {
        state.latestUserOperation = .backward

        if state.currentClick > 0 {
            state.position = .click(state.currentClick - 1)
        }
        else if slideNumber > 0 {
            slideNumber -= 1
            state = SlideState(
                actionContainer: flow[slideNumber].0.actionContainer,
                position: .end
            )
            state.latestUserOperation = .backward
        }
    }

    /// Jumps directly to the beginning of the given slide.
    public func randomAccess(slideNumber: Int) {
        guard self.slideNumber != slideNumber,
            0 <= slideNumber && slideNumber < flow.count
        else {
            return
        }
        self.slideNumber = slideNumber
        state = SlideState(actionContainer: flow[slideNumber].0.actionContainer)
        state.latestUserOperation = .randomAccess
    }
}

extension DeckController {
    fileprivate var transitionAnimation: Animation? {
        slideNumber + 1 < flow.count ? flow[slideNumber + 1].1.animation : nil
    }
}
