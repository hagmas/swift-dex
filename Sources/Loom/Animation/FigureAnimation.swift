import SwiftUI

/// How the parts of a figure appear when the figure changes, phase by phase.
///
/// Left alone, a figure has no animation of its own: change it inside an
/// animation and everything moves together — nodes fade in, the rest make
/// room, and new lines draw themselves in, all over that one animation.
///
/// Ask for phases and the lines wait. Nodes appear and settle first, and only
/// once that has finished do the lines draw in. Waiting for the layout to
/// settle is the point: a node making room moves for the whole of whatever
/// animation moves it, so no share of a single animation is ever "after".
///
/// ```swift
/// FigureView(figure)
///     .figureAnimation(.phased)
///
/// FigureView(figure)
///     .figureAnimation { phase in
///         switch phase {
///         case .nodes: nil
///         case .lines: .easeOut(duration: 0.4)
///         }
///     }
/// ```
///
/// A phase given no animation of its own takes the one the figure was changed
/// in — so `.phased` keeps whatever timing the caller chose and runs it twice,
/// once for each phase. Leaving is never phased: whatever goes, goes at once —
/// nodes fading out, and the lines to them gone as they start to.
public struct FigureAnimation: Sendable {
    /// One step of a figure appearing.
    public enum Phase: Hashable, Sendable {
        /// Nodes appear, and the nodes already there make room.
        case nodes

        /// Lines draw themselves in.
        case lines
    }

    /// The animation for the nodes, or `nil` for the one the figure was
    /// changed in.
    let nodes: Animation?

    /// The animation for the lines, or `nil` for the one the figure was
    /// changed in.
    let lines: Animation?

    /// How far the appearing nodes have to have come before the lines start,
    /// or `nil` for the lines to wait until the nodes have settled.
    let linesFrom: CGFloat?

    /// Phases with the animation for each.
    ///
    /// - Parameters:
    ///   - linesFrom: How far the appearing nodes have to have come, from `0`
    ///     to `1`, before the lines start — or `nil` for the lines to wait
    ///     until the nodes have settled.
    ///   - animation: The animation for a phase, or `nil` for the one the
    ///     figure was changed in.
    public init(linesFrom: CGFloat? = nil, _ animation: (Phase) -> Animation?) {
        self.nodes = animation(.nodes)
        self.lines = animation(.lines)
        self.linesFrom = linesFrom
    }

    /// Phases, each taking the animation the figure was changed in, the lines
    /// waiting until the nodes have settled.
    public static let phased = FigureAnimation { _ in nil }

    /// Phases, each taking the animation the figure was changed in, the lines
    /// starting once the appearing nodes are partway there.
    ///
    /// Waiting for the nodes to settle can feel slow, a springy animation
    /// above all, which goes on settling long after it is all but there.
    /// So the lines can start earlier: once the nodes have come this far.
    ///
    /// It is a distance, not a time — an animation's length cannot be read —
    /// so it means "once the nodes are this close", whatever the animation.
    /// Springs cover most of the distance early, which makes `0.8` start the
    /// lines well before the nodes come to rest. A spring overshoots, and can
    /// reach `1` before it has settled.
    ///
    /// Measured from the nodes that are appearing, from `0` to `1`. A change
    /// that brings in no node has nothing to measure, and its lines wait for
    /// it to settle.
    public static func phased(linesFrom: CGFloat) -> FigureAnimation {
        FigureAnimation(linesFrom: linesFrom) { _ in nil }
    }
}

extension EnvironmentValues {
    /// The phases a figure appears in, or `nil` for all at once.
    @Entry var figureAnimation: FigureAnimation?
}

public extension View {
    /// Has every figure in this view appear in phases: nodes first, then
    /// lines.
    func figureAnimation(_ animation: FigureAnimation) -> some View {
        environment(\.figureAnimation, animation)
    }

    /// Has every figure in this view appear in phases, with the animation for
    /// each — or `nil` for a phase that takes the one the figure was changed
    /// in.
    func figureAnimation(_ animation: (FigureAnimation.Phase) -> Animation?) -> some View {
        figureAnimation(FigureAnimation(animation))
    }
}
