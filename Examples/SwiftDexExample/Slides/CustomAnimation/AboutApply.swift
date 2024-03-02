import SwiftDex
import SwiftUI

struct AboutApply: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Apply Action"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "The " + "Apply".bold() + " Action allows you to apply various types of animations to elements within a slide."
            Grid {
                GridRow {
                    Spacer()
                    iconView(title: "Fade") {
                        Image(systemName: "fish").font(.system(size: 120))
                            .elementID(.element(0))
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Offset") {
                        Image(systemName: "leaf").font(.system(size: 120))
                            .elementID(.element(1))
                    }
                    Spacer()
                }
                GridRow {
                    Spacer()
                    iconView(title: "Blur") {
                        Image(systemName: "bird").font(.system(size: 120))
                            .elementID(.element(2))
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Combination") {
                        Image(systemName: "carrot").font(.system(size: 120))
                            .elementID(.element(3))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Apply(.fadeIn, to: .element(0))
        Apply(.offset, to: .element(1))
        Apply(.blur, to: .element(2))
        Apply(.combination, to: .element(3))
    }
}

private extension AboutApply {
    func iconView(title: String, view: () -> some View) -> some View {
        VStack(spacing: 28) {
            view()
            title
        }
        .frame(maxHeight: .infinity)
        .frame(width: 260)
    }
}

private extension ElementTransition {
    static let fadeIn = ElementTransition(
        animation: .bouncy(duration: 1.2),
        previous: .identity.opacity(0.0),
        current: .identity
    )

    static let offset = ElementTransition(
        animation: .bouncy(duration: 1.2),
        previous: .identity.offset(x: -100).opacity(0.0),
        current: .identity
    )

    static let blur = ElementTransition(
        animation: .bouncy(duration: 1.2),
        previous: .identity.blur(radius: 50).opacity(0.0),
        current: .identity
    )

    static let combination = ElementTransition(
        animation: .bouncy(duration: 1.2),
        previous: .identity.opacity(0.0).blur(radius: 50).blur(radius: 50).offset(x: -100),
        current: .identity
    )
}

#Preview{
    SlidePreview(slide: AboutApply())
}
