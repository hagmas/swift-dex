import Foundation
import SwiftUI

final class StaticSlideViewModel: SlideViewModel {
    let step: Int
    let actionContainer: ActionContainer

    init(step: Int, actionContainer: ActionContainer) {
        self.step = step
        self.actionContainer = actionContainer
    }

    func deactivate(actionID: ActionID) {}

    var canBeAnimated: Bool {
        false
    }

    func actionState<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionState<A>? {
        guard let node: ActionSequenceNode<A> = actionContainer[elementID, step] else {
            return nil
        }

        switch node {
        case .static(let value):
            return .static(
                .init(
                    step: step,
                    previous: value.previous?.action,
                    next: value.next?.action
                )
            )

        case .dynamic(let value):
            return .deactivated(
                .init(
                    step: step,
                    actionID: value.current.id,
                    current: value.current.action,
                    previous: value.previous?.action,
                    next: value.next?.action
                )
            )
        }
    }
}
