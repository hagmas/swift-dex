import Foundation
import SwiftUI

final class DynamicSlideViewModel: SlideViewModel {
    @Binding var state: SlideState
    let actionContainer: ActionContainer

    init(state: Binding<SlideState>, actionContainer: ActionContainer) {
        self._state = state
        self.actionContainer = actionContainer
    }

    func deactivate(actionID: ActionID) {
        state.deactivate(actionID: actionID)
    }

    var canBeAnimated: Bool {
        state.latestUserOperation == .forward
    }

    func actionState<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionState<A>? {
        guard let node: ActionSequenceNode<A> = actionContainer[elementID, state.step] else {
            return nil
        }

        switch node {
        case .static(let value):
            return .static(
                .init(
                    step: state.step,
                    previous: value.previous?.action,
                    next: value.next?.action
                )
            )

        case .dynamic(let value):
            if state.activeActionIDs.contains(value.current.id) {
                return .activated(
                    .init(
                        step: state.step,
                        actionID: value.current.id,
                        current: value.current.action,
                        previous: value.preivous?.action,
                        next: value.next?.action
                    )
                )
            }
            else {
                return .deactivated(
                    .init(
                        step: state.step,
                        actionID: value.current.id,
                        current: value.current.action,
                        previous: value.preivous?.action,
                        next: value.next?.action
                    )
                )
            }
        }
    }
}
