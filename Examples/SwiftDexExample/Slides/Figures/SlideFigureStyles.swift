import Loom
import SwiftDex
import SwiftUI

/// How much larger than Loom's own numbers a figure on a slide is drawn.
///
/// Loom's numbers are picked to look right with 18pt words, and a slide sets
/// its words in points against a 1920×1080 canvas. A figure on a slide is
/// drawn at the size of the slide's body text.
///
/// A stand-in until a figure's styles are made from the deck's own style.
let slideFigureRatio = TextStyle.body.size / NodeStyle.standard.fontSize

extension NodeStyle {
    /// This style, with every number made large enough for a slide.
    func onSlide() -> NodeStyle {
        with { style in
            if case .roundedRectangle(let cornerRadius) = style.shape {
                style.shape = .roundedRectangle(cornerRadius: cornerRadius * slideFigureRatio)
            }
            style.strokeWidth *= slideFigureRatio
            style.fontSize *= slideFigureRatio
            style.padding = EdgeInsets(
                top: style.padding.top * slideFigureRatio,
                leading: style.padding.leading * slideFigureRatio,
                bottom: style.padding.bottom * slideFigureRatio,
                trailing: style.padding.trailing * slideFigureRatio
            )
            style.minWidth *= slideFigureRatio
            style.maxWidth = style.maxWidth.map { $0 * slideFigureRatio }
        }
    }
}

extension LineStyle {
    /// This style, with every number made large enough for a slide.
    func onSlide() -> LineStyle {
        var style = self
        style.width *= slideFigureRatio
        style.cornerRadius *= slideFigureRatio
        style.dash = style.dash.map { $0 * slideFigureRatio }
        style.arrowHead.size = style.arrowHead.size.map { $0 * slideFigureRatio }
        style.labelFontSize *= slideFigureRatio
        style.labelPadding *= slideFigureRatio
        return style
    }
}
