import SwiftDex
import SwiftUI

struct AboutBullets: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Bullets"
    }

    var body: some View {
        Bullets(style: .bullet) {
            "You can put text."
            "or SwiftUI view."
            Indent {
                "Hogehoge"
                Indent {
                    "Hogehoge"
                }
            }
            "Hogehoge"
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }

//    @ActionContainerBuilder
//    var actionContainer: ActionContainer {
//        Apply(.fade, to: .title)
//        ApplyByItem(.custom, to: .bullets(1))
//        ApplyByItem(.custom, to: .bullets(2))
//    }
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
    SlidePreview(slide: AboutBullets())
}
