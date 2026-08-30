import Foundation

/// A presenter's movement of the camera, layered over where the actions put it.
///
/// The override is a delta rather than a position, so the thing it is layered
/// over stays a pure function of the timeline and never has to be saved. That
/// is also what makes returning free: dropping the override *is* the return,
/// with nothing to restore.
///
/// `anchorClick` is the click the movement was made on. Advancing past it is
/// the presenter resuming the script, which drops the movement — see
/// `SlideState.effectiveCameraOverride`.
struct CameraOverride: Equatable {
    /// How much the presenter has magnified the camera. `1` is the action's own
    /// zoom level.
    var scale: CGFloat = 1

    /// How far the presenter has moved the camera, in canvas units.
    var translation: CGSize = .zero

    /// The click the movement started on.
    let anchorClick: Int

    /// The range the presenter may magnify within.
    ///
    /// Unlike travel, which is deliberately unbounded, magnification is clamped:
    /// a camera rectangle that collapses or inverts has no sensible transform.
    static let scaleLimits: ClosedRange<CGFloat> = 0.25...8

    var isIdentity: Bool {
        scale == 1 && translation == .zero
    }

    /// The camera rectangle this override produces from the one the actions
    /// resolved to.
    func apply(to rect: CGRect) -> CGRect {
        let size = CGSize(width: rect.width / scale, height: rect.height / scale)
        return CGRect(
            x: rect.midX - size.width / 2 + translation.width,
            y: rect.midY - size.height / 2 + translation.height,
            width: size.width,
            height: size.height
        )
    }

    /// Magnifies by `factor`, keeping `pivot` where it is on screen.
    ///
    /// Scaling alone holds the camera's centre still, so the pivot is kept by
    /// moving the centre towards it by the share the magnification took away.
    mutating func magnify(by factor: CGFloat, about pivot: CGPoint, in rect: CGRect) {
        let clamped = min(max(scale * factor, Self.scaleLimits.lowerBound), Self.scaleLimits.upperBound)
        guard clamped != scale else {
            return
        }
        let applied = clamped / scale
        scale = clamped

        let centre = apply(to: rect)
        translation.width += (pivot.x - centre.midX) * (1 - 1 / applied)
        translation.height += (pivot.y - centre.midY) * (1 - 1 / applied)
    }
}
