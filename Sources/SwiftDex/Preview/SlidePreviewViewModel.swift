import SwiftUI

@Observable class SlidePreviewViewModel {
    var state = SlideState()
    let actionContainer: ActionContainer
    @ObservationIgnored var imageCache = [Int: NSImage]()

    init(actionContainer: ActionContainer) {
        self.actionContainer = actionContainer
    }

    func forward() {
        state.latestUserOperation = .forward
        let click = state.position.resolved(total: totalClicks)
        if click < totalClicks {
            state.position = .click(click + 1)
        }
    }

    func backward() {
        state.latestUserOperation = .backward
        let click = state.position.resolved(total: totalClicks)
        if click > 0 {
            state.position = .click(click - 1)
        }
    }

    /// The beat-boundary index of the current position, used for thumbnail selection.
    var boundaryIndex: Int {
        let click = state.position.resolved(total: totalClicks)
        return actionContainer.beatIndex(at: click, clickCounts: state.clickCounts)
    }

    /// Jumps to the click at which every line before `index` has completed.
    func randomAccess(boundary index: Int) {
        guard index != boundaryIndex else {
            return
        }
        state.latestUserOperation = .randomAccess
        state.position = .click(
            actionContainer.click(atBoundary: index, clickCounts: state.clickCounts)
        )
    }
}

private extension SlidePreviewViewModel {
    var totalClicks: Int {
        actionContainer.totalClicks(clickCounts: state.clickCounts)
    }
}
