import Foundation
import SwiftUI
import SwiftDex

struct AboutFlipper: StandardLayoutSlide {
    var head: some View {
        Text("Flipper")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            "Flipper displays multiple views on the same place."
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
                    Image("british_shorthair")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image("munchkin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image("scottish_fold")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
        ApplyByItem(.fade, to: .bullets) 
        & FlipByItem(.flipper)
        & Apply(.fade, to: .flipper)
    }
}

#Preview{
    SlidePreview(slide: AboutFlipper())
}
