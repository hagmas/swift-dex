import SwiftUI

/// `ElementAnimator` is a `ViewModifier` for applying the `Apply` action to Views that have `.elementID()` applied.
struct ElementAnimator: ViewModifier {
    let elementID: ElementID
    @ActionContext(Apply.self) var actionContext

    @ViewBuilder
    func body(content: Content) -> some View {
        Group {
            if !isHidden {
                content.apply(elementModifier ?? .identity)
                    .animation(animation, value: actionContext.state)
            }
        }
        .onChange(of: actionContext.state?.actionID) { _, value in
            guard let actionID = value else {
                return
            }
            actionContext.deactivate(actionID: actionID)
        }
    }
}

extension ElementAnimator {
    fileprivate var isHidden: Bool {
        elementModifier?.isHidden ?? false
    }

    fileprivate var elementModifier: ElementModifier? {
        switch actionContext.state {
        case .static(let value):
            value.nearestElementModifier

        case .activated(let value):
            value.current.elementTransition.current

        case .deactivated(let value):
            value.current.elementTransition.current

        default:
            nil
        }
    }

    fileprivate var animation: Animation? {
        guard actionContext.canBeAnimated else {
            return nil
        }

        switch actionContext.state {
        case .static(let value):
            return value.previous?.elementTransition.animation

        case .activated(let value):
            return value.current.elementTransition.animation

        case .deactivated(let value):
            return value.current.elementTransition.animation

        default:
            return nil
        }
    }
}

extension ActionState.Static where A == Apply {
    fileprivate var nearestElementModifier: ElementModifier? {
        if let value = next?.elementTransition.previous {
            return value
        }

        if let value = previous?.elementTransition.next {
            return value
        }

        if let value = previous?.elementTransition.current {
            return value
        }

        return nil
    }
}

public extension View {
    func elementID(_ elementID: ElementID) -> some View {
        self.modifier(ElementAnimator(elementID: elementID))
            .environment(\.elementID, elementID)
            .transformAnchorPreference(
                key: ElementAnchorsPreference.self,
                value: .bounds
            ) {
                $0[elementID] = $1
            }
    }
}
