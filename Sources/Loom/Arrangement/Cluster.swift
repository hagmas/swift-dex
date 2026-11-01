import SwiftUI

/// A box around some of a figure's elements, to show that they belong
/// together — a service's parts, a network's machines.
///
/// ```swift
/// Column {
///     Row { TextNode(.client, title: "Client") }
///     Cluster(.backend, title: "Backend") {
///         Row {
///             TextNode(.api, title: "API")
///             TextNode(.db, title: "DB")
///         }
///     }
/// }
///
/// Line(from: .client, to: .api)      // across the box
/// Line(from: .client, to: .backend)  // to the box as a whole
/// ```
///
/// Unlike a figure drawn inside a node, a cluster is part of the figure it is
/// in: its elements share the figure's node IDs, and lines cross its box
/// freely, to the elements in it or to the box itself. To the arrangement
/// around it, it is one element at one position, as a node is; its elements
/// are stacked in it from top to bottom, as a figure's are.
///
/// The box is drawn beneath the figure's lines, so that lines inside it and
/// lines across it show; the title is drawn with the nodes. Its look is a
/// ``ClusterStyle``.
public struct Cluster<Content: FigureElement>: Connectable {
    /// The identity lines refer to, to reach the box as a whole.
    public let id: NodeID

    private let title: String?
    private let content: Content

    /// Creates a cluster.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to, to reach the box as a whole.
    ///   - title: Words across the top of the box.
    ///   - content: The elements in the box, top to bottom.
    public init(_ id: NodeID, title: String? = nil, @FigureBuilder content: () -> Content) {
        self.id = id
        self.title = title
        self.content = content()
    }

    /// The cluster's title and elements, reporting where the box is.
    public var elementBody: some View {
        ClusterView(id: id, title: title, content: content.elementBody)
    }

    /// The cluster, holding its elements.
    public var placements: [Placement] {
        [.cluster(id, content.placements)]
    }
}

/// What a cluster reports upwards, for its box to be drawn beneath the lines.
struct ClusterMark {
    let style: ClusterStyle

    /// How many clusters this one is inside, so that the boxes are drawn
    /// from the outside in.
    let depth: Int

    /// How much of the cluster has appeared, which its box follows: the box is
    /// drawn apart from the cluster, so the cluster's own fade never reaches it.
    let opacity: CGFloat
}

extension EnvironmentValues {
    /// How many clusters the view is inside.
    @Entry var clusterDepth = 0
}

private struct ClusterView<Content: View>: View {
    let id: NodeID
    let title: String?
    let content: Content

    @Environment(\.clusterStyle) private var style
    @Environment(\.figureScale) private var scale
    @Environment(\.clusterDepth) private var depth
    @Environment(\.appearOpacity) private var opacity

    var body: some View {
        ClusterLayout(alignment: style.titleAlignment, spacing: style.titleSpacing * scale) {
            if let title {
                Text(title)
                    .font(.system(size: style.titleSize * scale, weight: style.titleWeight))
                    .foregroundStyle(style.titleColor)
            }
            ScaledVStack(alignment: .center, spacing: 8, content: content)
                .environment(\.clusterDepth, depth + 1)
        }
        .padding(style.padding * scale)
        // Drawn inside the box, never past it, as a node's content is: an
        // element added to a cluster is laid out where it ends up at once,
        // while the box grows towards it.
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius * scale))
        .reportsBounds(as: id)
        .transformPreference(FigureMarksPreference.self) { marks in
            // Lines to the cluster meet its box.
            marks.outlines[id] = Outline(shape: .roundedRectangle(cornerRadius: style.cornerRadius), scale: scale)
            marks.clusters[id] = ClusterMark(style: style, depth: depth, opacity: opacity)
        }
    }
}

/// The title across the top, where its style says, and the elements centred
/// beneath it.
///
/// A `VStack` lines everything in it up one way; the title and the elements
/// want two.
///
/// Both are laid out at their own size, whatever the cluster is offered, as a
/// figure is. A row works out how far what is in it gives by offering it no
/// width at all, and a title offered none breaks after every letter: the
/// cluster would make room for a title that tall, then set it on one line.
private struct ClusterLayout: Layout {
    let alignment: HorizontalAlignment
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let gaps = CGFloat(Swift.max(sizes.count - 1, 0)) * spacing
        return CGSize(
            width: sizes.map(\.width).max() ?? 0,
            height: sizes.map(\.height).reduce(0, +) + gaps
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            // Only the title, which comes first when there is one, sits where
            // the style says; the elements are centred.
            let isTitle = index == 0 && subviews.count > 1
            let x: CGFloat =
                switch isTitle ? alignment : .center {
                case .leading: bounds.minX
                case .trailing: bounds.maxX - size.width
                default: bounds.midX - size.width / 2
                }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            y += size.height + spacing
        }
    }
}

/// A cluster's box.
struct ClusterBox: View {
    let style: ClusterStyle
    let scale: CGFloat

    var body: some View {
        let box = RoundedRectangle(cornerRadius: style.cornerRadius * scale)
        box.fill(style.fill)
            .overlay {
                box.strokeBorder(
                    style.stroke,
                    style: StrokeStyle(lineWidth: style.strokeWidth * scale, dash: style.dash.map { $0 * scale })
                )
            }
    }
}
