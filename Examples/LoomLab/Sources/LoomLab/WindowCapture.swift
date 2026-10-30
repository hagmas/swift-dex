import AppKit

/// Images of the lab's own window, as it is on screen this instant —
/// animation and all.
///
/// SwiftUI draws through Metal, past where AppKit's `cacheDisplay` or a
/// layer's `render(in:)` can see, and an `ImageRenderer` draws a view afresh
/// at rest. Only the window server holds the frame actually shown, and asking
/// it for the image of one of the app's own windows needs no permission to
/// record the screen.
///
/// The call that does it, `CGWindowListCreateImage`, is deprecated in favour
/// of ScreenCaptureKit — which does want that permission — and Swift no longer
/// offers it, so it is looked up by name. A later macOS may take it away; the
/// lab then says so rather than crashing.
@MainActor
enum WindowCapture {
    private typealias CreateImage = @convention(c) (CGRect, UInt32, UInt32, UInt32) -> Unmanaged<CGImage>?

    private static let createImage: CreateImage? = {
        guard let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "CGWindowListCreateImage") else {
            return nil
        }
        return unsafeBitCast(symbol, to: CreateImage.self)
    }()

    /// The part of `window` in `rect`, in the window's own points measured
    /// from its top-left corner, as a PNG.
    static func png(of window: NSWindow, in rect: CGRect) -> Data? {
        // Just this window, without its shadow.
        let includingWindow: UInt32 = 1 << 3
        let boundsIgnoreFraming: UInt32 = 1 << 0
        guard
            let createImage,
            let image = createImage(.null, includingWindow, UInt32(window.windowNumber), boundsIgnoreFraming)?
                .takeRetainedValue()
        else {
            return nil
        }

        let scale = CGFloat(image.width) / window.frame.width
        let pixels = CGRect(
            x: rect.minX * scale,
            y: rect.minY * scale,
            width: rect.width * scale,
            height: rect.height * scale
        ).integral
        guard let cropped = image.cropping(to: pixels) else {
            return nil
        }
        return NSBitmapImageRep(cgImage: cropped).representation(using: .png, properties: [:])
    }
}
