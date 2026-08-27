import SwiftUI

struct CameraView<Content: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @Environment(AnySlideViewModel.self) private var slideViewModel
    @Environment(\.slideSize) private var slideSize

    private let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            // Slide-scoped: the action itself is not bound to an element — its
            // target lives in `Camera.operation` and is resolved through anchors.
            // The reader registers the clicks and drives the animation; the
            // rectangle comes from the whole history, because `pan` is
            // relative to the operation before it.
            ActionReader(Camera.self, elementID: .none, clicks: 1) { progress in
                ZStack(alignment: .topLeading) {
                    content()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .modifier(
                    // `ignoredByLayout` keeps the camera transform out of layout, so
                    // anchors keep resolving in untransformed slide coordinates and a
                    // later target is not distorted by where the camera is now.
                    CameraEffect(rect: cameraRect(proxy: proxy))
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
