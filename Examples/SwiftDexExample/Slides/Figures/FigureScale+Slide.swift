import Loom
import SwiftDex
import SwiftUI

extension View {
    /// Draws a figure at the size of the slide's body text.
    ///
    /// A figure's numbers are its own, picked to look right with 13pt titles,
    /// and a slide sets its text in points against a 1920×1080 canvas.
    func figureAtBodyTextSize() -> some View {
        figureScale(TextStyle.body.size / BoxStyle.standard.fontSize)
    }
}
