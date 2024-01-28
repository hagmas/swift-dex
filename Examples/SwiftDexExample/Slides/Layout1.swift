import Foundation
import SwiftDex
import SwiftUI

struct Layout1: StandardLayoutSlide {
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
        "Auxiliary View"
    }
}

#Preview {
    SlidePreview(slide: Layout1())
}
