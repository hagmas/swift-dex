import SwiftDex
import SwiftUI

struct Introduction: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "What is SwiftDex"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "`SwiftDex` is a framework for describing presentations in SwiftUI."
            Bullets {
                "Supports animations."
                "Supports custom views."
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .elementID(.bullets)
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        ApplyByItem(.custom, to: .bullets)
    }
}

private extension ElementTransition {
    static let custom = ElementTransition(
        animation: .bouncy,
        previous: .identity.opacity(0.5).set(isHidden: true),
        current: .identity.opacity(1.0).scaleEffect(CGSize(width: 1.2, height: 1.2)),
        next: .identity.opacity(0.5)
    )
}

#Preview{
    SlidePreview(slide: Introduction())
}
