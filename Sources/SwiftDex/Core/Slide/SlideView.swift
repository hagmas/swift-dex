import Foundation
import SwiftUI

struct SlideView<T>: View where T: Slide {
    let slide: T
    @StateObject var elementAnchors = ElementAnchors()
    var viewModel: AnySlideViewModel

    init(
        slide: T,
        state: Binding<SlideState>
    ) {
        self.slide = slide

        let viewModel = DynamicSlideViewModel(state: state)
        self.viewModel = AnySlideViewModel(viewModel)
    }

    init(slide: T, step: Int) {
        self.slide = slide

        let viewModel = StaticSlideViewModel(
            index: step,
            actionContainer: slide.actionContainer
        )
        self.viewModel = AnySlideViewModel(viewModel)
    }

    init(slide: T) {
        self.slide = slide
        let viewModel = StaticSlideViewModel(
            index: 0,
            actionContainer: ActionContainer.empty
        )
        self.viewModel = AnySlideViewModel(viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZoomView {
                slide.background
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                slide.content
            }
            HighlightView()
        }
        .environment(viewModel)
        .environmentObject(elementAnchors)
        .onPreferenceChange(ElementAnchorsPreference.self) {
            elementAnchors.update(value: $0)
        }
    }
}
