import Foundation
import SwiftDex
import SwiftUI

struct AboutCode: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Code"
    }

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "Code".bold() + " displays code with syntax highlighting. It supports multiple Xcode Themes."
            HStack(spacing: 40) {
                code(name: "Default Dark", theme: DefaultDarkTheme())
                code(name: "Sunset", theme: SunsetTheme())
            }
            .frame(maxHeight: .infinity)
        }
    }

    func code(name: String, theme: XcodeTheme) -> some View {
        VStack(alignment: .center, spacing: 24) {
            Code(
                theme: theme,
                code:
                    """
                    struct MyView: View {
                        var body: some View {
                            Text("Hello, World!")
                        }
                    }
                    """
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.background)
            .cornerRadius(16)
            name
        }

    }
}

#Preview{
    SlidePreview(slide: AboutCode())
}
