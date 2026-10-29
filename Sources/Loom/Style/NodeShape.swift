import SwiftUI

/// The outline a node is framed in.
///
/// A fixed set rather than any `Shape`, because a frame has to be sized to
/// hold its content, and how big that is depends on the shape: a circle must
/// be as wide as its content's diagonal, a diamond twice as wide as its
/// content. An arbitrary shape gives no way to know.
///
/// Lines meet the outline, not the rectangle around it, wherever along a side
/// they arrive.
public enum NodeShape: Hashable, Sendable {
    /// A rectangle with rounded corners, the default.
    case roundedRectangle(cornerRadius: CGFloat)

    /// A rectangle with fully rounded ends.
    case capsule

    /// A circle, as wide as it is tall.
    case circle

    /// An ellipse.
    case ellipse

    /// A diamond, its corners at the middle of each side.
    case diamond

    /// No outline: the node's content is drawn on its own, and lines meet the
    /// rectangle around it.
    ///
    /// For a node that draws its own outline in its content.
    case none
}

extension NodeShape {
    /// How big the frame has to be to hold `content`, with `padding` between
    /// the content and the outline.
    ///
    /// The rectangular shapes simply pad. The round ones and the diamond
    /// enclose the content's corners, which needs more room: a circle as wide
    /// as the content's diagonal, an ellipse √2 times as wide and as tall, a
    /// diamond twice.
    func enclosure(of content: CGSize, padding: EdgeInsets) -> CGSize {
        let across = padding.leading + padding.trailing
        let down = padding.top + padding.bottom
        switch self {
        case .roundedRectangle, .capsule, .none:
            return CGSize(width: content.width + across, height: content.height + down)
        case .circle:
            let diameter =
                (content.width * content.width + content.height * content.height).squareRoot()
                + Swift.max(across, down)
            return CGSize(width: diameter, height: diameter)
        case .ellipse:
            return CGSize(
                width: content.width * 2.squareRoot() + across,
                height: content.height * 2.squareRoot() + down
            )
        case .diamond:
            return CGSize(width: content.width * 2 + across, height: content.height * 2 + down)
        }
    }

    /// The outline drawn in `rect`, with any corner radius multiplied by
    /// `scale`.
    ///
    /// Made from SwiftUI's own shapes, so a rounded rectangle has SwiftUI's
    /// continuous corners — which the lines then meet exactly.
    ///
    /// Inset by `inset` the way SwiftUI insets its shapes — a rounded
    /// rectangle's corners tighten as it shrinks — so that an outline stroked
    /// inside the frame draws as SwiftUI's own would.
    func path(in rect: CGRect, scale: CGFloat, inset: CGFloat = 0) -> Path {
        switch self {
        case .roundedRectangle(let cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius * scale).inset(by: inset).path(in: rect)
        case .capsule:
            Capsule().inset(by: inset).path(in: rect)
        case .circle, .ellipse:
            Ellipse().inset(by: inset).path(in: rect)
        case .diamond:
            Path { path in
                let rect = rect.insetBy(dx: inset, dy: inset)
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
                path.closeSubpath()
            }
        case .none:
            Rectangle().inset(by: inset).path(in: rect)
        }
    }
}

/// A node's outline as the lines see it: a shape, at the figure's scale.
struct Outline: Sendable {
    let shape: NodeShape
    let scale: CGFloat

    func path(in rect: CGRect) -> CGPath {
        shape.path(in: rect, scale: scale).cgPath
    }
}

/// A node's outline as a SwiftUI shape, to fill and stroke.
struct NodeOutline: InsettableShape {
    let shape: NodeShape
    let scale: CGFloat
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        shape.path(in: rect, scale: scale, inset: inset)
    }

    func inset(by amount: CGFloat) -> NodeOutline {
        var outline = self
        outline.inset += amount
        return outline
    }
}
