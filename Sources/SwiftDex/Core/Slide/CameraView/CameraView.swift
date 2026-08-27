import SwiftUI

struct CameraView<Content: View, Background: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @Environment(AnySlideViewModel.self) private var slideViewModel
    @Environment(\.slideSize) private var slideSize

    let canvas: SlideCanvas
    @ViewBuilder let content: () -> Content
    @ViewBuilder let background: () -> Background

    var body: some View {
        GeometryReader { proxy in
            // Slide-scoped: the action itself is not bound to an element — its
            // target lives in `Camera.operation` and is resolved through anchors.
            // The reader registers the clicks and drives the animation; the
            // rectangle comes from the whole history, because `pan` is
            // relative to the operation before it.
            ActionReader(Camera.self, elementID: .none, clicks: 1) { progress in
                canvasContent
                    .modifier(
                        // `ignoredByLayout` keeps the camera transform out of layout, so
                        // anchors keep resolving in untransformed canvas coordinates and a
                        // later target is not distorted by where the camera is now.
                        CameraEffect(rect: cameraRect(proxy: proxy), viewport: slideSize)
                            .ignoredByLayout()
                    )
            } animation: { progress in
                progress.current != nil ? .spring() : nil
            }
        }
        .clipped()
    }
}

private extension CameraView {
    /// The slide laid out at its canvas size, pinned to the canvas origin.
    ///
    /// A `.content` axis is left unconstrained so the content takes its ideal
    /// size on it. The canvas extent is therefore never measured: it is an
    /// outcome of laying the content out, not an input to it, which is what
    /// keeps a `.content` canvas renderable in one pass.
    var canvasContent: some View {
        ZStack(alignment: .topLeading) {
            content()
        }
        .fixedSize(horizontal: canvas.width.isContent, vertical: canvas.height.isContent)
        .frame(
            width: canvas.width.length(slide: slideSize.width),
            height: canvas.height.length(slide: slideSize.height),
            alignment: .topLeading
        )
        // The background is applied to the laid-out canvas rather than stretched
        // on its own, so it covers a `.content` canvas without being measured.
        .background(alignment: .topLeading) {
            background()
        }
        // Inside the camera transform, so the cutout travels with the content it
        // is cut out of and needs no transform of its own. The dim covers the
        // canvas; the area beyond a canvas edge is the deck's background.
        .overlay {
            HighlightView()
        }
        // Pin the canvas to the viewport's origin: the camera addresses it in
        // coordinates that start at the canvas's top-left corner.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// The rectangle the camera returns to, and starts from.
    ///
    /// Deliberately the viewport at the canvas origin rather than anything
    /// derived from the canvas: it is then known before the content has laid
    /// out, so a thumbnail of a `.content` canvas is framed correctly on the
    /// first pass.
    var home: CGRect {
        CGRect(origin: .zero, size: slideSize)
    }

    func cameraRect(proxy: GeometryProxy) -> CGRect {
        CameraRect.resolve(
            history: slideViewModel.actionHistory(for: .none, type: Camera.self),
            home: home
        ) { elementID in
            elementAnchors.value[elementID].map { proxy[$0] }
        }
    }
}
