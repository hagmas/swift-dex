import SwiftUI

/// How the parts of a figure arrive when the figure changes, phase by phase.
///
/// Left alone, a figure has no animation of its own: change it inside an
/// animation and everything moves together — nodes fade in, the rest make
/// room, and new lines draw themselves in, all over that one animation.
///
/// Ask for phases and the lines wait. Nodes arrive and settle first, and only
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
    /// One step of a figure's arrival.
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

    /// How far the arriving nodes have to have come before the lines start,
    /// or `nil` for the lines to wait until the nodes have settled.
    let linesFrom: CGFloat?

    /// Phases with the animation for each.
    ///
    /// - Parameters:
    ///   - linesFrom: How far the arriving nodes have to have come, from `0`
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
    /// starting once the arriving nodes are partway there.
    ///
    /// Waiting for the nodes to settle can feel slow, a springy animation
    /// above all, which goes on settling long after it has all but arrived.
    /// So the lines can start earlier: once the nodes have come this far.
    ///
    /// It is a distance, not a time — an animation's length cannot be read —
    /// so it means "once the nodes are this close", whatever the animation.
    /// Springs cover most of the distance early, which makes `0.8` start the
    /// lines well before the nodes come to rest. A spring overshoots, and can
    /// reach `1` before it has settled.
    ///
    /// Measured from the nodes that are arriving, from `0` to `1`. A change
    /// that brings in no node has nothing to measure, and its lines wait for
    /// it to settle.
    public static func phased(linesFrom: CGFloat) -> FigureAnimation {
        FigureAnimation(linesFrom: linesFrom) { _ in nil }
    }
}

extension EnvironmentValues {
    /// The phases a figure arrives in, or `nil` for all at once.
    @Entry var figureAnimation: FigureAnimation?
}

public extension View {
    /// Has every figure in this view arrive in phases: nodes first, then
    /// lines.
    func figureAnimation(_ animation: FigureAnimation) -> some View {
        environment(\.figureAnimation, animation)
    }

    /// Has every figure in this view arrive in phases, with the animation for
    /// each — or `nil` for a phase that takes the one the figure was changed
    /// in.
    func figureAnimation(_ animation: (FigureAnimation.Phase) -> Animation?) -> some View {
        figureAnimation(FigureAnimation(animation))
    }
}

extension AnyTransition {
    /// How an element of an arrangement comes and goes: fading, and reporting
    /// how far it has come as it arrives.
    static var figureElement: AnyTransition {
        .asymmetric(
            insertion: .modifier(active: NodeArrival(progress: 0), identity: NodeArrival(progress: 1)),
            removal: .opacity
        )
    }

    /// How the stand-in for a line arrives when the figure arrives all at
    /// once: the line is drawn in over the animation it arrived in.
    ///
    /// It leaves at once. A view on its way out reports nothing, so there is
    /// no way to tell its line how far through leaving it is — and the node
    /// the line went to may be gone too, leaving nowhere to route it. Lines
    /// simply go when their nodes start to.
    static func lineStandIn(_ id: DrawnLineID) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: LineArrival(id: id, progress: 0),
                identity: LineArrival(id: id, progress: 1)
            ),
            removal: .identity
        )
    }
}

/// A node partway through arriving.
///
/// It fades in, and reports how far it has come so that lines can start once
/// it is close enough.
private struct NodeArrival: ViewModifier, Animatable {
    var progress: CGFloat

    nonisolated var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .opacity(progress)
            .transformPreference(NodeArrivalPreference.self) { slowest in
                slowest = Swift.min(slowest, progress)
            }
    }
}

/// How far the slowest arriving node in a figure has come, or `1` when none
/// is arriving.
struct NodeArrivalPreference: PreferenceKey {
    static let defaultValue: CGFloat = 1

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = Swift.min(value, nextValue())
    }
}

/// Stands in for one line among the figure's ordinary views.
///
/// A line itself cannot be animated in. Lines are drawn from where the nodes
/// ended up, which reaches them as a preference — in a later pass than the
/// change that added the line, and without the animation that change was made
/// in. A line appearing there just appears. Which lines a figure has, though,
/// follows from the figure alone, so each one gets a stand-in here, where
/// changes do arrive animated. The stand-in draws nothing; it reports how far
/// its line is through arriving, frame by frame, for the line to read.
///
/// Arriving all at once, that is its transition. Arriving in phases, it comes
/// in undrawn and is told when the figure has settled — the nodes' phase has
/// finished — and draws itself in, in the animation that settling was
/// announced in.
struct LineStandIn: View {
    let id: DrawnLineID

    /// Whether the line may be drawn yet, or `nil` when it arrives all at once.
    let drawn: Bool?

    var body: some View {
        if let drawn {
            Color.clear
                .frame(width: 0, height: 0)
                .modifier(LineArrival(id: id, progress: drawn ? 1 : 0))
        }
        else {
            Color.clear
                .frame(width: 0, height: 0)
        }
    }
}

/// Keeps track of which settling each line arriving in phases waits for.
///
/// Every change that brings in new lines is one settling to wait for; the
/// lines it brought in wait for that one. A reference, so that keeping track
/// does not count as a change to the figure: it happens while a change is
/// being made, when the figure's own state must not be touched.
@MainActor
final class ArrivalWatch {
    private var waits: [DrawnLineID: Int] = [:]
    private var latest = 0
    private var unannounced = false
    private var due: (settling: Int, animation: Animation?)?

    /// Notes the lines the figure has now, and has any that are new wait for
    /// the next settling.
    func note(_ lines: [DrawnLineID]) {
        let new = lines.filter { waits[$0] == nil }
        waits = waits.filter { lines.contains($0.key) }
        guard !new.isEmpty else {
            return
        }
        latest += 1
        unannounced = true
        for line in new {
            waits[line] = latest
        }
    }

    /// The settling `line` waits for.
    func settling(for line: DrawnLineID) -> Int {
        waits[line] ?? 0
    }

    /// Has the lines of `settling` start early, in `animation`, should the
    /// nodes come far enough before they settle.
    func startEarly(_ settling: Int, in animation: Animation?) {
        due = (settling, animation)
    }

    /// The settling to start early now, if there is one not yet started.
    func takeDue() -> (settling: Int, animation: Animation?)? {
        defer { due = nil }
        return due
    }

    /// The settling the change being made has to announce when it finishes,
    /// if it has brought in new lines and nobody has taken it on yet.
    func takeUnannounced() -> Int? {
        guard unannounced else {
            return nil
        }
        unannounced = false
        return latest
    }
}

/// A line's stand-in partway through arriving, reporting how far the line is.
private struct LineArrival: ViewModifier, Animatable {
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
