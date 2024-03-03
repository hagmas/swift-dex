import Foundation
import SwiftDex
import SwiftUI

struct Layout1: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Body + Auxiliary"
    }

    @ViewBuilder
    var body: some View {
        ZStack {
            Color(.cyan)
            VStack(alignment: .leading, spacing: 32) {
                "Body View"
                    .foregroundStyle(.white)
                    .textStyle(.subtitle)
                Bullets {
                    "The main contents of the slide."
                    "Occupies the left half of the slide when an auxiliary view is present."
                    "Spans the full width of the slide if no auxiliary view is specified."
                }
                .lineSpacing(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(60)
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    var auxiliary: some View {
        ZStack {
            Color(.magenta)
            VStack(alignment: .leading, spacing: 32) {
                "Auxiliary View"
                    .foregroundStyle(.white)
                    .textStyle(.subtitle)
                Bullets {
                    "The auxiliary contents of the slide."
                    "Occupies the right half of the slide."
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(60)
            .foregroundStyle(.white)
        }
    }
}

#Preview{
    SlidePreview(slide: Layout1())
}
