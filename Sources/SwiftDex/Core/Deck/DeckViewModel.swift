import SwiftUI

@Observable class DeckViewModel {
    let flow: [(any Slide, SlideTransition)]

    var state = SlideState()
    var slideNumber: Int = 0
    private(set) var slideID = UUID()
    private(set) var actionContainer: ActionContainer

    init<T: Deck>(deck: T, slideNumber: Int?) {
        let slideNumber = slideNumber ?? 0
        self.slideNumber = slideNumber
        self.flow = deck.flow.flatten()
        actionContainer = flow[slideNumber].0.actionContainer
        state = SlideState()
    }

    func forward() {
        state.latestUserOperation = .forward
        let total = actionContainer.totalClicks(clickCounts: state.clickCounts)
        let click = state.position.resolved(total: total)

        if click < total {
            state.position = .click(click + 1)
        }
        else if slideNumber < flow.count - 1 {
            withAnimation(transitionAnimation) {
                slideNumber += 1
                slideID = UUID()
                actionContainer = flow[slideNumber].0.actionContainer
                state = SlideState()
                state.latestUserOperation = .forward
            }
        }
    }

    func backward() {
        state.latestUserOperation = .backward
        let total = actionContainer.totalClicks(clickCounts: state.clickCounts)
        let click = state.position.resolved(total: total)

        if click > 0 {
            state.position = .click(click - 1)
        }
        else if slideNumber > 0 {
            slideNumber -= 1
            actionContainer = flow[slideNumber].0.actionContainer
            state = SlideState(position: .end)
            state.latestUserOperation = .backward
        }
    }

    func randomAccess(slideNumber: Int) {
        guard self.slideNumber != slideNumber else {
            return
        }
        self.slideNumber = slideNumber
        actionContainer = flow[slideNumber].0.actionContainer
        state = SlideState()
        state.latestUserOperation = .randomAccess
    }
}

extension DeckViewModel {
    fileprivate var transitionAnimation: Animation? {
        slideNumber + 1 < flow.count ? flow[slideNumber + 1].1.animation : nil
    }
}
