import Foundation
import SwiftDex
import SwiftUI
import AppKit

struct MatchedContent: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Matched"
            .matchID(.init(rawValue: "matched"))
    }

    @ViewBuilder
    var body: some View {
        Bullets {
            "Hoge"
        }
    }
}

#Preview {
    SlidePreview(slide: MatchedContent())
}
