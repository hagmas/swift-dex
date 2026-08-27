import SwiftDex
import SwiftUI

struct AboutCamera: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Camera Action"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "The **`Camera`** Action moves the rectangle of the slide the viewport shows."
            "**`zoom`** resizes it, **`pan`** moves it at the current zoom level, and **`reset`** returns home."
            HStack {
                Spacer()
                Element(.element(0)) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 320))
                        .foregroundColor(.cyan)
                }
                Spacer()
                Element(.element(1)) {
                    Image(systemName: "square.fill")
                        .font(.system(size: 320))
                        .foregroundColor(.mint)
                }
                Spacer()
                Element(.element(2)) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 320))
                        .foregroundColor(.pink)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    // The three zooms re-fit each shape in turn, so the camera resizes as it
    // moves. The pan that follows keeps the zoom level the last one set and
    // only travels, which is the difference between the two operations.
    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Camera(.zoom(to: .element(0), ratio: 0.5))
        Camera(.zoom(to: .element(1), ratio: 0.5))
        Camera(.zoom(to: .element(2), ratio: 0.5))
        Camera(.pan(to: .element(0)))
        Camera(.reset)
    }
}

#Preview {
    SlidePreview(slide: AboutCamera())
}
