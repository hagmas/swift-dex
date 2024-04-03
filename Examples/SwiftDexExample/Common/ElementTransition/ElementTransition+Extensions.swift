import SwiftDex

extension ElementTransition {
    static let fadeInFromUp = ElementTransition(
        animation: .bouncy,
        previous: .opacity(0.0).offset(y: -20)
    )
}
