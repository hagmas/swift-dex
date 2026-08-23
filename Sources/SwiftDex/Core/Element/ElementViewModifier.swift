import SwiftUI

/// A `ViewModifier` for applying `ElementModifier` to a `View`.
struct ElementViewModifier: ViewModifier {
    let elementModifier: ElementModifier

    func body(content: Content) -> some View {
        content
            .rotationEffect(
                elementModifier.rotationEffect.angle,
                anchor: elementModifier.rotationEffect.anchor
            )
            .scaleEffect(
                elementModifier.scaleEffect.scale,
                anchor: elementModifier.scaleEffect.anchor
            )
            .offset(
                x: elementModifier.offset.x,
                y: elementModifier.offset.y
            )
            .shadow(
                color: elementModifier.shadow.color,
                radius: elementModifier.shadow.radius,
                x: elementModifier.shadow.x,
                y: elementModifier.shadow.y
            )
            .opacity(elementModifier.opacity)
            .blur(
                radius: elementModifier.blur.radius,
                opaque: elementModifier.blur.opaque
            )
    }
}

extension AnyTransition {
    static func modifier(
        active: ElementModifier,
        identity: ElementModifier
    ) -> AnyTransition {
        .modifier(
            active: ElementViewModifier(elementModifier: active),
            identity: ElementViewModifier(elementModifier: identity)
        )
    }
}
