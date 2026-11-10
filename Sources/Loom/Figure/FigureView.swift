import SwiftUI

/// Renders a ``Figure``.
///
/// ```swift
/// FigureView(RefactorFigure())
/// ```
///
/// The arrangement is laid out by SwiftUI, each node publishes where it landed,
/// and the lines are drawn from those positions — behind the nodes, so a line
/// arriving at a box never draws across it.
///
/// A figure can be drawn inside a node of another, by putting a `FigureView`
/// in the node's body:
///
/// ```swift
/// struct Backend: Node {
///     let id: NodeID
///
///     var body: some View {
///         VStack {
///             Text("Backend")
///             FigureView(BackendFigure())
///         }
///     }
/// }
/// ```
///
/// The figure inside keeps to itself. Its node IDs are its own, so they may
/// repeat the ones outside, and its lines stay inside: a line outside can
/// reach the node that holds it, but nothing in it. Styles reach it as they
/// reach any view, so a style given to the holding node is the inner nodes'
/// too unless the inner figure is given one of its own.
///
/// The node is as big as the figure's nodes, and its content is cut to its
/// outline. A line that reaches past them — a loop off a side, a line going
/// round the outside, the words on them — is cut off with it, so make room
/// for it with padding:
///
/// ```swift
/// FigureView(BackendFigure())
///     .padding(.trailing, 48)  // for the line going round on the right
/// ```
///
/// A figure is laid out at its own size, whatever room it is given, so that
/// it looks the same wherever it is drawn. Given less room than it needs, it
/// draws past it rather than squeezing its nodes together; given more, it sits
/// in the middle. The view itself still takes all the room it is given — it
/// has to stay put while the figure in it grows and shrinks — so to know how
/// big the figure is, to make room for it, read its size with
/// ``SwiftUICore/View/onFigureSizeChange(_:)``.
///
/// That size is its nodes', not its lines': a line coming or going would
/// otherwise move every node. A line that reaches past the nodes is drawn
/// past them, and a figure that has one needs that much more room around it.
public struct FigureView<Content: Figure>: View {
    private let figure: Content
    private let spacing: CGFloat
    private let routing: Line.Routing

    @Environment(\.lineStyle) private var lineStyle
    @Environment(\.figureAnimation) private var figureAnimation
    @Environment(\.isInsideFigure) private var isInsideFigure
    @Environment(\.figureSpace) private var figureSpace
    @Environment(\.figureSizeAction) private var figureSizeAction
    @Environment(\.figureExtentAction) private var figureExtentAction
    @Environment(\.figureIsStill) private var figureIsStill

    /// How many nodes' phases have finished, which is what lines appearing in
    /// phases wait for — see ``LinePhaseTracker``.
    @State private var finished = 0
    @State private var phaseTracker = LinePhaseTracker()

    /// Renders a figure.
    ///
    /// - Parameters:
    ///   - figure: The figure to draw.
    ///   - spacing: How far apart lines sharing an edge or a waypoint are held.
    ///   - routing: How lines get where they are going. A line can override it,
    ///     but a figure almost always wants one kind of line throughout.
    public init(
        _ figure: Content,
        spacing: CGFloat = 14,
        routing: Line.Routing = .straight
    ) {
        self.figure = figure
        self.spacing = spacing
        self.routing = routing
    }

    /// The content and behavior of the view.
    public var body: some View {
        if isInsideFigure {
            content
        }
        else {
            GeometryReader { space in
                content
                    .environment(\.figureSpace, FigureSpace(proxy: space))
                    .frame(width: space.size.width, height: space.size.height)
            }
        }
    }

    /// The figure itself, in whatever space it is drawn in.
    @ViewBuilder private var content: some View {
        // The arrangement's root may hold several elements. Stacking them here
        // gives the outermost container a direction, which is the same one
        // `Placement.addresses(in:)` reads a line's leaving edge from.
        let lines = figure.lines
        let present = Set(figure.nodeIDs)
        let drawable = LineRouter.drawnIDs(for: lines, present: present.contains)
        let _ = figureAnimation == nil ? () : phaseTracker.note(drawable)

        VStack(alignment: .center, spacing: 12) { figure.arrangement.elementBody }
            .environment(\.waypointSpans, WaypointSpans.spans(for: lines, spacing: spacing))
            .environment(\.isInsideFigure, true)
            // At its own size, never the room around it: a figure that took
            // its shape from where it is drawn would be a different figure in
            // a narrower window.
            .fixedSize()
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { size in
                // A figure inside a node is the node's business, not whoever
                // asked the figure outside how big it is.
                if !isInsideFigure {
                    figureSizeAction?(size)
                }
            }
            .background {
                ZStack {
                    ForEach(drawable, id: \.self) { id in
                        LineStandIn(id: id, shown: figureAnimation == nil ? nil : finished >= phaseTracker.phase(for: id))
                            .transition(LineAppearTransition(id: id, drawsIn: figureAnimation == nil))
                    }
                }
            }
            // The lines are read outside the arrangement, in the space the figure
            // was given rather than the one it takes up. An arrangement that grows
            // or shrinks drags its own space with it, and an anchor resolved
            // against a space that is itself moving comes out somewhere the node
            // is not — which never shows while a figure is still, and shows up
            // badly the moment one animates.
            //
            // A figure inside a node is the exception: taking all the room it
            // is given would make the node that holds it take all of its own,
            // so it is as big as its arrangement.
            .frame(maxWidth: isInsideFigure ? nil : .infinity, maxHeight: isInsideFigure ? nil : .infinity)
            // Where this space is, for a figure inside a node to read its
            // nodes against — see `rects(in:marks:)`.
            .transformAnchorPreference(key: FigureMarksPreference.self, value: .bounds) { marks, anchor in
                marks.space = anchor
            }
            .backgroundPreferenceValue(FigureMarksPreference.self) { marks in
                GeometryReader { proxy in
                    let placements = figure.arrangement.placements
                    let rects = rects(in: proxy, marks: marks)
                    let routes = LineRouter.routes(
                        for: lines,
                        rects: rects,
                        outlines: marks.outlines,
                        addresses: Placement.addresses(in: placements),
                        waypointAxes: Placement.waypointAxes(in: placements),
                        routing: routing,
                        spacing: spacing
                    )
                    // Clusters' boxes first, outermost first, so that the
                    // lines inside them and across them are drawn on top.
                    let clusters = marks.clusters.sorted { ($0.value.depth, $0.key.rawValue) < ($1.value.depth, $1.key.rawValue) }
                    ForEach(clusters, id: \.key) { id, cluster in
                        if let rect = rects[id] {
                            ClusterBox(style: cluster.style)
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                                .opacity(cluster.opacity)
                        }
                    }
                    // Lines with something flowing along them are drawn again
                    // every frame; a figure with none never is.
                    let flowing = routes.contains { (lines[$0.line].style ?? lineStyle).flow != nil }
                    TimelineView(.animation(paused: !flowing || figureIsStill)) { timeline in
                        // Time since a fixed moment rather than since the figure
                        // appeared, so that the same figure in two windows flows
                        // in step.
                        let time = flowing && !figureIsStill ? timeline.date.timeIntervalSinceReferenceDate : 0
                        ZStack {
                            ForEach(routes) { route in
                                LineView(
                                    route: route,
                                    style: lines[route.line].style ?? lineStyle,
                                    appeared: marks.lines[route.id] ?? 1,
                                    time: time
                                )
                            }
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .overlayPreferenceValue(LabelBoundsPreference.self) { labels in
                        if !isInsideFigure, let figureExtentAction {
                            // Lines can reach past the nodes — a loop, a line
                            // going round the outside, the words on them — so
                            // what the figure draws is measured from all of it.
                            Color.clear
                                .onGeometryChange(for: CGRect.self) { space in
                                    // From the middle, where the nodes are
                                    // centred, however big the view turns out.
                                    extent(nodes: rects.values, routes: routes, labels: labels.map { space[$0] })
                                        .offsetBy(dx: -space.size.width / 2, dy: -space.size.height / 2)
                                } action: {
                                    figureExtentAction($0)
                                }
                        }
                    }
                }
            }
            .transaction { transaction in
                runPhases(in: &transaction)
            }
            // Lines asked to start before the nodes settle start once the
            // appearing nodes have come far enough.
            .onPreferenceChange(ElementAppearPreference.self) { slowest in
                guard let from = figureAnimation?.linesFrom, slowest >= from, let early = phaseTracker.takeEarly() else {
                    return
                }
                withAnimation(early.animation) {
                    finished = Swift.max(finished, early.phase)
                }
            }
            // A figure that first appears has nothing to wait for, and no
            // change for the lines it starts with to have appeared in.
            .onAppear {
                if let phase = phaseTracker.takeUnannounced() {
                    finished = Swift.max(finished, phase)
                }
            }
            // What the figure's parts publish is for this figure alone. Let
            // out, it would reach a figure this one is drawn inside, where a
            // node here sharing an ID with a node there would take its place.
            .transformPreference(FigureMarksPreference.self) { $0 = FigureMarksPreference.defaultValue }
            .transformPreference(ElementAppearPreference.self) { $0 = ElementAppearPreference.defaultValue }
            .transformPreference(LabelBoundsPreference.self) { $0 = LabelBoundsPreference.defaultValue }
    }
}

/// The space the outermost figure was given, for the figures inside it to
/// read their nodes against.
///
/// It does not move while the figures in it animate, which no space inside it
/// can promise: a figure in a node goes wherever its node goes, and an anchor
/// resolved against a space that is itself moving comes out somewhere the node
/// is not.
struct FigureSpace {
    let proxy: GeometryProxy
}

public extension View {
    /// Adds an action to perform when the size of a figure in this view
    /// changes — the size of the figure itself, not of the room it was given.
    ///
    /// A ``FigureView`` takes all the room it is given, so its own size says
    /// nothing about how big its figure is. Read this instead to make room
    /// for it, as a view that scrolls must:
    ///
    /// ```swift
    /// ScrollView([.horizontal, .vertical]) {
    ///     FigureView(BigFigure())
    ///         .onFigureSizeChange { size = $0 }
    ///         .frame(width: size.width, height: size.height)
    /// }
    /// ```
    ///
    /// The size is where the figure is going, not where it is: a change made
    /// in an animation reports the size it ends at, once. Figures drawn inside
    /// a node of the figure do not report theirs.
    func onFigureSizeChange(_ action: @escaping @MainActor (CGSize) -> Void) -> some View {
        environment(\.figureSizeAction, FigureSizeAction(action: action))
    }
}

/// What to do when a figure's size changes.
struct FigureSizeAction {
    let action: @MainActor (CGSize) -> Void

    @MainActor func callAsFunction(_ size: CGSize) {
        action(size)
    }
}

/// What to do with the extent of everything a figure draws.
struct FigureExtentAction {
    let action: @MainActor (CGRect) -> Void

    @MainActor func callAsFunction(_ extent: CGRect) {
        action(extent)
    }
}

/// Where the words on a figure's lines are, for the figure to know how far
/// what it draws reaches.
struct LabelBoundsPreference: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value += nextValue()
    }
}

extension EnvironmentValues {
    /// What to do when the figure's size changes, if anything.
    @Entry var figureSizeAction: FigureSizeAction? = nil

    /// What to do with the extent of everything the figure draws, if
    /// anything — measured, unlike its size, from its lines as well as its
    /// nodes, and from the middle of the view the figure is drawn in.
    @Entry var figureExtentAction: FigureExtentAction? = nil

    /// Whether the figure is drawn as a still picture, with whatever flows
    /// along its lines where it starts out.
    @Entry var figureIsStill = false

    /// The space the outermost figure was given, or `nil` outside any figure.
    @Entry var figureSpace: FigureSpace? = nil

    /// Whether the view is part of a figure — which a figure drawn inside a
    /// node is.
    @Entry var isInsideFigure = false
}

private extension FigureView {
    /// Where each node is, in the space the lines are drawn in.
    ///
    /// A figure on its own reads its nodes against that space, which is the
    /// one it was given and stays put. A figure inside a node has no such
    /// space of its own — its own goes wherever the node does — so it reads
    /// its nodes and its own space against the outermost figure's, which does
    /// stay put, and takes the one from the other.
    func rects(in proxy: GeometryProxy, marks: FigureMarks) -> [NodeID: CGRect] {
        guard isInsideFigure, let outermost = figureSpace?.proxy, let space = marks.space else {
            return marks.anchors.mapValues { proxy[$0] }
        }
        let origin = outermost[space].origin
        return marks.anchors.mapValues { anchor in
            outermost[anchor].offsetBy(dx: -origin.x, dy: -origin.y)
        }
    }

    /// Everything the figure draws, in the space the lines are drawn in: its
    /// nodes and clusters, its lines with their arrowheads, and the words on
    /// them.
    func extent(nodes: some Sequence<CGRect>, routes: [RoutedLine], labels: [CGRect]) -> CGRect {
        var extent = CGRect.null
        for rect in nodes {
            extent = extent.union(rect)
        }
        for route in routes {
            let style = figure.lines[route.line].style ?? lineStyle
            // An arrowhead is wider than the line it tips, and reaches as far
            // to either side of it as it is long at most.
            let reach = Swift.max(style.arrowHead.size ?? style.width * 5, style.width)
            for point in route.points {
                extent = extent.union(CGRect(x: point.x - reach, y: point.y - reach, width: reach * 2, height: reach * 2))
            }
        }
        for label in labels {
            extent = extent.union(label)
        }
        return extent
    }

    /// Runs the nodes' phase in the change being made, and has the lines'
    /// phase follow it.
    ///
    /// The nodes' phase, when it has an animation of its own, replaces the one
    /// the figure was changed in. The lines wait for the end of that animation
    /// — over the whole figure, since that is where the nodes are moving — and
    /// it can only be waited for from here: a completion added further in
    /// waits only for what animates further in.
    func runPhases(in transaction: inout Transaction) {
        guard let figureAnimation else {
            return
        }
        let animated = transaction.animation != nil
        if let nodes = figureAnimation.nodes, animated {
            transaction.animation = nodes
        }
        guard let phase = phaseTracker.takeUnannounced() else {
            return
        }

        let finish = $finished
        guard animated else {
            // Not animated, so there is nothing to wait for. Not now, though:
            // the change is still being made.
            Task { @MainActor in finish.wrappedValue = Swift.max(finish.wrappedValue, phase) }
            return
        }
        let lines = figureAnimation.lines ?? transaction.animation
        // Settling is still the fallback for lines asked to start early: a
        // change that brings in no node has nothing to measure.
        if figureAnimation.linesFrom != nil {
            phaseTracker.showEarly(phase, in: lines)
        }
        transaction.addAnimationCompletion {
            withAnimation(lines) {
                finish.wrappedValue = Swift.max(finish.wrappedValue, phase)
            }
        }
    }
}
