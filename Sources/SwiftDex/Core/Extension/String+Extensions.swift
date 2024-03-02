import SwiftUI

public extension String {
    func elementID(_ elemenetID: ElementID) -> some View {
        Text(self)
            .elementID(elemenetID)
    }

    func foregroundStyle<S>(_ style: S) -> some View where S: ShapeStyle {
        Text(self)
            .foregroundStyle(style)
    }

    func foregroundStyle<S1, S2>(_ primary: S1, _ secondary: S2) -> some View where S1: ShapeStyle, S2: ShapeStyle {
        Text(self)
            .foregroundStyle(primary, secondary)
    }

    func foregroundStyle<S1, S2, S3>(_ primary: S1, _ secondary: S2, _ tertiary: S3) -> some View
    where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle {
        Text(self)
            .foregroundStyle(primary, secondary, tertiary)
    }

    func font(_ font: Font?) -> Text {
        Text(self)
            .font(font)
    }

    func fontWeight(_ weight: Font.Weight?) -> Text {
        Text(self)
            .fontWeight(weight)
    }

    func fontWidth(_ width: Font.Width?) -> Text {
        Text(self)
            .fontWidth(width)
    }

    func bold(_ isActive: Bool = true) -> Text {
        Text(self)
            .bold(isActive)
    }

    func italic(_ isActive: Bool = true) -> Text {
        Text(self)
            .italic(isActive)
    }

    func monospaced(_ isActive: Bool = true) -> Text {
        Text(self)
            .monospaced(isActive)
    }

    func fontDesign(_ design: Font.Design?) -> Text {
        Text(self)
            .fontDesign(design)
    }

    func monospacedDigit() -> Text {
        Text(self)
            .monospacedDigit()
    }

    func strikethrough(_ isActive: Bool = true, pattern: Text.LineStyle.Pattern, color: Color? = nil) -> Text {
        Text(self)
            .strikethrough(isActive, pattern: pattern, color: color)
    }

    func underline(_ isActive: Bool = true, pattern: Text.LineStyle.Pattern, color: Color? = nil) -> Text {
        Text(self)
            .underline(isActive, pattern: pattern, color: color)
    }

    func kerning(_ kerning: CGFloat) -> Text {
        Text(self)
            .kerning(kerning)
    }

    func tracking(_ tracking: CGFloat) -> Text {
        Text(self)
            .tracking(tracking)
    }

    func baselineOffset(_ baselineOffset: CGFloat) -> Text {
        Text(self)
            .baselineOffset(baselineOffset)
    }

    func textScale(_ scale: Text.Scale, isEnabled: Bool = true) -> Text {
        Text(self)
            .textScale(scale, isEnabled: isEnabled)
    }

    func multilineTextAlignment(_ alignment: TextAlignment) -> some View {
        Text(self)
            .multilineTextAlignment(alignment)
    }

    func lineSpacing(_ lineSpacing: CGFloat) -> some View {
        Text(self)
            .lineSpacing(lineSpacing)
    }
}

public func + (lhs: String, rhs: Text) -> Text {
    Text(lhs) + rhs
}

public func + (lhs: Text, rhs: String) -> Text {
    lhs + Text(rhs)
}
