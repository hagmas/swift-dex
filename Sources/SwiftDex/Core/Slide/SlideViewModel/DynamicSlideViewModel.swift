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

    func actionHistory<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> [A] {
        state.actionHistory(for: elementID, type: type)
    }

    var cameraOverride: CameraOverride? {
        state.effectiveCameraOverride
    }

    func updateCameraOverride(_ edit: (inout CameraOverride) -> Void) {
        // A stale override is gone as far as the camera is concerned, so a new
        // movement starts from the script's own rectangle rather than resuming
        // one the presenter left behind on an earlier click.
        var override = state.effectiveCameraOverride ?? CameraOverride(anchorClick: state.currentClick)
        edit(&override)
        state.cameraOverride = override.isIdentity ? nil : override
    }

    func clearCameraOverride() {
        guard state.cameraOverride != nil else {
            return
        }
        state.cameraOverride = nil
    }
}
