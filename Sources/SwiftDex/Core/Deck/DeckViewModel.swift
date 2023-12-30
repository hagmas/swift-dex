import Combine
import SwiftUI

@Observable class DeckViewModel {
    let flow: [(any Slide, SlideTransition)]
    let eventDispatcher = EventDispatcher()

    var state = SlideState(step: 0, activeActionIDs: [])
    var slideNumber: Int = 0
    private(set) var slideID = UUID()
    private(set) var actionContainer: ActionContainer

    init<T: Deck>(deck: T, slideNumber: Int?) {
        let slideNumber = slideNumber ?? 0
        self.slideNumber = slideNumber
        self.flow = deck.flow.flatten()
        actionContainer = flow[slideNumber].0.actionContainer
        state = SlideState(step: 0, activeActionIDs: [])
    }

    func forward() {
        state.latestUserOperation = .forward
        if state.step == actionContainer.capacity {
            if slideNumber < flow.count - 1 {
                withAnimation(transitionAnimation) {
                    slideNumber += 1
                    slideID = UUID()
                    actionContainer = flow[slideNumber].0.actionContainer
                    state.step = 0
                    state.activate(actionIDs: [])
                }
            }
        }
        else if state.step < actionContainer.capacity {
            state.step += 1
            let actionIDs = actionContainer.actionIDs(for: state.step - 1)
            state.activate(actionIDs: actionIDs)
        }
    }

    func backward() {
        state.latestUserOperation = .backward
        if state.step == 0 {
            if slideNumber > 0 {
                slideNumber -= 1
                slideID = UUID()
                actionContainer = flow[slideNumber].0.actionContainer
                state.step = actionContainer.capacity
            }
        }
        else if 0 < state.step {
            state.step -= 1
            state.activate(actionIDs: [])
        }
    }

    func randomAccess(slideNumber: Int) {
        guard self.slideNumber != slideNumber else {
            return
        }
        state.latestUserOperation = .randomAccess
        self.slideNumber = slideNumber
        state.step = 0
        let actionIDs = actionContainer.actionIDs(for: state.step - 1)
        state.activate(actionIDs: actionIDs)
    }
}

extension DeckViewModel {
    fileprivate var transitionAnimation: Animation? {
        slideNumber + 1 < flow.count ? flow[slideNumber + 1].1.animation : nil
    }
}
