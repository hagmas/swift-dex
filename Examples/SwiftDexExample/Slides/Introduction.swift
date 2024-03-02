import SwiftDex
import SwiftUI

struct Introduction: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "What is SwiftDex"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "SwiftDex".bold() + " is a framework for describing presentations in SwiftUI."
            Bullets {
                Text("Supports custom views, such as ") + "Buellts".bold() + ", " + "Code".bold() + ", or " + "Flipper".bold() + "."
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
