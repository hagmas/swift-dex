import SwiftDex
import SwiftUI

struct Slide02: StandardLayoutSlide {
    var head: some View {
        "Slide02"
            .elementID(.title)
    }

    var body: some View {
        HStack {
            Bullets(style: .bullet) {
                "Watashiha"
                "Watashida"
                Indent {
                    Text("Hogehoge")
                        .matchID(.init(rawValue: "hoge"))
                    Indent {
                        "Hogehoge"
                    }
                }
                "Hogehoge"
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .elementID(.bullets(1))
            Bullets {
                "Watashiha"
                "Watashida"
                Indent {
                    "Hogehoge"
                }
                "Hogehoge"
                "Hogehoge"
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .elementID(.bullets(2))
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Apply(.fade, to: .title)
        ApplyByItem(.custom, to: .bullets(1))
        ApplyByItem(.custom, to: .bullets(2))
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
    SlidePreview(slide: Slide02())
}
