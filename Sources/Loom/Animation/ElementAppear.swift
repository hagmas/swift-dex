import SwiftUI

/// How an element of an arrangement appears and disappears: it fades in and
/// out, and as it appears it reports how far it has come.
///
/// The report is what lets lines start before the nodes have settled — see
/// ``FigureAnimation/phased(linesFrom:)``.
struct ElementAppearTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(ElementAppearProgress(progress: phase.isIdentity ? 1 : 0))
    }
}

/// An element partway through appearing.
///
/// Animatable, so SwiftUI calls it with every value in between as it animates
/// from `0` to `1` — which is what lets it report how far the element has
/// come frame by frame, rather than only before and after.
private struct ElementAppearProgress: ViewModifier, Animatable {
    var progress: CGFloat

    nonisolated var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    @Environment(\.appearOpacity) private var outer

    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .environment(\.appearOpacity, outer * progress)
            .transformPreference(ElementAppearPreference.self) { slowest in
                slowest = Swift.min(slowest, progress)
            }
    }
}

/// How far the slowest appearing element in a figure has come, or `1` when
/// none is appearing.
struct ElementAppearPreference: PreferenceKey {
    static let defaultValue: CGFloat = 1

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = Swift.min(value, nextValue())
    }
}

extension EnvironmentValues {
    /// How much of the view has appeared: the product of every element around
    /// it that is partway through appearing.
    ///
    /// For what is drawn apart from the element it belongs to — a cluster's
    /// box, beneath the lines — and so would not fade with it otherwise.
    @Entry var appearOpacity: CGFloat = 1
}
