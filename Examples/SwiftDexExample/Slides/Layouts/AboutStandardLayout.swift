import AppKit
import Foundation
import SwiftDex
import SwiftUI

struct AboutStandardLayout: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "StandardLayoutSlide"
    }

    @ViewBuilder
    var body: some View {
        Bullets {
            "The " + "StandardLayoutSlide".bold() + " protocol allows you to write commonly used slide layouts."
            "Includes layout information for the Head, Body, and Auxiliary sections, as well as details like padding."
            "Using the " + "Slide".bold() + " protocol, you can also describe layouts from scratch."
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview{
    SlidePreview(slide: AboutStandardLayout())
}
