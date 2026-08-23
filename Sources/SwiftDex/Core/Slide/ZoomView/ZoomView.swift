import SwiftUI

struct ZoomView<Content: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @Environment(\.slideSize) private var slideSize

    private let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            // Slide-scoped: the action itself is not bound to an element — its
            // target lives in `Zoom.operation` and is resolved through anchors.
            ActionReader(Zoom.self, elementID: .none, clicks: 1, isApplyTarget: false) {
                progress in
                ZStack(alignment: .topLeading) {
                    content()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .modifier(
                    // `ignoredByLayout` keeps the zoom transform out of layout, so
                    // anchors keep resolving in untransformed slide coordinates and a
                    // later zoom target is not distorted by the current zoom.
                    ZoomEffect(
                        baseRect: CGRect(origin: .zero, size: slideSize),
                        targetRect: targetRect(for: progress, proxy: proxy)
                    )
                    .ignoredByLayout()
                )
            } animation: { progress in
                progress.current != nil ? .spring() : nil
            }
        }
        .clipped()
    }
}

private extension ZoomView {
    func targetRect(for progress: ActionProgress<Zoom>, proxy: GeometryProxy) -> CGRect? {
        guard let zoom = progress.nearestAction else {
            return nil
        }

        let rect: CGRect
        if let anchor = elementAnchors.value[zoom.operation.elementID] {
            rect = proxy[anchor]
        }
        else {
            rect = CGRect(origin: .zero, size: slideSize)
        }

        let xInset = (rect.width / zoom.ratio - rect.width) / 2
        let yInset = (rect.height / zoom.ratio - rect.height) / 2

        return rect.insetBy(dx: -xInset, dy: -yInset)
    }
}
