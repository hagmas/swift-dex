import SwiftUI

/// A horizontal run of elements.
///
/// Loom computes no coordinates of its own: `Row` lowers onto an `HStack` and
/// SwiftUI does the layout. Everything in a figure is therefore positioned
/// relatively, which is what lets a figure be authored without a single number
/// in the API.
public struct Row<Content: FigureElement>: FigureElement {
    private let alignment: VerticalAlignment
    private let spacing: CGFloat
    private let content: Content

    /// Creates a row.
    ///
    /// - Parameters:
    ///   - alignment: How the elements line up across the row's height.
    ///   - spacing: The gap between elements.
    ///   - content: The elements, left to right.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat = 8,
        @FigureBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    /// The row, laid out by SwiftUI.
    public var elementBody: some View {
        ScaledHStack(alignment: alignment, spacing: spacing, content: content.elementBody)
    }

    /// The row's elements, as one horizontal group.
    public var placements: [Placement] {
        [.group(.horizontal, content.placements)]
    }
}

/// A vertical run of elements.
///
/// The counterpart to ``Row``; it lowers onto a `VStack`.
public struct Column<Content: FigureElement>: FigureElement {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content

    /// Creates a column.
    ///
    /// - Parameters:
    ///   - alignment: How the elements line up across the column's width.
    ///   - spacing: The gap between elements.
    ///   - content: The elements, top to bottom.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 8,
        @FigureBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    /// The column, laid out by SwiftUI.
    public var elementBody: some View {
        ScaledVStack(alignment: alignment, spacing: spacing, content: content.elementBody)
    }

    /// The column's elements, as one vertical group.
    public var placements: [Placement] {
        [.group(.vertical, content.placements)]
    }
}

/// An `HStack` whose spacing is in the figure's own terms.
private struct ScaledHStack<Content: View>: View {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    let content: Content

    @Environment(\.figureScale) private var scale

    var body: some View {
        HStack(alignment: alignment, spacing: spacing * scale) {
            content
        }
    }
}

/// A `VStack` whose spacing is in the figure's own terms.
struct ScaledVStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: Content

    @Environment(\.figureScale) private var scale

    var body: some View {
        VStack(alignment: alignment, spacing: spacing * scale) {
            content
        }
    }
}

/// A hole the size of a node.
///
/// Use it to keep columns lined up when one row holds fewer nodes than another.
/// It does not stretch: a row of three boxes above a row of `Empty` and one box
/// puts that box under the second column, where a flexible spacer would have
/// centred it instead.
public struct Empty: FigureElement {
    private let width: CGFloat?
    private let height: CGFloat?

    /// Creates a hole.
    ///
    /// - Parameters:
    ///   - width: How wide the hole is, or `nil` for the ``BoxStyle/minWidth``
    ///     of the boxes around it, so a row of default boxes lines up with a
    ///     row containing one.
    ///   - height: How tall the hole is, or `nil` to take no vertical space of
    ///     its own.
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }

    /// Nothing, occupying the space a node would have.
    public var elementBody: some View {
        Hole(width: width, height: height)
    }

    /// A gap: it holds a position without being a node.
    public var placements: [Placement] {
        [.gap]
    }
}

/// An empty frame, as wide as a box unless told otherwise.
private struct Hole: View {
    let width: CGFloat?
    let height: CGFloat?

    @Environment(\.boxStyle) private var style
    @Environment(\.figureScale) private var scale

    var body: some View {
        Color.clear
            .frame(width: (width ?? style.minWidth) * scale, height: height.map { $0 * scale })
    }
}
