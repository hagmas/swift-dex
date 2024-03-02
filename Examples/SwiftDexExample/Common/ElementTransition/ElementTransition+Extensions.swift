import SwiftDex

extension ElementTransition {
    static let fadeInFromUp = ElementTransition(
        animation: .bouncy,
        previous: .identity.opacity(0.0).offset(y: -20),
        current: .identity
    )
}
