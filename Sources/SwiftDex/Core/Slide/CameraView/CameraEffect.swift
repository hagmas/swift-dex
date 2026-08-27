import SwiftUI

/// Maps the camera's rectangle onto the viewport.
///
/// The transform is the affine map that puts `rect`'s centre at the centre of
/// the viewport and scales it to fit, so the whole of `rect` is visible on its
/// tighter axis. Interpolating `rect` is what animates the camera: a move and a
/// zoom are the same value changing, which is why they never fight.
struct CameraEffect: GeometryEffect {
    var rect: CGRect

    /// The size of the surface the camera maps onto.
    ///
    /// Passed in rather than taken from `effectValue(size:)`, whose `size` is
    /// the size of the view being transformed — on a canvas slide that is the
    /// canvas, not the viewport. The two coincide only when a slide is exactly
    /// as large as the screen.
    let viewport: CGSize

    var animatableData: CGRect.AnimatableData {
        get {
            CGRect.AnimatableData(
                CGPoint.AnimatableData(rect.origin.x, rect.origin.y),
                CGSize.AnimatableData(rect.size.width, rect.size.height)
            )
        }
        set {
            rect = CGRect(
                x: newValue.first.first,
                y: newValue.first.second,
                width: newValue.second.first,
                height: newValue.second.second
            )
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard rect.width > 0, rect.height > 0 else {
            return ProjectionTransform()
        }

        let scale = min(viewport.width / rect.width, viewport.height / rect.height)
        return ProjectionTransform(
            CGAffineTransform.identity
                .translatedBy(x: viewport.width / 2, y: viewport.height / 2)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -rect.midX, y: -rect.midY)
        )
    }
}
