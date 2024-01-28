import Foundation
import SwiftDex
import SwiftUI
import AppKit

struct Layout2: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Layout"
    }

    @ViewBuilder
    var body: some View {
        "Body View"
    }

    @ViewBuilder
    var auxiliary: some View {
        Image("Image")
    }

    var background: some View {
        Image(systemName: "moon")
//        Image("Mountain")
    }
}

#Preview {
    SlidePreview(slide: Layout2())
}
