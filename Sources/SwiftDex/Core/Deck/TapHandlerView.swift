import SwiftUI

struct TapHandlerView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let onLeftTap: () -> Void
    let onRightTap: () -> Void

    var body: some View {
        GeometryReader { proxy in
            content()
                .onTapGesture { location in
                    if location.x > proxy.size.width / 2 {
                        onRightTap()
                    }
                    else {
                        onLeftTap()
                    }
                }
                .background {
                    Button("") {
                        onLeftTap()
                    }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    Button("") {
                        onRightTap()
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
        }
    }
}
