import SwiftUI

/// How a ``Node`` is framed, and how the text in it is set.
///
/// The frame — outline, fill, padding, widths — is drawn by the figure around
/// whatever a node shows, and the text settings are passed to the node's
/// content, so a style applies alike to a ``TextNode`` and to a node of your
/// own.
///
/// A style decides everything about a node's appearance at once. Styles do not
/// combine: the one nearest the node wins outright, and whatever it leaves out
/// comes from its own defaults, never from a style further out.
///
/// ```swift
/// extension NodeStyle {
///     static let classType = NodeStyle(fill: .blue.opacity(0.12), stroke: .blue)
///     static let structType = NodeStyle(fill: .orange.opacity(0.12), stroke: .orange)
/// }
///
/// Row {
///     TextNode(.user, title: "User").nodeStyle(.classType)
///     TextNode(.point, title: "Point").nodeStyle(.structType)
/// }
/// ```
///
/// Applied to a ``FigureView`` a style is the figure's own; applied to a
/// ``Row`` or ``Column`` it covers everything inside; applied to a node it
/// covers that node alone.
///
/// Every number is in points, in the figure's own terms. A figure is not told
/// how big it will be shown: a host that wants it larger scales the whole of it.
///
/// Colours are fixed rather than following the system's appearance. A figure
/// is content, not interface, and should look the same wherever it is shown.
public struct NodeStyle: Sendable {
    /// The outline the node is framed in.
    public var shape: NodeShape

    /// The colour inside the node.
    public var fill: Color

    /// The colour of the node's outline.
    public var stroke: Color

    /// The thickness of the node's outline.
    public var strokeWidth: CGFloat

    /// The colour of the node's text.
    public var textColor: Color

    /// The point size of the node's text.
    public var fontSize: CGFloat

    /// The weight of the node's text.
    public var fontWeight: Font.Weight

    /// How the lines of a title that wraps line up with each other, and where
    /// a title narrower than the node sits within it.
    public var textAlignment: TextAlignment

    /// The space between the title and the outline.
    public var padding: EdgeInsets

    /// The width a node will not shrink below.
    ///
    /// Ragged node widths are the first thing that makes a figure look untidy,
    /// so the default is a width rather than none. It is also how wide an
    /// ``Empty`` is unless told otherwise, so a hole lines up with the nodes
    /// around it.
    ///
    /// A circle's is its diameter, so a circle grows taller with it and stays
    /// round.
    public var minWidth: CGFloat

    /// The width a node will not grow beyond, or `nil` for no limit.
    ///
    /// A title too long to fit wraps, and the node grows taller instead.
    public var maxWidth: CGFloat?

    /// Creates a style.
    public init(
        shape: NodeShape = .roundedRectangle(cornerRadius: 8),
        fill: Color = .white,
        stroke: Color = .black,
        strokeWidth: CGFloat = 1,
        textColor: Color = .black,
        fontSize: CGFloat = 13,
        fontWeight: Font.Weight = .regular,
        textAlignment: TextAlignment = .center,
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        minWidth: CGFloat = 140,
        maxWidth: CGFloat? = nil
    ) {
        self.shape = shape
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textAlignment = textAlignment
        self.padding = padding
        self.minWidth = minWidth
        self.maxWidth = maxWidth
    }

    /// The style a node has when nothing says otherwise.
    public static let standard = NodeStyle()

    /// This style with some of it changed.
    ///
    /// Styles do not combine, so a style that should share most of another's
    /// look is made from it:
    ///
    /// ```swift
    /// extension NodeStyle {
    ///     static let brand = NodeStyle(fill: .indigo.opacity(0.1), stroke: .indigo)
    ///     static let state = NodeStyle.brand.with { $0.shape = .circle }
    /// }
    /// ```
    public func with(_ change: (inout NodeStyle) -> Void) -> NodeStyle {
        var style = self
        change(&style)
        return style
    }
}

extension EnvironmentValues {
    @Entry var nodeStyle: NodeStyle = .standard
}

public extension View {
    /// Sets the style of every node in this view — for a ``FigureView``, every
    /// node in the figure that does not have a style of its own.
    func nodeStyle(_ style: NodeStyle) -> some View {
        environment(\.nodeStyle, style)
    }
}

public extension FigureElement {
    /// Sets the style of every node in this element that does not have a style
    /// of its own.
    func nodeStyle(_ style: NodeStyle) -> NodeStyled<Self> {
        NodeStyled(self, style: style)
    }
}

/// An element whose nodes have been given a style.
///
/// It adds nothing to the arrangement's shape: a styled row is still the same
/// row, in the same place.
public struct NodeStyled<Wrapped: FigureElement>: FigureElement {
    private let wrapped: Wrapped
    private let style: NodeStyle

    init(_ wrapped: Wrapped, style: NodeStyle) {
        self.wrapped = wrapped
        self.style = style
    }

    /// The element, with the style in its environment.
    public var elementBody: some View {
        wrapped.elementBody
            .environment(\.nodeStyle, style)
    }

    /// The element's placements, unchanged.
    public var placements: [Placement] {
        wrapped.placements
    }
}
