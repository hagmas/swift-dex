import SwiftDex
import SwiftUI

struct AboutTransition: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Slide Transition"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "Transitions between slides can be customized by defining a custom **`SlideTransition`**."
            Spacer()
            Code(
                theme: DefaultDarkTheme(),
                code: """
                    extension SlideTransition {
                        static func customPush(duration: TimeInterval = 0.5) -> SlideTransition {
                            SlideTransition(
                                transition: AnyTransition.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: AnyTransition(PushRemovalTransition())
                                ),
                                animation: .spring(duration: duration)
                            )
                        }
                    }
                    """
            )
            .cornerRadius(16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview{
    SlidePreview(slide: AboutTransition())
}
