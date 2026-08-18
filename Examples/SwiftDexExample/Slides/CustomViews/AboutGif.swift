import SwiftDex
import SwiftUI

struct AboutGif: StandardLayoutSlide {
    var head: some View {
        Text("GifView")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "**GifView** plays an animated GIF. It loops continuously while visible."
            GifView(name: "cat-chan")
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview(slide: AboutGif())
}
