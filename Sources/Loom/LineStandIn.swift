import SwiftUI

/// Stands in for one line among the figure's ordinary views.
///
/// A line itself cannot be animated in. Lines are drawn from where the nodes
/// ended up, which reaches them as a preference — in a later pass than the
/// change that added the line, and without the animation that change was made
/// in. A line appearing there just appears. Which lines a figure has, though,
/// follows from the figure alone, so each one gets a stand-in here, where
/// changes do arrive animated. The stand-in draws nothing; it reports how much
/// of its line has appeared, frame by frame, for the line to read.
///
/// When the figure appears all at once, the stand-in's transition does that.
/// When it appears in phases, the stand-in comes in with nothing of its line
/// shown, and is told when the nodes' phase has finished — and then shows its
/// line, in the animation that finish was announced in.
struct LineStandIn: View {
    let id: DrawnLineID

    /// Whether the line may be shown yet, or `nil` when the figure appears all
    /// at once.
    let shown: Bool?

    var body: some View {
        if let shown {
            Color.clear
                .frame(width: 0, height: 0)
                .modifier(LineAppearProgress(id: id, progress: shown ? 1 : 0))
        }
        else {
            Color.clear
                .frame(width: 0, height: 0)
        }
    }
}

/// How the stand-in for a line appears and disappears.
///
/// When the figure appears all at once, the line is drawn in over the
/// animation it appeared in. When it appears in phases, this does nothing and
/// ``LineStandIn`` does the drawing in once the nodes have settled. It must not
/// report anything itself then, or it would report the line as shown over the
/// stand-in's own report that it is still waiting.
///
/// It disappears at once. A view on its way out reports nothing, so there is
/// no way to tell its line how far through disappearing it is — and the node
/// the line went to may be gone too, leaving nowhere to route it. Lines simply
/// go when their nodes start to.
struct LineAppearTransition: Transition {
    let id: DrawnLineID

    /// Whether this transition draws the line in, rather than ``LineStandIn``.
    let drawsIn: Bool

    func body(content: Content, phase: TransitionPhase) -> some View {
        if drawsIn {
            content.modifier(LineAppearProgress(id: id, progress: phase == .willAppear ? 0 : 1))
        }
        else {
            content
        }
    }
}

/// A line's stand-in partway through appearing, reporting how much of the
/// line has.
///
/// Animatable, like ``ElementAppearTransition``'s progress, so the report
/// follows every frame of the animation.
private struct LineAppearProgress: ViewModifier, Animatable {
    let id: DrawnLineID
    var progress: CGFloat

    nonisolated var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.transformPreference(FigureMarksPreference.self) { marks in
            marks.lines[id] = progress
        }
    }
}
