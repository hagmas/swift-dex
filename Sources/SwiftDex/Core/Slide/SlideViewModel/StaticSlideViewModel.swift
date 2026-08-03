import Foundation
import SwiftUI

/// The slide view model used for previews and thumbnails.
///
/// Positions are interpreted at line granularity (no click counts are registered:
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
        index
    }

    func register<A: Action>(clicks: Int, for elementID: ElementID, type: A.Type) {}

    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        guard let node: ActionSequenceNode<A> = actionContainer[elementID, index] else {
            return nil
        }

        switch node {
        case .static(let value):
            return .idle(
                previous: value.previous?.action,
                next: value.next?.action
            )

        case .dynamic(let value):
            return .completed(current: value.current.action)
        }
    }
}
