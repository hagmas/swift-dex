import SwiftDex
import SwiftUI

struct AboutApply: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Apply Action"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "The **`Apply`** Action allows you to apply various types of animations to elements within a slide."
            Grid {
                GridRow {
                    Spacer()
                    iconView(title: "Fade") {
                        Element(.element(0)) {
                            Image(systemName: "fish").font(.system(size: 120))
                        }
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Offset") {
                        Element(.element(1)) {
                            Image(systemName: "leaf").font(.system(size: 120))
                        }
                    }
                    Spacer()
                }
                GridRow {
                    Spacer()
                    iconView(title: "Blur") {
                        Element(.element(2)) {
                            Image(systemName: "bird").font(.system(size: 120))
                        }
                    }
                    Spacer()
                    Spacer()
                    iconView(title: "Combination") {
                        Element(.element(3)) {
                            Image(systemName: "carrot").font(.system(size: 120))
                        }
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
        before: .opacity(0.0)
    )

    static let offset = ElementTransition(
        animation: .bouncy(duration: 1.2),
        before: .offset(x: -100).opacity(0.0)
    )

    static let blur = ElementTransition(
        animation: .bouncy(duration: 1.2),
        before: .blur(radius: 50).opacity(0.0)
    )

    static let combination = ElementTransition(
        animation: .bouncy(duration: 1.2),
        before: .opacity(0.0).blur(radius: 50).blur(radius: 50).offset(x: -100)
    )
}

#Preview {
    SlidePreview(slide: AboutApply())
}
