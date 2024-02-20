import Foundation
import SwiftUI
import SwiftDex

struct AboutCode: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Code"
    }

    var body: some View {
        Code(
            theme: DefaultDarkTheme(),
            isScrollViewEnabled: true,
            code:
"""
struct MyView: View {
    var body: some View {
        Text("Hello, Woooooooooooooooooooooooooooooooooooooooooooooooooooooooorld!")
    }
}

struct MyView: View {
    var body: some View {
        Text("Hello, Woooooooooooooooooooooooooooooooooooooooooooooooooooooooorld!")
    }
}

struct MyView: View {
    var body: some View {
        Text("Hello, Woooooooooooooooooooooooooooooooooooooooooooooooooooooooorld!")
    }
}

struct MyView: View {
    var body: some View {
        Text("Hello, Woooooooooooooooooooooooooooooooooooooooooooooooooooooooorld!")
    }
}

struct MyView: View {
    var body: some View {
        Text("Hello, Woooooooooooooooooooooooooooooooooooooooooooooooooooooooorld!")
    }
}
"""
        )
    }
}

#Preview {
    SlidePreview(slide: AboutCode())
}

