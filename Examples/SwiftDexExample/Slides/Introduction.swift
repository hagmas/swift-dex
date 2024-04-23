import SwiftDex
import SwiftUI

struct Introduction: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "What is SwiftDex"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "**SwiftDex** is a framework for describing presentations in SwiftUI."
            Bullets {
                "Supports custom views, such as **Buellts**, **Code**, or **Flipper**."
                "Supports animations with simple syntax."
                "Flexible layouts."
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .elementID(.bullets)
            Spacer()
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        ApplyByItem(.fadeInFromUp, to: .bullets)
    }
}

#Preview{
    SlidePreview(slide: Introduction())
}
