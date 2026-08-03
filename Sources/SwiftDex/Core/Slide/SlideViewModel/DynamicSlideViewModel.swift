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
        let position = actionContainer.position(
            at: currentClick,
            clickCounts: state.clickCounts
        )
        guard let node: ActionSequenceNode<A> = actionContainer[elementID, position.index] else {
            return nil
        }

        switch node {
        case .static(let value):
            return .idle(
                previous: value.previous?.action,
                next: value.next?.action
            )

        case .dynamic(let value):
            let key = ClickCountKey(elementID: elementID, actionType: A.self)
            let clicks = state.clickCounts[key] ?? 1
            if position.offset < clicks {
                return .active(current: value.current.action, step: position.offset + 1)
            }
            else {
                return .completed(current: value.current.action)
            }
        }
    }
}
