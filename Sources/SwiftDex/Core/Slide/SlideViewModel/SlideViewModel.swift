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
}
