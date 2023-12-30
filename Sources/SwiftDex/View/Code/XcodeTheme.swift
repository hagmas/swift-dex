import SwiftUI

/// A protocol defining the color scheme for syntax highlighting in an Xcode-like editor environment.
public protocol XcodeTheme {
    /// Color for plain text.
    var plainText: Color { get }

    /// Color for keywords.
    var keyword: Color { get }

    /// Color for strings.
    var string: Color { get }

    /// Color for types.
    var type: Color { get }

    /// Color for function or method calls.
    var call: Color { get }

    /// Color for numbers.
    var number: Color { get }

    /// Color for comments.
    var comment: Color { get }

    /// Color for properties.
    var property: Color { get }

    /// Color for dot accesses.
    var dotAccess: Color { get }

    /// Color for preprocessing instructions.
    var preprocessing: Color { get }

    /// Color for the background.
    var background: Color { get }

    /// Color for text selection.
    var selection: Color { get }
}

/// Basic Theme.
public struct BasicTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.0, green: 0.0, blue: 1.0)

    /// Color for strings.
    public let string = Color(red: 0.6392, green: 0.0823, blue: 0.0823)

    /// Color for types.
    public let type = Color(red: 0.0431, green: 0.3098, blue: 0.4745)

    /// Color for function or method calls.
    public let call = Color(red: 0.1686, green: 0.5137, blue: 0.6235)

    /// Color for numbers.
    public let number = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for comments.
    public let comment = Color(red: 0.0, green: 0.5019, blue: 0.0)

    /// Color for properties.
    public let property = Color(red: 0.1686, green: 0.5137, blue: 0.6235)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1686, green: 0.5137, blue: 0.6235)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.0, green: 0.0, blue: 1.0)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for text selection.
    public let selection = Color(red: 0.6431, green: 0.8039, blue: 1.0)

    /// Initialize a new instance.
    public init() {}
}

/// Civic Theme.
public struct CivicTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.8824, green: 0.8863, blue: 0.9059)

    /// Color for keywords.
    public let keyword = Color(red: 0.8431, green: 0.0, blue: 0.5608)

    /// Color for strings.
    public let string = Color(red: 0.8235, green: 0.1373, blue: 0.1804)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.1137, green: 0.6627, blue: 0.6353)

    /// Color for numbers.
    public let number = Color(red: 0.0824, green: 0.6118, blue: 0.5725)

    /// Color for comments.
    public let comment = Color(red: 0.2706, green: 0.7333, blue: 0.2431)

    /// Color for properties.
    public let property = Color(red: 0.1137, green: 0.6627, blue: 0.6353)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1137, green: 0.6627, blue: 0.6353)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.7804, green: 0.4784, blue: 0.2941)

    /// Color for the background.
    public let background = Color(red: 0.1216, green: 0.1255, blue: 0.1608)

    /// Color for text selection.
    public let selection = Color(red: 0.2078, green: 0.251, blue: 0.3059)

    /// Initialize a new instance.
    public init() {}
}

/// Classic Dark Theme.
public struct ClassicDarkTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.85)

    /// Color for keywords.
    public let keyword = Color(red: 0.9882, green: 0.3725, blue: 0.6392)

    /// Color for strings.
    public let string = Color(red: 0.9882, green: 0.4157, blue: 0.3647)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for numbers.
    public let number = Color(red: 0.8157, green: 0.749, blue: 0.4118)

    /// Color for comments.
    public let comment = Color(red: 0.451, green: 0.6549, blue: 0.3059)

    /// Color for properties.
    public let property = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.9922, green: 0.5608, blue: 0.2471)

    /// Color for the background.
    public let background = Color(red: 0.1216, green: 0.1216, blue: 0.1412)

    /// Color for text selection.
    public let selection = Color(red: 0.3176, green: 0.3569, blue: 0.4392)

    /// Initialize a new instance.
    public init() {}
}

/// Classic Light Theme.
public struct ClassicLightTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.85)

    /// Color for keywords.
    public let keyword = Color(red: 0.6078, green: 0.1373, blue: 0.5765)

    /// Color for strings.
    public let string = Color(red: 0.7686, green: 0.1019, blue: 0.0863)

    /// Color for types.
    public let type = Color(red: 0.0431, green: 0.3098, blue: 0.4745)

    /// Color for function or method calls.
    public let call = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for numbers.
    public let number = Color(red: 0.1098, green: 0.4275, blue: 1.0)

    /// Color for comments.
    public let comment = Color(red: 0.149, green: 0.4588, blue: 0.0275)

    /// Color for properties.
    public let property = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.3922, green: 0.2196, blue: 0.1255)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5216)

    /// Color for text selection.
    public let selection = Color(red: 0.6431, green: 0.8039, blue: 1.0)

    /// Initialize a new instance.
    public init() {}
}

/// Default Dark Theme.
public struct DefaultDarkTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.85)

    /// Color for keywords.
    public let keyword = Color(red: 0.9882, green: 0.3725, blue: 0.6392)

    /// Color for strings.
    public let string = Color(red: 0.9882, green: 0.4157, blue: 0.3647)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for numbers.
    public let number = Color(red: 0.8157, green: 0.749, blue: 0.4118)

    /// Color for comments.
    public let comment = Color(red: 0.4235, green: 0.4745, blue: 0.3373)

    /// Color for properties.
    public let property = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.4039, green: 0.7176, blue: 0.6431)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.9922, green: 0.5608, blue: 0.2471)

    /// Color for the background.
    public let background = Color(red: 0.1216, green: 0.1216, blue: 0.1412)

    /// Color for text selection.
    public let selection = Color(red: 0.3176, green: 0.3569, blue: 0.4392)

    /// Initialize a new instance.
    public init() {}
}

/// Default Light Theme.
public struct DefaultLightTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.85)

    /// Color for keywords.
    public let keyword = Color(red: 0.6078, green: 0.1373, blue: 0.5765)

    /// Color for strings.
    public let string = Color(red: 0.7686, green: 0.1019, blue: 0.0863)

    /// Color for types.
    public let type = Color(red: 0.0431, green: 0.3098, blue: 0.4745)

    /// Color for function or method calls.
    public let call = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for numbers.
    public let number = Color(red: 0.2353, green: 0.4275, blue: 0.4745)

    /// Color for comments.
    public let comment = Color(red: 0.3647, green: 0.4235, blue: 0.4745)

    /// Color for properties.
    public let property = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1961, green: 0.4275, blue: 0.4549)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.3922, green: 0.2196, blue: 0.1255)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5216)

    /// Color for text selection.
    public let selection = Color(red: 0.6431, green: 0.8039, blue: 1.0)

    /// Initialize a new instance.
    public init() {}
}

/// Dusk Theme.
public struct DuskTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.698, green: 0.0941, blue: 0.5373)

    /// Color for strings.
    public let string = Color(red: 0.8588, green: 0.1725, blue: 0.2196)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.5137, green: 0.7529, blue: 0.3412)

    /// Color for numbers.
    public let number = Color(red: 0.4667, green: 0.4275, blue: 0.7686)

    /// Color for comments.
    public let comment = Color(red: 0.2549, green: 0.7137, blue: 0.2706)

    /// Color for properties.
    public let property = Color(red: 0.5137, green: 0.7529, blue: 0.3412)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.5137, green: 0.7529, blue: 0.3412)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.7804, green: 0.4863, blue: 0.2824)

    /// Color for the background.
    public let background = Color(red: 0.1176, green: 0.1255, blue: 0.1569)

    /// Color for text selection.
    public let selection = Color(red: 0.3294, green: 0.3333, blue: 0.2902)

    /// Initialize a new instance.
    public init() {}
}

/// High Contrast Dark Theme.
public struct HighContrastDarkTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.9882, green: 0.4196, blue: 0.6667)

    /// Color for strings.
    public let string = Color(red: 0.9882, green: 0.4627, blue: 0.4039)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.4471, green: 0.749, blue: 0.6824)

    /// Color for numbers.
    public let number = Color(red: 0.8157, green: 0.7373, blue: 0.3373)

    /// Color for comments.
    public let comment = Color(red: 0.4863, green: 0.7098, blue: 0.3294)

    /// Color for properties.
    public let property = Color(red: 0.4471, green: 0.749, blue: 0.6824)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.4471, green: 0.749, blue: 0.6824)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.9922, green: 0.5608, blue: 0.2471)

    /// Color for the background.
    public let background = Color(red: 0.098, green: 0.0902, blue: 0.1059)

    /// Color for text selection.
    public let selection = Color(red: 0.2039, green: 0.2353, blue: 0.2941)

    /// Initialize a new instance.
    public init() {}
}

/// High Contrast Light Theme.
public struct HighContrastLightTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.5333, green: 0.0, blue: 0.4941)

    /// Color for strings.
    public let string = Color(red: 0.6078, green: 0.0235, blue: 0.0353)

    /// Color for types.
    public let type = Color(red: 0.0157, green: 0.1804, blue: 0.3765)

    /// Color for function or method calls.
    public let call = Color(red: 0.3608, green: 0.149, blue: 0.6)

    /// Color for numbers.
    public let number = Color(red: 0.1098, green: 0.0078, blue: 0.8118)

    /// Color for comments.
    public let comment = Color(red: 0.1019, green: 0.3255, blue: 0.0039)

    /// Color for properties.
    public let property = Color(red: 0.1608, green: 0.2941, blue: 0.3059)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1608, green: 0.2941, blue: 0.3059)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.3922, green: 0.2627, blue: 0.1255)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for text selection.
    public let selection = Color(red: 0.6431, green: 0.8039, blue: 1.0)

    /// Initialize a new instance.
    public init() {}
}

/// Low Key Theme.
public struct LowKeyTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.149, green: 0.1725, blue: 0.4157)

    /// Color for strings.
    public let string = Color(red: 0.4392, green: 0.1725, blue: 0.3176)

    /// Color for types.
    public let type = Color(red: 0.0431, green: 0.3098, blue: 0.4745)

    /// Color for function or method calls.
    public let call = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for numbers.
    public let number = Color(red: 0.149, green: 0.1725, blue: 0.4157)

    /// Color for comments.
    public let comment = Color(red: 0.2627, green: 0.3176, blue: 0.2196)

    /// Color for properties.
    public let property = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for text selection.
    public let selection = Color(red: 0.8118, green: 0.898, blue: 0.8196)

    /// Initialize a new instance.
    public init() {}
}

/// Midnight Theme.
public struct MidnightTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.8275, green: 0.0941, blue: 0.5843)

    /// Color for strings.
    public let string = Color(red: 1.0, green: 0.1725, blue: 0.2196)

    /// Color for types.
    public let type = Color(red: 0.3647, green: 0.8471, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.1373, green: 1.0, blue: 0.5137)

    /// Color for numbers.
    public let number = Color(red: 0.4667, green: 0.4275, blue: 1.0)

    /// Color for comments.
    public let comment = Color(red: 0.2549, green: 0.3647, blue: 1.0)

    /// Color for properties.
    public let property = Color(red: 0.1373, green: 1.0, blue: 0.5137)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.1373, green: 1.0, blue: 0.5137)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.8941, green: 0.4863, blue: 0.2824)

    /// Color for the background.
    public let background = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for text selection.
    public let selection = Color(red: 0.2941, green: 0.2784, blue: 0.2509)

    /// Initialize a new instance.
    public init() {}
}

/// Presentation Dark Theme.
public struct PresentationDarkTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.949, green: 0.1412, blue: 0.549)

    /// Color for strings.
    public let string = Color(red: 0.9882, green: 0.2745, blue: 0.3176)

    /// Color for types.
    public let type = Color(red: 0.4, green: 0.8549, blue: 1.0)

    /// Color for function or method calls.
    public let call = Color(red: 0.3373, green: 0.8157, blue: 0.702)

    /// Color for numbers.
    public let number = Color(red: 1.0, green: 0.9059, blue: 0.4275)

    /// Color for comments.
    public let comment = Color(red: 0.4235, green: 0.4745, blue: 0.5294)

    /// Color for properties.
    public let property = Color(red: 0.3373, green: 0.8157, blue: 0.702)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.3373, green: 0.8157, blue: 0.702)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.9922, green: 0.5608, blue: 0.2471)

    /// Color for the background.
    public let background = Color(red: 0.0941, green: 0.0941, blue: 0.1098)

    /// Color for text selection.
    public let selection = Color(red: 0.3176, green: 0.3569, blue: 0.4392)

    /// Initialize a new instance.
    public init() {}
}

/// Presentation Light Theme.
public struct PresentationLightTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.7059, green: 0.0, blue: 0.3765, opacity: 0.80)

    /// Color for strings.
    public let string = Color(red: 0.7294, green: 0.0, blue: 0.0667)

    /// Color for types.
    public let type = Color(red: 0.0, green: 0.2863, blue: 0.4588)

    /// Color for function or method calls.
    public let call = Color(red: 0.2314, green: 0.498, blue: 0.5373)

    /// Color for numbers.
    public let number = Color(red: 0.0, green: 0.0431, blue: 1.0)

    /// Color for comments.
    public let comment = Color(red: 0.3373, green: 0.3765, blue: 0.4196)

    /// Color for properties.
    public let property = Color(red: 0.2314, green: 0.498, blue: 0.5373)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.2314, green: 0.498, blue: 0.5373)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.3922, green: 0.3765, blue: 0.4392)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for text selection.
    public let selection = Color(red: 0.7804, green: 0.8588, blue: 1.0)

    /// Initialize a new instance.
    public init() {}
}

/// Printing Theme.
public struct PrintingTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.349, green: 0.349, blue: 0.349)

    /// Color for strings.
    public let string = Color(red: 0.3647, green: 0.3647, blue: 0.3647)

    /// Color for types.
    public let type = Color(red: 0.2275, green: 0.2275, blue: 0.2275)

    /// Color for function or method calls.
    public let call = Color(red: 0.2549, green: 0.2549, blue: 0.2549)

    /// Color for numbers.
    public let number = Color(red: 0.2157, green: 0.2157, blue: 0.2157)

    /// Color for comments.
    public let comment = Color(red: 0.3647, green: 0.3647, blue: 0.3647)

    /// Color for properties.
    public let property = Color(red: 0.3961, green: 0.3961, blue: 0.3961)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.3961, green: 0.3961, blue: 0.3961)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.2627, green: 0.2627, blue: 0.2627)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Color for text selection.
    public let selection = Color(red: 0.7686, green: 0.7686, blue: 0.7686)

    /// Initialize a new instance.
    public init() {}
}

/// Sunset Theme.
public struct SunsetTheme: XcodeTheme {
    /// Color for plain text.
    public let plainText = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Color for keywords.
    public let keyword = Color(red: 0.1608, green: 0.2588, blue: 0.4667)

    /// Color for strings.
    public let string = Color(red: 0.8745, green: 0.0275, blue: 0.0)

    /// Color for types.
    public let type = Color(red: 0.0431, green: 0.3098, blue: 0.4745)

    /// Color for function or method calls.
    public let call = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for numbers.
    public let number = Color(red: 0.1608, green: 0.2588, blue: 0.4667)

    /// Color for comments.
    public let comment = Color(red: 0.7647, green: 0.4549, blue: 0.1098)

    /// Color for properties.
    public let property = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for dot accesses.
    public let dotAccess = Color(red: 0.2784, green: 0.4157, blue: 0.5922)

    /// Color for preprocessing instructions.
    public let preprocessing = Color(red: 0.3922, green: 0.3922, blue: 0.5216)

    /// Color for the background.
    public let background = Color(red: 1.0, green: 1.0, blue: 0.898)

    /// Color for text selection.
    public let selection = Color(red: 0.9765, green: 0.8745, blue: 0.7373)

    /// Initialize a new instance.
    public init() {}
}
