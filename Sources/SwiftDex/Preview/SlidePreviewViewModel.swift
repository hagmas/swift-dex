import SwiftUI

@Observable class SlidePreviewViewModel {
    let eventDispatcher = EventDispatcher()
    var state = SlideState(step: 0)
    let actionContainer: ActionContainer
    @ObservationIgnored var imageCache = [Int: NSImage]()

    init(actionContainer: ActionContainer) {
        self.actionContainer = actionContainer
    }

    func forward() {
        state.latestUserOperation = .forward
        if state.step < actionContainer.capacity {
            state.step += 1
            let actionIDs = actionContainer.actionIDs(for: state.step - 1)
            state.activate(actionIDs: actionIDs)
        }
    }

    func backward() {
        state.latestUserOperation = .backward
        if 0 < state.step {
            state.step -= 1
            state.activate(actionIDs: [])
        }
    }

    func randomAccess(step: Int) {
        guard step != state.step else {
            return
        }
        state.latestUserOperation = .randomAccess
        state.step = step
        let actionIDs = actionContainer.actionIDs(for: state.step - 1)
        state.activate(actionIDs: actionIDs)
    }
}
