import Foundation
import SwiftDex
import SwiftUI
import AppKit

struct MatchedTitle: StandardLayoutSlide {
    @ViewBuilder
    var body: some View {
        "Matched"
            .textStyle(.title)
            .matchID(.init(rawValue: "matched"))
    }
}

#Preview {
    SlidePreview(slide: MatchedTitle())
}
