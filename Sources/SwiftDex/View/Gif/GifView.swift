import AppKit
import SwiftUI

/// A view that plays an animated GIF.
///
/// Live playback is driven by an `NSImageView` at the AppKit layer for
/// performance; static contexts (thumbnails) fall back to a SwiftUI `Image`
/// so that `ImageRenderer` can capture the first frame.
///
/// ```swift
/// GifView(name: "demo", bundle: .main)
///     .frame(width: 400, height: 300)
/// ```
public struct GifView: View {
    @Environment(\.isStaticRendering) private var isStaticRendering

    private let image: NSImage?

    /// Creates a GIF view from raw data.
    public init(data: Data) {
        self.image = NSImage(data: data)
    }

    /// Creates a GIF view from a bundle resource.
    ///
    /// - Parameters:
    ///   - name: The name of the GIF file without the `.gif` extension.
    ///   - bundle: The bundle containing the resource.
    public init(name: String, bundle: Bundle = .main) {
        if let url = bundle.url(forResource: name, withExtension: "gif"),
            let data = try? Data(contentsOf: url)
        {
            self.image = NSImage(data: data)
        }
        else {
            self.image = nil
        }
    }

    /// The content and behavior of the view.
    public var body: some View {
        if let image {
            if isStaticRendering {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            }
            else {
                AnimatedNSImageView(image: image)
            }
        }
    }
}

private struct AnimatedNSImageView: NSViewRepresentable {
    let image: NSImage

    func makeNSView(context: Context) -> NSImageView {
        let view = NSImageView()
        view.imageScaling = .scaleProportionallyUpOrDown
        view.animates = true
        view.image = image
        return view
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        nsView.image = image
    }
}
