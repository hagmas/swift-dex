import SwiftUI

/// How a ``Box`` looks.
///
/// A style decides everything about a box's appearance at once. Styles do not
/// combine: the one nearest the box wins outright, and whatever it leaves out
/// comes from its own defaults, never from a style further out.
///
/// ```swift
/// extension BoxStyle {
///     static let classType = BoxStyle(fill: .blue.opacity(0.12), stroke: .blue)
///     static let structType = BoxStyle(fill: .orange.opacity(0.12), stroke: .orange)
/// }
///
/// Row {
///     Box(.user, title: "User").boxStyle(.classType)
///     Box(.point, title: "Point").boxStyle(.structType)
/// }
/// ```
///
/// Applied to a ``FigureView`` a style is the figure's own; applied to a
/// ``Row`` or ``Column`` it covers everything inside; applied to a box it
/// covers that box alone.
///
/// Every number is in points, in the figure's own terms. A figure is not told
/// how big it will be shown: a host that wants it larger scales the whole of it.
///
/// Colours are fixed rather than following the system's appearance. A figure
/// is content, not interface, and should look the same wherever it is shown.
public struct BoxStyle: Sendable {
    /// The colour inside the box.
    public var fill: Color

    /// The colour of the box's outline.
    public var stroke: Color

    /// The thickness of the box's outline.
    public var strokeWidth: CGFloat

    /// The colour of the title.
    public var textColor: Color

    /// The point size of the title.
    public var fontSize: CGFloat

    /// The weight of the title.
    public var fontWeight: Font.Weight

    /// How the lines of a title that wraps line up with each other, and where
    /// a title narrower than the box sits within it.
    public var textAlignment: TextAlignment

    /// The space between the title and the outline.
    public var padding: EdgeInsets

    /// The radius of the box's corners.
    public var cornerRadius: CGFloat

    /// The width a box will not shrink below.
    ///
    /// Ragged box widths are the first thing that makes a figure look untidy,
    /// so the default is a width rather than none. It is also how wide an
    /// ``Empty`` is unless told otherwise, so a hole lines up with the boxes
    /// around it.
    public var minWidth: CGFloat

    /// The width a box will not grow beyond, or `nil` for no limit.
    ///
    /// A title too long to fit wraps, and the box grows taller instead.
    public var maxWidth: CGFloat?

    /// Creates a style.
    public init(
        fill: Color = .white,
        stroke: Color = .black,
        strokeWidth: CGFloat = 1,
        textColor: Color = .black,
        fontSize: CGFloat = 13,
        fontWeight: Font.Weight = .regular,
        textAlignment: TextAlignment = .center,
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        cornerRadius: CGFloat = 8,
        minWidth: CGFloat = 140,
        maxWidth: CGFloat? = nil
    ) {
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textAlignment = textAlignment
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.minWidth = minWidth
        self.maxWidth = maxWidth
    }

    /// The style a box has when nothing says otherwise.
    public static let standard = BoxStyle()
}

extension EnvironmentValues {
    @Entry var boxStyle: BoxStyle = .standard
}

public extension View {
    /// Sets the style of every box in this view — for a ``FigureView``, every
    /// box in the figure that does not have a style of its own.
    func boxStyle(_ style: BoxStyle) -> some View {
        environment(\.boxStyle, style)
    }
}

public extension FigureElement {
    /// Sets the style of every box in this element that does not have a style
    /// of its own.
    func boxStyle(_ style: BoxStyle) -> BoxStyled<Self> {
        BoxStyled(self, style: style)
    }
}

/// An element whose boxes have been given a style.
///
/// It adds nothing to the arrangement's shape: a styled row is still the same
/// row, in the same place.
public struct BoxStyled<Wrapped: FigureElement>: FigureElement {
    private let wrapped: Wrapped
    private let style: BoxStyle

    init(_ wrapped: Wrapped, style: BoxStyle) {
        self.wrapped = wrapped
        self.style = style
    }

    /// The element, with the style in its environment.
    public var elementBody: some View {
        wrapped.elementBody
            .environment(\.boxStyle, style)
    }

    /// The element's placements, unchanged.
    public var placements: [Placement] {
        wrapped.placements
    }
}
