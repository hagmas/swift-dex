import SwiftUI

/// `ElementAnimator` is a `ViewModifier` for applying the `Apply` action to Views that have `.elementID()` applied.
struct ElementAnimator: ViewModifier {
    let elementID: ElementID

    func body(content: Content) -> some View {
        ActionReader(Apply.self, clicks: 1) { progress in
            let elementModifier = progress.elementModifier
            if !(elementModifier?.isHidden ?? false) {
                content.apply(elementModifier ?? .identity)
            }
        } animation: { progress in
            progress.transitionAnimation
        }
    }
}

private struct HasElementAnimatorKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hasElementAnimator: Bool {
        get { self[HasElementAnimatorKey.self] }
        set { self[HasElementAnimatorKey.self] = newValue }
    }
}

public extension View {
    /// Assigns an element identity and wires up the `Apply` action.
    ///
    /// > Important: Do not use this modifier on views backed by a
    /// > hardware-accelerated `NSViewRepresentable` (e.g. `VideoView`).
    /// > The animation and visual-effect modifiers it installs force SwiftUI
    /// > to flatten the video layer, which fails. Use ``mediaElementID(_:)``
    /// > instead.
    func elementID(_ elementID: ElementID) -> some View {
        self.modifier(ElementAnimator(elementID: elementID))
            .environment(\.elementID, elementID)
            .environment(\.hasElementAnimator, true)
            .transformAnchorPreference(
                key: ElementAnchorsPreference.self,
                value: .bounds
            ) {
                $0[elementID] = $1
            }
    }

    /// Assigns an element identity without the animation/visual-effect
    /// wrapper that ``elementID(_:)`` installs.
    ///
    /// Use this on views that contain a hardware-accelerated
    /// `NSViewRepresentable` (e.g. `VideoView`) where SwiftUI's layer
    /// flattening would fail. The identity is still visible to
    /// `@SlideValue` and to any `ActionReader` the view creates
    /// internally.
    func mediaElementID(_ elementID: ElementID) -> some View {
        self.environment(\.elementID, elementID)
    }
}
