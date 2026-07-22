import SwiftUI

struct ZoomView<Content: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors

    private let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            ActionStepper(Zoom.self, count: 1) { progress in
                ZStack(alignment: .topLeading) {
                    content()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .modifier(
                    // `ignoredByLayout` keeps the zoom transform out of layout, so
                    // anchors keep resolving in untransformed slide coordinates and a
                    // later zoom target is not distorted by the current zoom.
                    ZoomEffect(
                        baseRect: CGRect(x: 0, y: 0, width: 1920, height: 1080),
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
            rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        }

        let xInset = (rect.width / zoom.ratio - rect.width) / 2
        let yInset = (rect.height / zoom.ratio - rect.height) / 2

        return rect.insetBy(dx: -xInset, dy: -yInset)
    }
}

private extension ActionProgress {
    /// The action that currently defines the element's appearance: the running or
    /// completed action, or the most recently completed one when idle.
    var nearestAction: A? {
        switch self {
        case .idle(let previous, _):
            previous

        case .active(let current, _):
            current

        case .completed(let current):
            current
        }
    }
}
