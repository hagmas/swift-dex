import AppKit
import SwiftUI

/// Lets the presenter move the camera with the trackpad.
///
/// The events are taken with a local event monitor rather than SwiftUI
/// gestures, so that moving the camera never enters gesture arbitration with
/// the tap that advances the slide. It also means momentum arrives for free:
/// AppKit keeps delivering scroll events after the fingers lift.
///
/// The monitor is installed only while an interactive slide is on screen, so a
/// deck of ordinary slides never intercepts anything.
struct TrackpadCameraInput: ViewModifier {
    let isEnabled: Bool
    let live: LiveCameraFrame

    /// A travel, in canvas units.
    let onPan: (CGSize) -> Void

    /// A magnification, and the canvas point to keep still while it happens.
    let onMagnify: (CGFloat, CGPoint) -> Void

    /// A request to give the camera back to the actions.
    let onReturn: () -> Void

    @State private var monitor: Any?

    func body(content: Content) -> some View {
        content
            .onAppear { install() }
            .onDisappear { remove() }
            .onChange(of: isEnabled) { _, enabled in
                enabled ? install() : remove()
            }
    }
}

private extension TrackpadCameraInput {
    func install() {
        guard isEnabled, monitor == nil else {
            return
        }
        monitor = NSEvent.addLocalMonitorForEvents(
            matching: [.scrollWheel, .magnify, .smartMagnify]
        ) { event in
            handle(event) ? nil : event
        }
    }

    func remove() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    /// Returns whether the event was consumed.
    func handle(_ event: NSEvent) -> Bool {
        let frame = live.value

        // The monitor sees the whole application's events. Resolving the
        // location against this surface is both the conversion and the test for
        // whether the event was meant for it.
        guard let window = event.window,
            let pivot = frame.canvasPoint(atWindowLocation: flipped(event.locationInWindow, in: window))
        else {
            return false
        }

        switch event.type {
        case .scrollWheel:
            let scale = frame.canvasPerPoint
            // A scroll asks for the content to move; the camera moves the other
            // way, by the distance in canvas units that covers on screen.
            onPan(
                CGSize(
                    width: -event.scrollingDeltaX * scale,
                    height: -event.scrollingDeltaY * scale
                )
            )

        case .magnify:
            onMagnify(1 + event.magnification, pivot)

        case .smartMagnify:
            onReturn()

        default:
            return false
        }
        return true
    }

    /// AppKit reports a location from the window's bottom-left corner; the
    /// surface is measured from its top-left one.
    func flipped(_ location: CGPoint, in window: NSWindow) -> CGPoint {
        let height = window.contentView?.bounds.height ?? window.frame.height
        return CGPoint(x: location.x, y: height - location.y)
    }
}
