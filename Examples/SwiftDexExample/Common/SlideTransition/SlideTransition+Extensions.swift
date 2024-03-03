import SwiftDex
import SwiftUI

extension SwiftDex.SlideTransition {
    static func customPush(duration: TimeInterval = 0.5) -> SwiftDex.SlideTransition {
        SlideTransition(
            transition: AnyTransition.asymmetric(
                insertion: .move(edge: .trailing),
                removal: AnyTransition(PushRemovalTransition())
            ),
            animation: .spring(duration: duration)
        )
    }
}

private struct PushRemovalTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        GeometryReader { proxy in
            content
                .offset(x: phase.isIdentity ? 0 : -proxy.size.width * 0.1)
                .brightness(phase.isIdentity ? 0.0 : 1.0)
        }
    }
}
