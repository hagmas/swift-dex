import SwiftUI

/// `ElementAnimator` is a `ViewModifier` for applying the `Apply` action to Views that have `.elementID()` applied.
struct ElementAnimator: ViewModifier {
    let elementID: ElementID

    func body(content: Content) -> some View {
        ActionStepper(Apply.self, count: 1) { progress in
            let elementModifier = progress.elementModifier
            if !(elementModifier?.isHidden ?? false) {
                content.apply(elementModifier ?? .identity)
            }
        } animation: { progress in
            progress.transitionAnimation
        }
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
