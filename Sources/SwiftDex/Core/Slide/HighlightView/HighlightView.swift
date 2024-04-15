import SwiftUI

struct HighlightView: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors
    @State private var targetRect: CGRect?
    @ActionContext(Highlight.self) private var actionContext

    @ViewBuilder
    var body: some View {
        GeometryReader { proxy in
            Group {
                if let targetRect, let color = actionContext.state?.color {
                    ZStack {
                        Color(color)
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: targetRect.width + 40, height: targetRect.height + 40)
                            .position(x: targetRect.midX, y: targetRect.midY)
                            .blur(radius: 10)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                }
                else {
                    EmptyView()
                }
            }
            .onChange(of: actionContext.state) { _, state in
                withAnimation(animation) {
                    targetRect = getTargetRect(
                        proxy: proxy
                    )
                }
                switch state {
                case .activated(let value):
                    actionContext.deactivate(actionID: value.actionID)

                default:
                    break
                }
            }
        }
    }
}

private extension HighlightView {
    func getTargetRect(proxy: GeometryProxy) -> CGRect? {
        guard let actionState = actionContext.state else {
            return nil
        }

        let target = actionState.target ?? .none
        if let anchor = elementAnchors.value[target] {
            return proxy[anchor]
        }
        else {
            return nil
        }
    }

    var animation: Animation? {
        actionContext.canBeAnimated ? .linear : nil
    }
}

private extension ActionState<Highlight> {
    var color: NSColor? {
        switch self {
        case .static:
            nil

        case .activated(let value):
            value.current.mode.color

        case .deactivated(let value):
            value.current.mode.color
        }
    }

    var target: ElementID? {
        switch self {
        case .static:
            nil

        case .activated(let value):
            value.current.target

        case .deactivated(let value):
            value.current.target
        }
    }
}

private extension Highlight.Mode {
    var color: NSColor {
        switch self {
        case .light:
            .white.withAlphaComponent(0.7)
        case .dark:
            .black.withAlphaComponent(0.7)
        }
    }
}
