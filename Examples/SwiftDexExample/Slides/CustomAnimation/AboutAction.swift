import SwiftDex
import SwiftUI

struct AboutAction: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Action"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "Slides with dynamic content can be created with **Actions**."
            HStack(spacing: 32) {
                Bullets {
                    "To use an **Action:**"
                    Indent {
                        "Wrap the target view in an **Element** with an **ElementID**."
                        "Specify the action using this ID in the action container."
                    }
                }
                .frame(maxHeight: .infinity)
                Code(
                    theme: DefaultDarkTheme(),
                    fitWidthToParent: true,
                    code: """
                        struct SimpleSlide: StandardLayoutSlide {
                            @ViewBuilder
                            var body: some View {
                                Element(.element(0)) {
                                    "Target View"
                                }
                            }

                            @ActionContainerBuilder
                            var actionContainer: ActionContainer {
                                Apply(.fade, to: .element(0))
                            }
                        }
                        """
                )
                .cornerRadius(16.0)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SlidePreview(slide: AboutAction())
}
