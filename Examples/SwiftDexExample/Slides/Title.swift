import Foundation
import SwiftDex
import SwiftUI

struct Title: StandardLayoutSlide {
    let title: String

    @ViewBuilder
    var body: some View {
        title
            .textStyle(.title)
    }
}

#Preview{
    SlidePreview(slide: Title(title: "Introducing SwiftDex"))
}
