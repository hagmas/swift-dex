import SwiftUI

/// The lab's colours: the flavours of an ice candy, clear and bright, with
/// nothing black mixed into them.
///
/// Only the colours themselves, and lighter or darker ones made from them.
/// What a colour means in a figure is the figure's to say.
enum IceCandy {
    /// A flavour's colour, and the colours made from it.
    ///
    /// In Display P3, which reaches brighter and clearer colours than sRGB on
    /// the screens the lab is shown on.
    struct Flavor: Sendable {
        /// The colour itself.
        let color: Color

        /// The flavour deepened, for words and edges: darker but just as
        /// clear, picked by eye rather than mixed with anything grey, which
        /// would muddy it.
        let deep: Color

        /// Whether words on the colour itself are better deep than white.
        let isLight: Bool

        init(_ color: (Double, Double, Double), deep: (Double, Double, Double), isLight: Bool = false) {
            self.color = Color(.displayP3, red: color.0, green: color.1, blue: color.2)
            self.deep = Color(.displayP3, red: deep.0, green: deep.1, blue: deep.2)
            self.isLight = isLight
        }

        /// The colour with `amount` of white mixed in, from `0` (the colour)
        /// to `1` (white).
        func lightened(by amount: Double) -> Color {
            color.mix(with: .white, by: amount)
        }
    }

    /// A white with a breath of soda in it, for the ground a figure is drawn
    /// on.
    static let frost = Flavor.soda.lightened(by: 0.95)

    /// The dark that words and lines are drawn in: a deep slate rather than
    /// black, so that it sits with the flavours rather than against them.
    static let ink = Color(red: 0.16, green: 0.2, blue: 0.29)

    /// A softer slate than ink, for lines and the words on them: drawn
    /// between the flavours, they keep back and let them lead.
    static let slate = Color(red: 91 / 255, green: 107 / 255, blue: 133 / 255)
}

extension IceCandy.Flavor {
    static let soda = Self((0.16, 0.56, 1.0), deep: (0.04, 0.3, 0.72))
    static let lemon = Self((1.0, 0.84, 0.1), deep: (0.6, 0.38, 0.0), isLight: true)
    static let orange = Self((1.0, 0.45, 0.1), deep: (0.7, 0.25, 0.02))
    static let cherry = Self((1.0, 0.25, 0.38), deep: (0.72, 0.07, 0.22))
    static let grape = Self((0.53, 0.3, 0.98), deep: (0.32, 0.13, 0.72))
    static let melon = Self((0.1, 0.72, 0.4), deep: (0.02, 0.42, 0.21))
    static let caramel = Self((0.86, 0.6, 0.2), deep: (0.52, 0.32, 0.04), isLight: true)
}
