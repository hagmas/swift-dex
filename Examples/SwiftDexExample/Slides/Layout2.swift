import Foundation
import SwiftDex
import SwiftUI
import AppKit

struct Layout2: StandardLayoutSlide {
    @ViewBuilder
    var body: some View {
        "Background"
            .foregroundStyle(.white)
            .textStyle(.title)
    }

    var background: some View {
        Image("Image")
            .resizable()
    }
}

#Preview {
    SlidePreview(slide: Layout2())
}
