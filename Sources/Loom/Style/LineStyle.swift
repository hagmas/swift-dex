import SwiftUI

/// How a ``Line`` looks.
///
/// Like ``NodeStyle``, a style decides everything at once and styles do not
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
/// Every number is in points, drawn as it is, and colours are fixed
/// rather than following the system's appearance — for the same reasons as
/// ``NodeStyle``.
public struct LineStyle: Sendable {
    /// The colour of the line and its arrowheads.
    public var color: Color

    /// The thickness of the line.
    public var width: CGFloat

    /// The radius the line's corners are rounded to, or `0` for square ones.
    ///
    /// Only ever the corners a route already has: a line still goes where its
    /// routing sends it, and rounding just eases it round each turn. A corner
    /// between two short runs is rounded less, so the line never turns before
    /// it has arrived.
    public var cornerRadius: CGFloat

    /// The lengths of alternating dashes and gaps, or empty for a solid line.
    ///
    /// Arrowheads are always drawn solid.
    public var dash: [CGFloat]

    /// How the line's ends, and each of its dashes, are finished: square
    /// across the line where it stops, by default, or rounded off.
    ///
    /// A round end reaches half the line's width past where the line stops,
    /// as SwiftUI's does — into the outline of a node it meets, or under an
    /// arrowhead, where it does not show.
    public var lineCap: CGLineCap

    /// What the line's tipped ends look like.
    ///
    /// Which ends are tipped is not a matter of style: it is part of what the
    /// line says, and ``Line/arrow`` decides it.
    public var arrowHead: ArrowHead

    /// How the line appears when it is added to a figure that is changing.
    public var appear: Appear

    /// What flows along the line, from where it leaves to where it arrives,
    /// for as long as it is shown — or `nil` for a line that keeps still.
    ///
    /// Not an animation the figure is changed in, but part of how the line
    /// looks: a figure is still while nothing flows along it, and moves on
    /// its own while something does. To start or stop the flow, give the line
    /// a style with or without one.
    public var flow: Flow?

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

    /// The radius the corners of the colour behind the label are rounded
    /// to, or `0` for square ones.
    ///
    /// Held to half the label's height, as SwiftUI holds a rounded
    /// rectangle's, so a large enough radius makes a capsule of it.
    public var labelCornerRadius: CGFloat

    /// Creates a style.
    public init(
        color: Color = .black,
        width: CGFloat = 2,
        cornerRadius: CGFloat = 0,
        dash: [CGFloat] = [],
        lineCap: CGLineCap = .butt,
        arrowHead: ArrowHead = .filled,
        appear: Appear = .draw,
        flow: Flow? = nil,
        labelFontSize: CGFloat = 14,
        labelColor: Color = .black,
        labelBackground: Color = .white,
        labelPadding: CGFloat = 6,
        labelCornerRadius: CGFloat = 0
    ) {
        self.color = color
        self.width = width
        self.cornerRadius = cornerRadius
        self.dash = dash
        self.lineCap = lineCap
        self.arrowHead = arrowHead
        self.appear = appear
        self.flow = flow
        self.labelFontSize = labelFontSize
        self.labelColor = labelColor
        self.labelBackground = labelBackground
        self.labelPadding = labelPadding
        self.labelCornerRadius = labelCornerRadius
    }

    /// The style a line has when nothing says otherwise.
    public static let standard = LineStyle()
}

public extension LineStyle {
    /// What flows along a line, and how fast.
    ///
    /// ```swift
    /// LineStyle(flow: .dots)
    /// LineStyle(flow: .dashes(speed: 30))
    /// ```
    struct Flow: Hashable, Sendable {
        /// What it is that flows.
        public enum Mark: Hashable, Sendable {
            /// Dots travelling over the line, which is drawn as it would be
            /// without them. A dot sets off from where the line leaves and
            /// goes in under its arrowhead.
            case dots

            /// The line itself, dashed, its dashes marching along. They are
            /// the line's own ``LineStyle/dash`` if it has one, or else dashes
            /// and gaps half ``Flow/spacing`` long each.
            case dashes
        }

        /// What it is that flows.
        public var mark: Mark

        /// How far it moves along the line in a second, in points.
        public var speed: CGFloat

        /// How far apart one dot or dash is from the next, in points.
        public var spacing: CGFloat

        /// Creates a flow.
        public init(_ mark: Mark, speed: CGFloat = 60, spacing: CGFloat? = nil) {
            self.mark = mark
            self.speed = speed
            self.spacing = spacing ?? (mark == .dots ? 56 : 16)
        }

        /// Dots travelling over the line.
        public static let dots = Flow(.dots)

        /// The line, dashed, its dashes marching along.
        public static let dashes = Flow(.dashes)

        /// Dots travelling over the line, `speed` points a second and
        /// `spacing` points apart.
        public static func dots(speed: CGFloat = 60, spacing: CGFloat = 56) -> Flow {
            Flow(.dots, speed: speed, spacing: spacing)
        }

        /// The line, dashed, its dashes marching `speed` points a second,
        /// `spacing` points from one to the next.
        public static func dashes(speed: CGFloat = 60, spacing: CGFloat = 16) -> Flow {
            Flow(.dashes, speed: speed, spacing: spacing)
        }
    }

    /// How a line appears.
    ///
    /// Either way it takes the animation the figure was changed in — or, when
    /// the figure appears in phases, the lines' phase. It disappears at once,
    /// whichever it is.
    enum Appear: Hashable, Sendable {
        /// Drawn from where it leaves to where it arrives, its arrowhead
        /// travelling with the tip.
        case draw

        /// Faded in where it lies.
        case fade
    }
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
