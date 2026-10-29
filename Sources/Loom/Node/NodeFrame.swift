import SwiftUI

/// A node's content, framed as its style says.
///
/// Every node is drawn through this: its content says what it is, and the
/// frame — outline, fill, padding, widths — is the figure's, so that nodes of
/// every kind can be styled alike and lines know the outline they meet. The
/// text settings are passed to the content rather than applied to a text of
/// the frame's own, so any text a node draws takes them.
struct NodeFrame<Content: View>: View {
    let id: NodeID
    let content: Content

    @Environment(\.nodeStyle) private var style
    @Environment(\.figureScale) private var scale

    var body: some View {
        let outline = NodeOutline(shape: style.shape, scale: scale)

        content
            .font(.system(size: style.fontSize * scale, weight: style.fontWeight))
            .foregroundStyle(style.textColor)
            .multilineTextAlignment(style.textAlignment)
            .modifier(Enclosure(shape: style.shape, padding: style.padding * scale))
            .frame(minWidth: style.minWidth * scale, alignment: Alignment(style.textAlignment))
            .modifier(WidthLimit(maxWidth: style.maxWidth.map { $0 * scale }))
            .background {
                if style.shape != .none {
                    outline.fill(style.fill)
                }
            }
            .overlay {
                if style.shape != .none {
                    outline.strokeBorder(style.stroke, lineWidth: style.strokeWidth * scale)
                }
            }
            // Lines meet the outline, so they are told what it is.
            .transformPreference(FigureMarksPreference.self) { marks in
                marks.outlines[id] = Outline(shape: style.shape, scale: scale)
            }
    }
}

/// Makes room around the content for its outline, and centres it there.
///
/// A rectangle needs only the padding. A circle, an ellipse or a diamond has to
/// reach round the content's corners, which takes more — see
/// ``NodeShape/enclosure(of:padding:)``.
private struct Enclosure: ViewModifier {
    let shape: NodeShape
    let padding: EdgeInsets

    func body(content: Content) -> some View {
        switch shape {
        case .roundedRectangle, .capsule, .none:
            content.padding(padding)
        case .circle, .ellipse, .diamond:
            EnclosureLayout(shape: shape, padding: padding) { content }
        }
    }
}

private struct EnclosureLayout: Layout {
    let shape: NodeShape
    let padding: EdgeInsets

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let content = subviews.first else {
            return .zero
        }
        return shape.enclosure(of: size(of: content, within: proposal), padding: padding)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let content = subviews.first else {
            return
        }
        content.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: ProposedViewSize(size(of: content, within: proposal))
        )
    }

    /// How big the content comes out, if the whole frame is to fit `proposal`.
    ///
    /// An ellipse's width and a diamond's depend on the content's width alone,
    /// so the content is simply offered that much less. A circle's depends on
    /// the content's diagonal, height and all — and the narrower the content,
    /// the more lines it wraps onto and the taller it grows — so no one width
    /// can be worked out ahead. See ``widestFitting(_:within:)``.
    private func size(of content: LayoutSubview, within proposal: ProposedViewSize) -> CGSize {
        guard let width = proposal.width else {
            return content.sizeThatFits(.unspecified)
        }
        let room = width - padding.leading - padding.trailing

        switch shape {
        case .ellipse:
            return content.measured(at: room / 2.squareRoot())
        case .diamond:
            return content.measured(at: room / 2)
        case .circle:
            let across = padding.leading + padding.trailing
            let down = padding.top + padding.bottom
            return widestFitting(content, within: width - Swift.max(across, down))
        default:
            return content.measured(at: room)
        }
    }

    /// The content at the widest it can be and still have its diagonal
    /// within `diameter` — which is to say on the fewest lines.
    ///
    /// Too wide, and the content's own width is too much; too narrow, and the
    /// lines it wraps onto stack too tall. Somewhere between, it fits. So the
    /// content is tried at the whole width first, then a tenth narrower at a
    /// time until it fits, and the last step is halved down until the widest
    /// width that fits is close enough.
    ///
    /// Content that fits at no width at all — too much to go round in a
    /// circle that size — is left as wide as it would be anyway, rather than
    /// narrowed until its words break.
    private func widestFitting(_ content: LayoutSubview, within diameter: CGFloat) -> CGSize {
        func fits(_ width: CGFloat) -> Bool {
            content.measured(at: width).diagonal <= diameter + Self.slack
        }

        guard !fits(diameter) else {
            return content.measured(at: diameter)
        }
        var tooWide = diameter
        var narrowEnough: CGFloat?
        for tenth in 1..<10 {
            let width = diameter * CGFloat(10 - tenth) / 10
            if fits(width) {
                narrowEnough = width
                break
            }
            tooWide = width
        }
        guard var widest = narrowEnough else {
            return content.measured(at: diameter)
        }
        for _ in 0..<Self.halvings {
            let middle = (widest + tooWide) / 2
            if fits(middle) {
                widest = middle
            }
            else {
                tooWide = middle
            }
        }
        return content.measured(at: widest)
    }

    /// How many times the last step is halved: down to within a point or so
    /// of the widest width that fits, for any circle a figure would hold.
    private static let halvings = 5

    /// How far a measurement may be off and still count as fitting — text
    /// sizes are rounded to the pixel grid.
    private static let slack: CGFloat = 0.5
}

private extension LayoutSubview {
    /// The size the view takes when offered `width`, and as much height as it
    /// likes.
    func measured(at width: CGFloat) -> CGSize {
        sizeThatFits(ProposedViewSize(width: Swift.max(width, 0), height: nil))
    }
}

private extension CGSize {
    var diagonal: CGFloat {
        (width * width + height * height).squareRoot()
    }
}

/// Holds a view to a width without making it any wider.
///
/// `frame(maxWidth:)` would do the first and also the second: a frame with a
/// maximum takes as much as it is offered up to that maximum, so every box
/// would stretch to its limit. This only narrows what is offered, and the
/// view keeps whatever size it then chooses.
private struct WidthLimit: ViewModifier {
    let maxWidth: CGFloat?

    func body(content: Content) -> some View {
        if let maxWidth {
            WidthLimitLayout(maxWidth: maxWidth) { content }
        }
        else {
            content
        }
    }
}

private struct WidthLimitLayout: Layout {
    let maxWidth: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = min(proposal.width ?? .infinity, maxWidth)
        return subviews.first?.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
    }
}

private extension EdgeInsets {
    static func * (insets: EdgeInsets, scale: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: insets.top * scale,
            leading: insets.leading * scale,
            bottom: insets.bottom * scale,
            trailing: insets.trailing * scale
        )
    }
}

private extension Alignment {
    init(_ alignment: TextAlignment) {
        switch alignment {
        case .leading: self = .leading
        case .center: self = .center
        case .trailing: self = .trailing
        }
    }
}
