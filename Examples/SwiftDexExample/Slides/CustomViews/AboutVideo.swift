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

    // A VideoView cannot be an `Apply` target, but `Zoom` transforms the slide
    // around it rather than the video layer itself, so it works — on a video
    // that keeps playing while it scales.
    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Zoom(.in(.video, ratio: 0.8))
        Zoom(.out)
    }
}

#Preview {
    SlidePreview(slide: AboutVideo())
}
