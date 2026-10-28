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
        return shape.enclosure(of: content.sizeThatFits(contentProposal(within: proposal)), padding: padding)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let content = subviews.first else {
            return
        }
        let size = content.sizeThatFits(contentProposal(within: proposal))
        content.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: ProposedViewSize(size)
        )
    }

    /// How wide the content may be, if the whole frame is to fit `proposal`.
    private func contentProposal(within proposal: ProposedViewSize) -> ProposedViewSize {
        guard let width = proposal.width else {
            return .unspecified
        }
        let room = Swift.max(width - padding.leading - padding.trailing, 0)
        let content: CGFloat =
            switch shape {
            case .ellipse: room / 2.squareRoot()
            case .diamond: room / 2
            default: room
            }
        return ProposedViewSize(width: content, height: nil)
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
