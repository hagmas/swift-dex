import AppKit
import Foundation
import SwiftDex
import SwiftUI

struct Layout2: StandardLayoutSlide {

    @ViewBuilder
    var head: some View {
        "Background"
            .foregroundStyle(.white)
    }

    @ViewBuilder
    var body: some View {
        "The background is positioned beneath the foreground elements and is displayed without any padding."
            .foregroundStyle(.white)
    }

    var background: some View {
        Image("Image")
            .resizable()
    }
}

#Preview{
    SlidePreview(slide: Layout2())
}
