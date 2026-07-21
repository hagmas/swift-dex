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
        guard let state = actionContext.state else {
            return nil
        }
        return state.current?.elementTransition.current ?? state.nearestElementModifier
    }

    fileprivate var animation: Animation? {
        guard actionContext.canBeAnimated else {
            return nil
        }
        return actionContext.state?.transitionAnimation
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
