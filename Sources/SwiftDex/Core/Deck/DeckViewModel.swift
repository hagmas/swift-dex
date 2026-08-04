import SwiftUI

@Observable class DeckViewModel {
    let flow: [(any Slide, SlideTransition)]

    var state = SlideState()
    var slideNumber: Int = 0
    private(set) var slideID = UUID()

    init<T: Deck>(deck: T, slideNumber: Int?) {
        let slideNumber = slideNumber ?? 0
        self.slideNumber = slideNumber
        self.flow = deck.flow.flatten()
        state = SlideState(actionContainer: flow[slideNumber].0.actionContainer)
    }

    func forward() {
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

    func backward() {
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

    func randomAccess(slideNumber: Int) {
        guard self.slideNumber != slideNumber else {
            return
        }
        self.slideNumber = slideNumber
        state = SlideState(actionContainer: flow[slideNumber].0.actionContainer)
        state.latestUserOperation = .randomAccess
    }
}

extension DeckViewModel {
    fileprivate var transitionAnimation: Animation? {
        slideNumber + 1 < flow.count ? flow[slideNumber + 1].1.animation : nil
    }
}
