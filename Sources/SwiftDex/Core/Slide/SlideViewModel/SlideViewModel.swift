import SwiftUI

protocol SlideViewModel {
    var canBeAnimated: Bool { get }

    /// The resolved click index of the slide, for keying animations.
    var currentClick: Int { get }

    /// Registers how many clicks the action of the given type on the given element consumes.
    ///
    /// Called by `ActionReader` when its view appears. Until a registration arrives,
    /// the timeline treats the action as consuming one click.
    func register<A: Action>(clicks: Int, for elementID: ElementID, type: A.Type)

    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>?

    /// The occurrences of the action that have started, in timeline order.
    ///
    /// Needed by an action whose occurrences are relative to one another; see
    /// `SlideState.actionHistory(for:type:)`.
    func actionHistory<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> [A]

    /// The presenter's camera movement in force, or `nil` when the camera is
    /// where the actions put it.
    var cameraOverride: CameraOverride? { get }

    /// Edits the presenter's camera movement, starting one anchored at the
    /// current click if there is none.
    func updateCameraOverride(_ edit: (inout CameraOverride) -> Void)

    /// Drops the presenter's camera movement, returning the camera to the
    /// actions.
    func clearCameraOverride()
}

@Observable class AnySlideViewModel: SlideViewModel {
    let wrappedViewModel: any SlideViewModel

    init(_ wrappedViewModel: any SlideViewModel) {
        self.wrappedViewModel = wrappedViewModel
    }

    var canBeAnimated: Bool {
        wrappedViewModel.canBeAnimated
    }

    var currentClick: Int {
        wrappedViewModel.currentClick
    }

    func register<A: Action>(clicks: Int, for elementID: ElementID, type: A.Type) {
        wrappedViewModel.register(clicks: clicks, for: elementID, type: type)
    }

    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        wrappedViewModel.actionProgress(for: elementID, type: type)
    }

    func actionHistory<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> [A] {
        wrappedViewModel.actionHistory(for: elementID, type: type)
    }

    var cameraOverride: CameraOverride? {
        wrappedViewModel.cameraOverride
    }

    func updateCameraOverride(_ edit: (inout CameraOverride) -> Void) {
        wrappedViewModel.updateCameraOverride(edit)
    }

    func clearCameraOverride() {
        wrappedViewModel.clearCameraOverride()
    }
}
