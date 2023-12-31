import SwiftUI

@Observable class DeckPreviewViewModel {
    let flow: [(any Slide, SlideTransition)]
    var slideNumber: Int = 0
    @ObservationIgnored var imageCache = [Int: NSImage]()

    init(flow: [(any Slide, SlideTransition)]) {
        self.flow = flow
    }

    var numberOfSlides: Int {
        flow.count
    }
}
