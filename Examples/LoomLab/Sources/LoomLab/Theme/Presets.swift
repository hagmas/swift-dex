import Loom
import SwiftUI

/// Ways to draw a figure's parts in a flavour: frosty, a pale tint with the
/// flavour at its edge and in its words, or juicy, the flavour poured solid.
///
/// The lab's own, and nothing Loom knows about: a scenario picks a preset and
/// a flavour for each kind of thing it shows.
extension NodeStyle {
    /// A pale tint of `flavor`, edged and lettered in it.
    static func frosty(_ flavor: IceCandy.Flavor) -> NodeStyle {
        NodeStyle(
            shape: .capsule,
            fill: flavor.lightened(by: 0.86),
            // A light flavour's own colour is faint against a pale ground, so
            // its edge takes some of its depth.
            stroke: flavor.isLight ? flavor.color.mix(with: flavor.deep, by: 0.4) : flavor.color,
            strokeWidth: 1.5,
            textColor: flavor.deep,
            fontWeight: .medium
        )
    }

    /// `flavor` poured solid, lettered white — or dark, on a light flavour.
    static func juicy(_ flavor: IceCandy.Flavor) -> NodeStyle {
        NodeStyle(
            shape: .capsule,
            fill: flavor.color,
            stroke: .clear,
            strokeWidth: 0,
            textColor: flavor.isLight ? flavor.deep : .white,
            fontWeight: .semibold
        )
    }
}

extension ClusterStyle {
    /// A faint wash of `flavor`, with no edge, titled in it.
    static func frosty(_ flavor: IceCandy.Flavor) -> ClusterStyle {
        ClusterStyle(
            fill: flavor.lightened(by: 0.88),
            stroke: .clear,
            strokeWidth: 0,
            cornerRadius: 22,
            titleColor: flavor.deep
        )
    }
}

extension LineStyle {
    /// Lines in slate with round ends, their words on a capsule of frost,
    /// the ground the figures are drawn on.
    static let iceCandy = iceCandy(cornerRadius: 0)

    /// The same, with corners rounded.
    static func iceCandy(cornerRadius: CGFloat) -> LineStyle {
        LineStyle(
            color: IceCandy.slate,
            cornerRadius: cornerRadius,
            lineCap: .round,
            labelColor: IceCandy.slate,
            labelBackground: IceCandy.frost,
            labelCornerRadius: .greatestFiniteMagnitude
        )
    }
}

extension LineStyle {
    /// This style, changed by `change`.
    func with(_ change: (inout LineStyle) -> Void) -> LineStyle {
        var style = self
        change(&style)
        return style
    }
}
