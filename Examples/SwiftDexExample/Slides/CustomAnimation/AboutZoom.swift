import SwiftDex
import SwiftUI

struct AboutZoom: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Zoom Action"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "The **`Zoom`** Action is for zooming in or out on an Element."
            HStack {
                Spacer()
                Image(systemName: "circle.fill")
                    .font(.system(size: 320))
                    .foregroundColor(.cyan)
                    .elementID(.element(0))
                Spacer()
                Image(systemName: "square.fill")
                    .font(.system(size: 320))
                    .foregroundColor(.mint)
                    .elementID(.element(1))
                Spacer()
                Image(systemName: "triangle.fill")
                    .font(.system(size: 320))
                    .foregroundColor(.pink)
                    .elementID(.element(2))
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Zoom(.in(.element(0), ratio: 0.5))
        Zoom(.in(.element(1), ratio: 0.5))
        Zoom(.in(.element(2), ratio: 0.5))
        Zoom(.out)
    }
}

#Preview{
    SlidePreview(slide: AboutZoom())
}
