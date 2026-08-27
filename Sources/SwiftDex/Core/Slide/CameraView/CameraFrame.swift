import SwiftUI

/// Everything needed to turn a trackpad event into a camera movement.
///
/// Trackpad events arrive in the window's coordinates, while the camera is
/// addressed in the canvas's. The conversion needs the surface's on-screen
/// scale and where the camera is pointing, both of which change as the
/// presentation runs, so the current values are handed to the event handler
/// through `LiveCameraFrame` rather than captured when the monitor is
/// installed.
struct CameraFrame: Equatable {
    /// The size of the surface the camera maps onto, in slide units.
    var viewport: CGSize = .zero

    /// Where the actions alone put the camera.
    ///
    /// The presenter's movement is layered onto this, so it is the base every
    /// override is relative to.
    var actionRect: CGRect = .zero

    /// The camera rectangle actually on screen, including any movement.
    var currentRect: CGRect = .zero

    /// Window points per slide unit.
    var onScreenScale: CGFloat = 1

    /// The surface's top-left corner in the window's coordinates.
    var origin: CGPoint = .zero
}

extension CameraFrame {
    /// Slide units per canvas unit at the current camera rectangle.
    var magnification: CGFloat {
        guard currentRect.width > 0, currentRect.height > 0 else {
            return 1
        }
        return min(viewport.width / currentRect.width, viewport.height / currentRect.height)
    }

    /// Canvas units per window point.
    var canvasPerPoint: CGFloat {
        let scale = onScreenScale * magnification
        return scale > 0 ? 1 / scale : 0
    }

    /// The canvas point under a location in the window's coordinates, or `nil`
    /// when that location is not over this surface.
    ///
    /// A monitor sees every event the window gets, so this doubles as the test
    /// for whether an event was meant for the slide at all.
    func canvasPoint(atWindowLocation location: CGPoint) -> CGPoint? {
        guard onScreenScale > 0 else {
            return nil
        }
        let local = CGPoint(
            x: (location.x - origin.x) / onScreenScale,
            y: (location.y - origin.y) / onScreenScale
        )
        guard local.x >= 0, local.x <= viewport.width,
            local.y >= 0, local.y <= viewport.height
        else {
            return nil
        }
        let magnification = magnification
        return CGPoint(
            x: currentRect.midX + (local.x - viewport.width / 2) / magnification,
            y: currentRect.midY + (local.y - viewport.height / 2) / magnification
        )
    }
}

/// A reference to the latest `CameraFrame`.
///
/// The event monitor is installed once, so its handler cannot close over a
/// value that changes every click. It closes over this instead.
final class LiveCameraFrame {
    var value = CameraFrame()
}
