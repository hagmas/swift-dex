import SwiftDex
import SwiftUI

struct Slide01: StandardLayoutSlide {
    var head: some View {
        "Slide01"
            .elementID(.element(1))
    }

    var body: some View {
        Bullets {
            Text(.init("`var = hoge`"))
            Text("Hogehoge")
                .matchID(.init(rawValue: "hoge"))
            Indent {
                "Hogehogehoge"
                "Hogehoge"
            }
            "HogeHoge"
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .elementID(.bullets)
    }

    var auxiliary: some View {
        Flipper {
            Image(systemName: "1.circle.fill")
            Image(systemName: "2.circle.fill")
            Image(systemName: "3.circle.fill")
            Image(systemName: "4.circle.fill")
            Image(systemName: "5.circle.fill")
        }
        .foregroundColor(.mint)
        .font(.system(size: 240))
        .padding(20)
        .elementID(.flipper)
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Apply(.fade, to: .element(1))
        ApplyByItem(.custom, to: .bullets)
            & Apply(.fade, to: .flipper)
            & FlipByItem(.flipper)
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
    SlidePreview(slide: Slide01())
}
