import SwiftUI

struct ZoomView<Content: View>: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @State private var targetRect: CGRect?
    @ActionContext(Zoom.self) private var actionContext

    private let content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    @ViewBuilder
    var body: some View {
        GeometryReader { proxy in
            content()
                .onChange(of: actionContext.state) { _, state in
                    let animation: Animation?
                    let actionID: ActionID?
                    switch state {
                    case .activated(let value):
                        animation = .spring()
                        actionID = value.actionID

                    default:
                        animation = nil
                        actionID = nil
                    }

                    withAnimation(animation) {
                        targetRect = getTargetRect(
                            proxy: proxy
                        )
                    }

                    if let actionID {
                        actionContext.deactivate(actionID: actionID)
                    }
                }
        }
        .modifier(
            ZoomEffect(
                baseRect: CGRect(x: 0, y: 0, width: 1920, height: 1080),
                targetRect: targetRect
            )
        )
        .clipped()
    }
}

private extension ZoomView {
    func getTargetRect(proxy: GeometryProxy) -> CGRect? {
        guard let actionState = actionContext.state else {
            return nil
        }
        let elementID = actionState.elementID ?? .none
        let ratio = actionState.ratio ?? 1.0

        let rect: CGRect
        if let anchor = elementAnchors.value[elementID] {
            rect = proxy[anchor]
        }
        else {
            rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        }

        let xInset = (rect.width / ratio - rect.width) / 2
        let yInset = (rect.height / ratio - rect.height) / 2

        return rect.insetBy(dx: -xInset, dy: -yInset)
    }
}

private extension ActionState<Zoom> {
    var elementID: ElementID? {
        switch self {
        case .static(let value):
            value.previous?.operation.elementID

        case .activated(let value):
            value.current.operation.elementID

        case .deactivated(let value):
            value.current.operation.elementID
        }
    }

    var ratio: CGFloat? {
        switch self {
        case .static(let value):
            value.previous?.ratio

        case .activated(let value):
            value.current.ratio

        case .deactivated(let value):
            value.current.ratio
        }
    }
}
