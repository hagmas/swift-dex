import Foundation
import SwiftDex
import SwiftUI

struct AboutFlipper: StandardLayoutSlide {
    var head: some View {
        Text("Flipper")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "Flipper".bold() + " displays multiple views on the same place."
            HStack {
                Bullets {
                    "Bengal Cat"
                    "British Shorthair"
                    "Munchkin"
                    "Scottish Fold"
                }
                .elementID(.bullets)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                Flipper(
                    transition: .opacity,
                    animation: .linear
                ) {
                    Image("bengal_cat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                    Image("british_shorthair")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                    Image("munchkin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                    Image("scottish_fold")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                }
                .elementID(.flipper)
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        ApplyByItem(.fadeInFromUp, to: .bullets)
            & FlipByItem(.flipper)
            & Apply(.fade, to: .flipper)
    }
}

#Preview{
    SlidePreview(slide: AboutFlipper())
}
