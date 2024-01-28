import Foundation
import SwiftDex
import SwiftUI

struct Title: StandardLayoutSlide {
    @ViewBuilder
    var body: some View {
        "Introducing SwiftDex"
            .textStyle(.title)
    }
}

#Preview{
    SlidePreview(slide: Title())
}
