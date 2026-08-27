import SwiftUI

struct CameraView<Content: View, Background: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @Environment(AnySlideViewModel.self) private var slideViewModel
    @Environment(\.slideSize) private var slideSize

    let canvas: SlideCanvas
    let cameraControl: CameraControl
    @ViewBuilder let content: () -> Content
    @ViewBuilder let background: () -> Background

    // The event monitor is installed once, so its handler reads the geometry
    // from here instead of closing over values that change every click.
    @State private var live = LiveCameraFrame()

    var body: some View {
        GeometryReader { proxy in
            // Slide-scoped: the action itself is not bound to an element — its
            // target lives in `Camera.operation` and is resolved through anchors.
            // The reader registers the clicks and drives the animation; the
            // rectangle comes from the whole history, because `pan` is
            // relative to the operation before it.
            ActionReader(Camera.self, elementID: .none, clicks: 1) { progress in
                let action = actionRect(proxy: proxy)
                let current = slideViewModel.cameraOverride?.apply(to: action) ?? action

                canvasContent
                    .modifier(
                        // `ignoredByLayout` keeps the camera transform out of layout, so
                        // anchors keep resolving in untransformed canvas coordinates and a
                        // later target is not distorted by where the camera is now.
                        CameraEffect(rect: current, viewport: slideSize)
                            .ignoredByLayout()
                    )
                    .onChange(of: frame(proxy: proxy, action: action, current: current), initial: true) {
                        live.value = $1
                    }
            } animation: { progress in
                progress.current != nil ? .spring() : nil
            }
        }
        .clipped()
        .modifier(
            TrackpadCameraInput(
                isEnabled: cameraControl == .interactive,
                live: live,
                onPan: pan,
                onMagnify: magnify,
                onReturn: returnToScript
            )
        )
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

    func frame(proxy: GeometryProxy, action: CGRect, current: CGRect) -> CameraFrame {
        let global = proxy.frame(in: .global)
        // `.global` carries the scale the surface is displayed at, which is the
        // factor between a trackpad's window points and the slide's own units.
        let onScreenScale = proxy.size.width > 0 ? global.width / proxy.size.width : 1
        return CameraFrame(
            viewport: slideSize,
            actionRect: action,
            currentRect: current,
            onScreenScale: onScreenScale,
            origin: global.origin
        )
    }

    func pan(by translation: CGSize) {
        slideViewModel.updateCameraOverride {
            $0.translation.width += translation.width
            $0.translation.height += translation.height
        }
    }

    func magnify(by factor: CGFloat, about pivot: CGPoint) {
        let action = live.value.actionRect
        slideViewModel.updateCameraOverride {
            $0.magnify(by: factor, about: pivot, in: action)
        }
    }

    func returnToScript() {
        withAnimation(.spring()) {
            slideViewModel.clearCameraOverride()
        }
    }

    func actionRect(proxy: GeometryProxy) -> CGRect {
        CameraRect.resolve(
            history: slideViewModel.actionHistory(for: .none, type: Camera.self),
            home: home
        ) { elementID in
            elementAnchors.value[elementID].map { proxy[$0] }
        }
    }
}
