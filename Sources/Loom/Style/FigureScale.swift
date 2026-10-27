import SwiftUI

extension EnvironmentValues {
    /// How many times larger than its own numbers a figure is drawn.
    @Entry var figureScale: CGFloat = 1
}

public extension View {
    /// Draws every figure in this view `scale` times larger than its own
    /// numbers say.
    ///
    /// A figure's numbers are its own: a box style's font size, a column's
    /// spacing, a line's width are all points in the figure's terms, picked to
    /// look right together. A host that shows figures at another size says so
    /// once, here, and every one of those numbers is multiplied before
    /// anything is laid out.
    ///
    /// ```swift
    /// FigureView(RefactorFigure())
    ///     .figureScale(44.0 / BoxStyle.standard.fontSize)
    /// ```
    ///
    /// Not `scaleEffect`: that enlarges what has already been drawn, so text
    /// blurs. This draws it at the larger size in the first place.
    func figureScale(_ scale: CGFloat) -> some View {
        environment(\.figureScale, scale)
    }
}
