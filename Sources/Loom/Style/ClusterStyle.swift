import SwiftUI

/// How a ``Cluster`` is boxed, and how its title is set.
///
/// A style of its own rather than a ``NodeStyle``, so that styling a cluster
/// leaves the nodes in it as they were: a cluster is not a node, and has no
/// widths or text alignment to speak of.
///
/// ```swift
/// extension ClusterStyle {
///     static let vpc = ClusterStyle.standard.with {
///         $0.stroke = .orange
///         $0.dash = [6, 4]
///     }
/// }
///
/// Cluster(.vpc, title: "VPC") { … }
///     .clusterStyle(.vpc)
/// ```
///
/// As with ``NodeStyle``, styles do not combine, the numbers are in the
/// figure's own terms, and the colours are fixed.
public struct ClusterStyle: Sendable {
    /// The colour inside the box.
    public var fill: Color

    /// The colour of the box's outline.
    public var stroke: Color

    /// The thickness of the box's outline.
    public var strokeWidth: CGFloat

    /// The dash pattern of the box's outline, or empty for a solid one.
    public var dash: [CGFloat]

    /// How rounded the box's corners are.
    public var cornerRadius: CGFloat

    /// The space between the box and what it holds.
    public var padding: EdgeInsets

    /// The colour of the title.
    public var titleColor: Color

    /// The point size of the title.
    public var titleSize: CGFloat

    /// The weight of the title.
    public var titleWeight: Font.Weight

    /// Where the title sits across the top of the box.
    public var titleAlignment: HorizontalAlignment

    /// The space between the title and what the box holds.
    public var titleSpacing: CGFloat

    /// Creates a cluster style.
    public init(
        fill: Color = Color(white: 0.97),
        stroke: Color = Color(white: 0.6),
        strokeWidth: CGFloat = 1,
        dash: [CGFloat] = [],
        cornerRadius: CGFloat = 12,
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16),
        titleColor: Color = Color(white: 0.35),
        titleSize: CGFloat = 11,
        titleWeight: Font.Weight = .semibold,
        titleAlignment: HorizontalAlignment = .leading,
        titleSpacing: CGFloat = 12
    ) {
        self.fill = fill
        self.stroke = stroke
        self.strokeWidth = strokeWidth
        self.dash = dash
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.titleColor = titleColor
        self.titleSize = titleSize
        self.titleWeight = titleWeight
        self.titleAlignment = titleAlignment
        self.titleSpacing = titleSpacing
    }

    /// The style a cluster has when nothing says otherwise.
    public static let standard = ClusterStyle()

    /// This style with some of it changed — see ``NodeStyle/with(_:)``.
    public func with(_ change: (inout ClusterStyle) -> Void) -> ClusterStyle {
        var style = self
        change(&style)
        return style
    }
}

extension EnvironmentValues {
    @Entry var clusterStyle: ClusterStyle = .standard
}

public extension View {
    /// Sets the style of every cluster in this view — for a ``FigureView``,
    /// every cluster in the figure that does not have a style of its own.
    func clusterStyle(_ style: ClusterStyle) -> some View {
        environment(\.clusterStyle, style)
    }
}

public extension FigureElement {
    /// Sets the style of every cluster in this element that does not have a
    /// style of its own — this one, if it is a cluster.
    func clusterStyle(_ style: ClusterStyle) -> ClusterStyled<Self> {
        ClusterStyled(self, style: style)
    }
}

/// An element whose clusters have been given a style.
///
/// It adds nothing to the arrangement's shape, as ``NodeStyled`` adds nothing.
public struct ClusterStyled<Wrapped: FigureElement>: FigureElement {
    private let wrapped: Wrapped
    private let style: ClusterStyle

    init(_ wrapped: Wrapped, style: ClusterStyle) {
        self.wrapped = wrapped
        self.style = style
    }

    /// The element, with the style in its environment.
    public var elementBody: some View {
        wrapped.elementBody
            .environment(\.clusterStyle, style)
    }

    /// The element's placements, unchanged.
    public var placements: [Placement] {
        wrapped.placements
    }
}
