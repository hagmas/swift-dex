import SwiftDex
import SwiftUI

struct MultipleApplyByItem: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Multiple ApplyByItem"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            "The same **Bullets** can be targeted by multiple **ApplyByItem** actions in sequence."
            Bullets(style: .numbered) {
                "First, each item fades in from above."
                "Then, a second **ApplyByItem** kicks in."
                "It checks off each item, one by one."
            }
            .elementID(.bullets)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        ApplyByItem(.fadeInFromUp, to: .bullets)
        ApplyByItem(.checkOff, to: .bullets)
    }
}

private extension ElementTransition {
    // The `before` phase describes the state the first action left the items in.
    static let checkOff = ElementTransition(
        animation: .easeOut(duration: 0.4),
        before: .identity,
        current: .opacity(0.4).offset(x: 60)
    )
}

#Preview {
    SlidePreview(slide: MultipleApplyByItem())
}
