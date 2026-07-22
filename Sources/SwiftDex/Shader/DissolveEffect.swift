import SwiftUI

/// Applies the dissolve shader to a view with an animatable progress.
///
/// `Shader` arguments are not animatable by themselves, so this modifier
/// conforms to `Animatable` and re-renders the shader for every interpolated
/// progress value.
struct DissolveEffect: ViewModifier, Animatable {
    var progress: Double
    var cellSize: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.layerEffect(
            ShaderLibrary.bundle(.module).dissolve(
                .float(progress),
                .float(cellSize)
            ),
            maxSampleOffset: .zero,
            isEnabled: progress < 1
        )
    }
}
