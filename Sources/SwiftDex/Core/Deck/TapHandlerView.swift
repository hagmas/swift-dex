import SwiftUI

struct TapHandlerView<Content: View>: View {
    /// Whether this surface currently owns navigation.
    ///
    /// The live presentation stays mounted underneath the grid overview, so its
    /// arrow keys have to be switched off rather than shadowed — otherwise
    /// browsing the grid would quietly advance the talk.
    let isEnabled: Bool
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
                    // Only the shortcuts are disabled: `.disabled` inherits, and
                    // the slide itself must keep rendering as it always does.
                    Group {
                        Button("") {
                            onLeftTap()
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        Button("") {
                            onRightTap()
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    }
                    .disabled(!isEnabled)
                }
        }
    }
}
