import SwiftDex
import SwiftUI

struct AboutBullets: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Bullets"
    }

    var body: some View {
        Bullets(style: .bullet) {
            "Bullets is a view for displaying items in a bulleted list format."
            "Bullet items can be text,"
            HStack {
                "a SwiftUI view, "
                Image(systemName: "figure.wave")
                Image(systemName: "figure.american.football")
                Image(systemName: "figure.cooldown")
                Image(systemName: "figure.curling")
            }
            Indent {
                "or an indent."
            }
            "It can be animated using the " + "ApplyByItem".bold() + " Action."
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .elementID(.bullets)
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        ApplyByItem(.fadeInFromUp, to: .bullets)
    }
}

private extension ElementTransition {
    static let fadeInFromUp = ElementTransition(
        animation: .bouncy,
        previous: .identity.opacity(0.0).offset(y: -20),
        current: .identity
    )
}

#Preview{
    SlidePreview(slide: AboutBullets())
}
