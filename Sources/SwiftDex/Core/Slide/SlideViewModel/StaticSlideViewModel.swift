import Foundation
import SwiftUI

/// The slide view model used for previews and thumbnails.
///
/// Positions are interpreted at beat granularity (no click counts are registered:
/// rendering happens off-screen where `onAppear` never fires), and every action at
/// or before the current position renders as completed, without animation.
final class StaticSlideViewModel: SlideViewModel {
    let index: Int
    let actionContainer: ActionContainer

    init(index: Int, actionContainer: ActionContainer) {
        self.index = index
        self.actionContainer = actionContainer
    }

    var canBeAnimated: Bool {
        false
    }

    var currentClick: Int {
        actionContainer.click(atBoundary: index, clickCounts: [:])
    }

    func register<A: Action>(clicks: Int, for elementID: ElementID, type: A.Type) {}

    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        let progress = actionContainer.actionProgress(
            for: elementID,
            type: type,
            at: currentClick,
            clickCounts: [:]
        )

        // Previews never animate mid-action states; an action at the current
        // position renders as completed.
        if case .active(let current, _) = progress {
            return .completed(current: current)
        }
        return progress
    }
}
