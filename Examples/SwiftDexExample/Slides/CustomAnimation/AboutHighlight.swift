import SwiftDex
import SwiftUI

struct AboutHighlight: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Apply Highlight"
    }

    var body: some View {
        VStack(alignment: .leading) {
            "The " + "Highlight".bold() + " Action allows you to highlight an element by darkening or lightening the surrounding area."
            VStack(alignment: .leading) {
                "\"".textStyle(.subtitle)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                Text("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                Text(
                    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                )
                HStack {
                    Spacer()
                    "\"".textStyle(.subtitle)
                }
            }
            .italic()
            .elementID(.element(0))
            .padding(.horizontal, 128)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Highlight(.dark, to: .element(0))
    }
}

#Preview{
    SlidePreview(slide: AboutHighlight())
}
