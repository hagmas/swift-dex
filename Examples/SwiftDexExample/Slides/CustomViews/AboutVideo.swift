import SwiftDex
import SwiftUI

struct AboutVideo: StandardLayoutSlide {
    var head: some View {
        Text("VideoView")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "**VideoView** plays a video. Hover over it to reveal the playback controls."
            VideoView(name: "cat-chan", elementID: .video)
                .aspectRatio(16 / 9, contentMode: .fit)
                .cornerRadius(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SlidePreview(slide: AboutVideo())
}
