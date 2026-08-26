import SwiftUI

/// Maps the camera's rectangle onto the viewport.
///
/// The transform is the affine map that puts `rect`'s centre at the centre of
/// the viewport and scales it to fit, so the whole of `rect` is visible on its
/// tighter axis. Interpolating `rect` is what animates the camera: a move and a
/// zoom are the same value changing, which is why they never fight.
struct CameraEffect: GeometryEffect {
    var rect: CGRect

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

        let scale = min(size.width / rect.width, size.height / rect.height)
        return ProjectionTransform(
            CGAffineTransform.identity
                .translatedBy(x: size.width / 2, y: size.height / 2)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -rect.midX, y: -rect.midY)
        )
    }
}
