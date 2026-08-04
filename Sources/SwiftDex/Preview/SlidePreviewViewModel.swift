import SwiftUI

@Observable class SlidePreviewViewModel {
    var state: SlideState
    @ObservationIgnored var imageCache = [Int: NSImage]()

    init(actionContainer: ActionContainer) {
        state = SlideState(actionContainer: actionContainer)
    }

    func forward() {
        state.latestUserOperation = .forward
        if state.currentClick < state.totalClicks {
            state.position = .click(state.currentClick + 1)
        }
    }

    func backward() {
        state.latestUserOperation = .backward
        if state.currentClick > 0 {
            state.position = .click(state.currentClick - 1)
        }
    }

    /// Jumps to the click at which every beat before `index` has completed.
    func randomAccess(boundary index: Int) {
        guard index != state.currentBeatIndex else {
            return
        }
        state.latestUserOperation = .randomAccess
        state.position = .click(state.click(atBoundary: index))
    }
}
