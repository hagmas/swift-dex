import SwiftUI

/// The way back to where the actions put the camera.
///
/// Shown only while the presenter has moved the camera, which makes its
/// presence the signal that the slide is off script and its disappearance the
/// signal that it is back on. That is why it is not hidden from the audience:
/// it is part of the performance, like the grid overview, rather than chrome.
///
/// It belongs outside the camera transform. Inside it, the control would travel
/// with the canvas and leave the screen exactly when it is needed.
struct CameraReturnControl: View {
    @Environment(AnySlideViewModel.self) private var slideViewModel
    @Environment(\.colorStyle) private var colorStyle

    var body: some View {
        let isPresented = slideViewModel.cameraOverride != nil

        return ZStack {
            Button(action: returnToScript) {
                Image(systemName: "scope")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(colorStyle.backgroundColor)
                    .frame(width: 72, height: 72)
                    .background(
                        Circle().fill(colorStyle.textColor(textStyle: .body).opacity(0.55))
                    )
            }
            .buttonStyle(.plain)
            .padding(40)
            // Present the shortcut only alongside the control, so it is not
            // competing for Escape with anything else on the surface.
            .background {
                Button("", action: returnToScript)
                    .keyboardShortcut(.cancelAction)
                    .opacity(0)
            }
        }
        .opacity(isPresented ? 1 : 0)
        .allowsHitTesting(isPresented)
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

private extension CameraReturnControl {
    func returnToScript() {
        // Animated here rather than by the camera itself: dropping the override
        // does not move the slide's click, which is what the camera's own
        // animation is keyed on.
        withAnimation(.spring()) {
            slideViewModel.clearCameraOverride()
        }
    }
}
