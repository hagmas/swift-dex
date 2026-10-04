import SwiftUI

/// How a ``Line`` looks.
///
/// Like ``BoxStyle``, a style decides everything at once and styles do not
/// combine: a line's own style wins outright over the figure's, and whatever
/// it leaves out comes from its own defaults.
///
/// ```swift
/// extension LineStyle {
///     static let conformance = LineStyle(dash: [6, 4], arrowHead: .hollow)
/// }
///
/// Line(from: .user, to: .identifiable, style: .conformance)
/// ```
///
/// Applied to a ``FigureView`` a style is the figure's own. Lines are not part
/// of the arrangement, so a style on a ``Row`` or ``Column`` does not reach
/// them; a line that should look different says so itself.
///
/// Every number is in points, in the figure's own terms, and colours are fixed
/// rather than following the system's appearance — for the same reasons as
/// ``BoxStyle``.
public struct LineStyle: Sendable {
    /// The colour of the line and its arrowheads.
    public var color: Color

    /// The thickness of the line.
    public var width: CGFloat

    /// The lengths of alternating dashes and gaps, or empty for a solid line.
    ///
    /// Arrowheads are always drawn solid.
    public var dash: [CGFloat]

    /// What the line's tipped ends look like.
    ///
    /// Which ends are tipped is not a matter of style: it is part of what the
    /// line says, and ``Line/arrow`` decides it.
    public var arrowHead: ArrowHead

    /// The point size of the line's label.
    public var labelFontSize: CGFloat

    /// The colour of the line's label.
    public var labelColor: Color

    /// The colour behind the label.
    ///
    /// The label is painted over the line so the line reads as split by the
    /// words rather than running under them, so this should be the colour of
    /// whatever the figure is shown on.
    public var labelBackground: Color

    /// The space between the label's words and the line on either side.
    public var labelPadding: CGFloat

    /// Creates a style.
    public init(
        color: Color = .black,
        width: CGFloat = 1.5,
        dash: [CGFloat] = [],
        arrowHead: ArrowHead = .filled,
        labelFontSize: CGFloat = 10,
        labelColor: Color = .black,
        labelBackground: Color = .white,
        labelPadding: CGFloat = 4
    ) {
        self.color = color
        self.width = width
        self.dash = dash
        self.arrowHead = arrowHead
        self.labelFontSize = labelFontSize
        self.labelColor = labelColor
        self.labelBackground = labelBackground
        self.labelPadding = labelPadding
    }

    /// The style a line has when nothing says otherwise.
    public static let standard = LineStyle()
}

/// The mark at a tipped end of a line.
public struct ArrowHead: Hashable, Sendable {
    /// The outline of an arrowhead.
    public enum Shape: Hashable, Sendable {
        /// A solid triangle.
        case filled

        /// A triangle drawn as an outline, the way UML draws inheritance.
        case hollow

        /// Two strokes meeting at the tip, the way UML draws a dependency.
        case open
    }

    /// The outline of the arrowhead.
    public var shape: Shape

    /// How far the arrowhead reaches back from the tip, or `nil` for five times
    /// the line's width.
    ///
    /// Tied to the width by default so that a heavier line gets a heavier
    /// arrowhead without being told.
    public var size: CGFloat?

    /// Creates an arrowhead.
    public init(_ shape: Shape, size: CGFloat? = nil) {
        self.shape = shape
        self.size = size
    }

    /// A solid triangle, sized to the line.
    public static let filled = ArrowHead(.filled)

    /// A triangle drawn as an outline, sized to the line.
    public static let hollow = ArrowHead(.hollow)

    /// Two strokes meeting at the tip, sized to the line.
    public static let open = ArrowHead(.open)

    /// A solid triangle of a given size.
    public static func filled(size: CGFloat) -> ArrowHead {
        ArrowHead(.filled, size: size)
    }

    /// A triangle drawn as an outline, of a given size.
    public static func hollow(size: CGFloat) -> ArrowHead {
        ArrowHead(.hollow, size: size)
    }

    /// Two strokes meeting at the tip, of a given size.
    public static func open(size: CGFloat) -> ArrowHead {
        ArrowHead(.open, size: size)
    }
}

extension EnvironmentValues {
    @Entry var lineStyle: LineStyle = .standard
}

public extension View {
    /// Sets the style of every line in this view that does not have a style of
    /// its own.
    func lineStyle(_ style: LineStyle) -> some View {
        environment(\.lineStyle, style)
    }
}
