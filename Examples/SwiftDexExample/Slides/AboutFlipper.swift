import Foundation
import SwiftUI
import SwiftDex

struct AboutFlipper: StandardLayoutSlide {
    var head: some View {
        Text("Flipper")
    }

    var body: some View {
        Color(.yellow)
    }
    
    var auxiliary: some View {
        Color(.purple)
    }
}

#Preview{
    SlidePreview(slide: AboutFlipper())
}
