import Foundation
import SwiftUI

final class DynamicSlideViewModel: SlideViewModel {
    @Binding var state: SlideState
    let actionContainer: ActionContainer

    init(state: Binding<SlideState>, actionContainer: ActionContainer) {
        self._state = state
        self.actionContainer = actionContainer
    }

    var canBeAnimated: Bool {
        state.latestUserOperation == .forward
    }

    var currentClick: Int {
        state.position.resolved(
            total: actionContainer.totalClicks(clickCounts: state.clickCounts)
        )
    }

    func register<A: Action>(clicks: Int, for elementID: ElementID, type: A.Type) {
        let key = ClickCountKey(elementID: elementID, actionType: A.self)
        guard state.clickCounts[key] != clicks else {
            return
        }
        state.register(clicks: clicks, for: key)
    }

    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        actionContainer.actionProgress(
            for: elementID,
            type: type,
            at: currentClick,
            clickCounts: state.clickCounts
        )
    }
}
