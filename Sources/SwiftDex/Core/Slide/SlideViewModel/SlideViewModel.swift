import Combine
import SwiftUI

protocol SlideViewModel {
    func deactivate(actionID: ActionID)
    var canBeAnimated: Bool { get }
    func actionState<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionState<A>?
}

@Observable class AnySlideViewModel: SlideViewModel {
    let wrappedViewModel: any SlideViewModel

    init(_ wrappedViewModel: any SlideViewModel) {
        self.wrappedViewModel = wrappedViewModel
    }

    func deactivate(actionID: ActionID) {
        wrappedViewModel.deactivate(actionID: actionID)
    }

    var canBeAnimated: Bool {
        wrappedViewModel.canBeAnimated
    }

    func actionState<A>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionState<A>? where A: Action {
        wrappedViewModel.actionState(
            for: elementID,
            type: type
        )
    }
}
