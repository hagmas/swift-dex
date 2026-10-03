import SwiftUI

/// A rounded rectangle with a label in it — the node nine figures out of ten
/// are made of.
///
/// `Box` is to ``Node`` what `Text` is to `View`: the concrete type you reach
/// for until you need your own.
///
/// ```swift
/// Box(.repository, title: "Repository")
/// ```
///
/// How it looks is up to the ``BoxStyle`` around it.
public struct Box: Node {
    /// The identity lines refer to.
    public let id: NodeID

    /// The text shown in the box.
    public var title: String

    /// Creates a box.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to.
    ///   - title: The text shown in the box.
    public init(_ id: NodeID, title: String) {
        self.id = id
        self.title = title
    }

    /// The content and behavior of the view.
    public var body: some View {
        BoxView(title: title)
    }
}

/// A box as drawn, in whatever style it finds itself in.
private struct BoxView: View {
    let title: String

    @Environment(\.boxStyle) private var style
    @Environment(\.figureScale) private var scale

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: style.cornerRadius * scale)

        Text(title)
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
