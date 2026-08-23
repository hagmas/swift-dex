import SwiftDex
import SwiftUI

struct AboutDissolve: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Shader Effects"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            "Elements can dissolve in with a **Metal shader**, driven by the Action system."
            HStack(spacing: 80) {
                Element(.element(0)) {
                    Image("munchkin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                }
                VStack(alignment: .leading, spacing: 32) {
                    Element(.element(1)) {
                        "The grain size is configurable,"
                    }
                    Element(.element(2)) {
                        "from a fine sand-like dissolve"
                    }
                    Element(.element(3)) {
                        "to chunky pixel blocks."
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Apply(.dissolveIn(cellSize: 12), to: .element(0))
        Apply(.dissolveIn(cellSize: 2), to: .element(1))
            & Apply(.dissolveIn(cellSize: 8), to: .element(2))
            & Apply(.dissolveIn(cellSize: 24), to: .element(3))
    }
}

private extension ElementTransition {
    static func dissolveIn(cellSize: CGFloat) -> ElementTransition {
        ElementTransition(
            animation: .easeInOut(duration: 1.4),
            before: .dissolve(0, cellSize: cellSize)
        )
    }
}

#Preview {
    SlidePreview(slide: AboutDissolve())
}
