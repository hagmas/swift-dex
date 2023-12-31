import SwiftUI

struct ZoomEffect: GeometryEffect {
    private let depth: CGFloat = 500

    var baseRect: CGRect
    var targetRect: CGRect?

    var animatableData: CGRect.AnimatableData {
        get {
            let rect = targetRect ?? baseRect
            let origin = rect.origin
            let size = rect.size
            return CGRect.AnimatableData(
                CGPoint.AnimatableData(origin.x, origin.y),
                CGSize.AnimatableData(size.width, size.height)
            )
        }
        set {
            let (first, second) = (newValue.first, newValue.second)
            targetRect = CGRect(
                x: first.first,
                y: first.second,
                width: second.first,
                height: second.second
            )
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let rect = targetRect ?? baseRect
        var z: CGFloat = 0
        var ratio: CGFloat = 1.0
        if size.width * rect.height / rect.width < size.height {
            // width fit
            ratio = rect.width / size.width
            z = depth - depth * ratio
        }
        else {
            // height fit
            ratio = rect.height / size.height
            z = depth - depth * ratio
        }

        var transform = CATransform3DIdentity
        transform.m34 = -1 / depth
        transform = CATransform3DTranslate(transform, -size.width / 2.0, -size.height / 2.0, z)
        let affineTransform = ProjectionTransform(
            CGAffineTransform(
                translationX: size.width / 2.0 - (rect.midX - size.width / 2.0) / ratio,
                y: size.height / 2.0 - (rect.midY - size.height / 2.0) / ratio
            )
        )
        return ProjectionTransform(transform).concatenating(affineTransform)
    }
}
