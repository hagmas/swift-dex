import SwiftDex
import SwiftUI

struct AboutCanvas: Slide {
    // Three viewports wide. The height is left alone, so the slide is exactly
    // as tall as every other one.
    var canvas: SlideCanvas {
        .init(width: .points(1920 * 3))
    }

    var content: some View {
        HStack(spacing: 0) {
            Element(.element(0)) {
                panel(
                    number: "1",
                    title: "A slide can be wider than the screen",
                    color: .cyan
                ) {
                    "Give a slide a **`canvas`** and it keeps laying out past the edge of the viewport."
                    "Scroll or pinch to travel yourself — the control in the corner returns the camera to the script."
                }
            }
            Element(.element(1)) {
                panel(
                    number: "2",
                    title: "The camera travels over it",
                    color: .mint
                ) {
                    "**`Camera(.pan(to:))`** moves the viewport onto an element without changing the zoom level."
                }
            }
            Element(.element(2)) {
                panel(
                    number: "3",
                    title: "Both axes are independent",
                    color: .pink
                ) {
                    "Each axis is **`.slide`**, **`.points`**, or **`.content`**."
                    Element(.element(10)) {
                        "`.content` sizes the axis to whatever the slide lays out."
                            .textStyle(.caption)
                            .padding(24)
                            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }

    // Two pans across the canvas at the home zoom level, then a zoom into an
    // element small enough that only the camera can reach it, and home again.
    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Camera(.pan(to: .element(1)))
        Camera(.pan(to: .element(2)))
        Camera(.zoom(to: .element(10), ratio: 0.7))
        Camera(.reset)
    }
}

private extension AboutCanvas {
    @ViewBuilder
    func panel(
        number: String,
        title: String,
        color: Color,
        @ViewBuilder detail: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 40) {
            number
                .textStyle(.title)
                .foregroundStyle(color)
            title
                .textStyle(.subtitle)
            detail()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(80)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(.primary.opacity(0.1))
                .frame(width: 2)
        }
    }
}

#Preview {
    SlidePreview(slide: AboutCanvas())
}
