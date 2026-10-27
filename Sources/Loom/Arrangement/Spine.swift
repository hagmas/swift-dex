import SwiftUI

public extension HorizontalAlignment {
    /// A line down a column for chosen nodes to sit on.
    ///
    /// A column aligned on its spine lines up every row on it: by its middle,
    /// unless something in the row says which part of it belongs on the line.
    /// So a row thrown off-centre by a waypoint beside its box can still put
    /// that box under the others, and the lines between them run straight.
    ///
    /// ```swift
    /// Column(alignment: .columnSpine) {
    ///     Row { Box(.start, title: "Start") }
    ///     Row(spacing: 64) {
    ///         Box(.fetch, title: "Fetch data").aligned(on: .columnSpine)
    ///         Waypoint(.back)
    ///     }
    ///     Row { Box(.valid, title: "Valid?") }
    /// }
    /// ```
    ///
    /// This is SwiftUI's own alignment, so it has SwiftUI's limit: one line
    /// per column. Two separate pairs of nodes cannot each be lined up in the
    /// same column.
    ///
    /// Named for the container it runs through, as ``SwiftUICore/VerticalAlignment/rowSpine``
    /// is: both being called `spine` would leave `.aligned(on: .spine)` unable
    /// to say which it meant.
    static let columnSpine = HorizontalAlignment(ColumnSpine.self)
}

public extension VerticalAlignment {
    /// A line across a row for chosen nodes to sit on — the counterpart to
    /// ``SwiftUICore/HorizontalAlignment/columnSpine``.
    static let rowSpine = VerticalAlignment(RowSpine.self)
}

private enum ColumnSpine: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

private enum RowSpine: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
    }
}

public extension FigureElement {
    /// Says where this element sits on a horizontal alignment — SwiftUI's
    /// `alignmentGuide(_:computeValue:)`, for an element of a figure.
    func alignmentGuide(
        _ alignment: HorizontalAlignment,
        computeValue: @escaping @Sendable (ViewDimensions) -> CGFloat
    ) -> AlignmentGuided<Self> {
        AlignmentGuided(self, guide: .horizontal(alignment, computeValue))
    }

    /// Says where this element sits on a vertical alignment — SwiftUI's
    /// `alignmentGuide(_:computeValue:)`, for an element of a figure.
    func alignmentGuide(
        _ alignment: VerticalAlignment,
        computeValue: @escaping @Sendable (ViewDimensions) -> CGFloat
    ) -> AlignmentGuided<Self> {
        AlignmentGuided(self, guide: .vertical(alignment, computeValue))
    }

    /// Puts this element's middle on a horizontal alignment, such as
    /// ``SwiftUICore/HorizontalAlignment/columnSpine``.
    func aligned(on alignment: HorizontalAlignment) -> AlignmentGuided<Self> {
        alignmentGuide(alignment) { $0[HorizontalAlignment.center] }
    }

    /// Puts this element's middle on a vertical alignment, such as
    /// ``SwiftUICore/VerticalAlignment/rowSpine``.
    func aligned(on alignment: VerticalAlignment) -> AlignmentGuided<Self> {
        alignmentGuide(alignment) { $0[VerticalAlignment.center] }
    }
}

/// An element that says where it sits on an alignment.
///
/// It adds nothing to the arrangement's shape: it is the same element, moved
/// by its container to line up.
public struct AlignmentGuided<Wrapped: FigureElement>: FigureElement {
    enum Guide {
        case horizontal(HorizontalAlignment, @Sendable (ViewDimensions) -> CGFloat)
        case vertical(VerticalAlignment, @Sendable (ViewDimensions) -> CGFloat)
    }

    private let wrapped: Wrapped
    private let guide: Guide

    init(_ wrapped: Wrapped, guide: Guide) {
        self.wrapped = wrapped
        self.guide = guide
    }

    /// The element, with its alignment guide.
    @ViewBuilder public var elementBody: some View {
        switch guide {
        case .horizontal(let alignment, let value):
            wrapped.elementBody.alignmentGuide(alignment, computeValue: value)
        case .vertical(let alignment, let value):
            wrapped.elementBody.alignmentGuide(alignment, computeValue: value)
        }
    }

    /// The element's placements, unchanged.
    public var placements: [Placement] {
        wrapped.placements
    }
}
