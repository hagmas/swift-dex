import SwiftUI

/// A node's content, framed as its style says.
///
/// Every node is drawn through this: its content says what it is, and the
/// frame — outline, fill, padding, widths — is the figure's, so that nodes of
/// every kind can be styled alike and lines know the outline they meet. The
/// text settings are passed to the content rather than applied to a text of
/// the frame's own, so any text a node draws takes them.
struct NodeFrame<Content: View>: View {
    let content: Content

    @Environment(\.nodeStyle) private var style
    @Environment(\.figureScale) private var scale

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: style.cornerRadius * scale)

        content
            .font(.system(size: style.fontSize * scale, weight: style.fontWeight))
            .foregroundStyle(style.textColor)
            .multilineTextAlignment(style.textAlignment)
            .padding(style.padding * scale)
            .frame(minWidth: style.minWidth * scale, alignment: Alignment(style.textAlignment))
            .modifier(WidthLimit(maxWidth: style.maxWidth.map { $0 * scale }))
            .background(shape.fill(style.fill))
            .overlay(shape.strokeBorder(style.stroke, lineWidth: style.strokeWidth * scale))
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
