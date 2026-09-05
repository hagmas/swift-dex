import SwiftUI

/// A horizontal run of elements.
///
/// Loom computes no coordinates of its own: `Row` lowers onto an `HStack` and
/// SwiftUI does the layout. Everything in a figure is therefore positioned
/// relatively, which is what lets a figure be authored without a single number
/// in the API.
public struct Row<Content: FigureElement>: FigureElement {
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: Content

    /// Creates a row.
    ///
    /// - Parameters:
    ///   - alignment: How the elements line up across the row's height.
    ///   - spacing: The gap between elements, or `nil` for the system default.
    ///   - content: The elements, left to right.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @FigureBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    /// The row, laid out by SwiftUI.
    public var elementBody: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content.elementBody
        }
    }

    /// The identities of the elements in this run, in order.
    public var nodeIDs: [NodeID] {
        content.nodeIDs
    }
}

/// A vertical run of elements.
///
/// The counterpart to ``Row``; it lowers onto a `VStack`.
public struct Column<Content: FigureElement>: FigureElement {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: Content

    /// Creates a column.
    ///
    /// - Parameters:
    ///   - alignment: How the elements line up across the column's width.
    ///   - spacing: The gap between elements, or `nil` for the system default.
    ///   - content: The elements, top to bottom.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @FigureBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    /// The column, laid out by SwiftUI.
    public var elementBody: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content.elementBody
        }
    }

    /// The identities of the elements in this run, in order.
    public var nodeIDs: [NodeID] {
        content.nodeIDs
    }
}

/// A hole the size of a node.
///
/// Use it to keep columns lined up when one row holds fewer nodes than another.
/// It does not stretch: a row of three boxes above a row of `Empty` and one box
/// puts that box under the second column, where a flexible spacer would have
/// centred it instead.
public struct Empty: FigureElement {
    private let width: CGFloat
    private let height: CGFloat?

    /// Creates a hole.
    ///
    /// - Parameters:
    ///   - width: How wide the hole is. Defaults to ``Box``'s default minimum
    ///     width, so a row of default boxes lines up with a row containing one.
    ///   - height: How tall the hole is, or `nil` to take no vertical space of
    ///     its own.
    public init(width: CGFloat = Box.defaultMinWidth, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }

    /// Nothing, occupying the space a node would have.
    public var elementBody: some View {
        Color.clear
            .frame(width: width, height: height)
    }

    /// None: a hole is not a node.
    public var nodeIDs: [NodeID] {
        []
    }
}
