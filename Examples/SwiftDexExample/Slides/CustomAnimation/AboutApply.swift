import SwiftDex
import SwiftUI

struct AboutApply: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Apply Action"
    }

    var body: some View {
        VStack(spacing: 24) {
            "The " + "Apply".bold() + " Action allows you to apply various types of animations to elements within a slide."
            VStack {
                HStack {
                    Spacer()
                    iconView(title: "Fade") { Image(systemName: "fish").font(.system(size: 120))
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Rotation") { Image(systemName: "leaf").font(.system(size: 120))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack {
                    Spacer()
                    iconView(title: "Blur") { Image(systemName: "bird").font(.system(size: 120))
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Combination") { Image(systemName: "carrot").font(.system(size: 120))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
//    @ActionContainerBuilder
//    var actionContainer: ActionContainer {
//        ApplyByItem(.fadeInFromUp, to: .bullets)
//    }
}

private extension AboutApply {
    func iconView(title: String, view: () -> some View) -> some View {
        VStack(spacing: 28) {
            view()
                .frame(width: 120, height: 120)
            title
        }
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
    SlidePreview(slide: AboutApply())
}
