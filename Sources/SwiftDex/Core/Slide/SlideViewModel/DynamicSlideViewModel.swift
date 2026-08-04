import Foundation
import SwiftUI

final class DynamicSlideViewModel: SlideViewModel {
    @Binding var state: SlideState

    init(state: Binding<SlideState>) {
        self._state = state
    }

    var canBeAnimated: Bool {
        state.latestUserOperation == .forward
    }

    var currentClick: Int {
        state.currentClick
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
        state.actionProgress(for: elementID, type: type)
    }
}
