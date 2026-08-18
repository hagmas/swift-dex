import AVKit
import SwiftUI

/// A view that plays a video.
///
/// Playback uses SwiftUI's native `VideoPlayer`. The underlying `AVPlayer` is
/// held in a `@SlideValue`: give the view an `ElementID` via
/// ``SwiftUI/View/mediaElementID(_:)`` and every window presenting the same
/// deck shares one player. The player follows the slide-value lifecycle:
/// leaving the slide or rewinding discards it, so re-entry starts from the
/// beginning.
///
/// > Important: Use `.mediaElementID()`, **not** `.elementID()`.
/// > The animation modifier that `.elementID()` installs forces SwiftUI to
/// > flatten the video layer, which fails. `VideoView` detects this at
/// > runtime and shows a diagnostic placeholder.
///
/// ```swift
/// VideoView(name: "demo")
///     .mediaElementID(.video)
///     .frame(width: 800, height: 450)
/// ```
public struct VideoView: View {
    @Environment(\.isStaticRendering) private var isStaticRendering
    @Environment(\.hasElementAnimator) private var hasElementAnimator
    @SlideValue private var player: AVPlayer? = nil

    private let url: URL?

    /// Creates a video view for the given file URL.
    public init(url: URL?) {
        self.url = url
    }

    /// Creates a video view from a bundle resource.
    ///
    /// - Parameters:
    ///   - name: The name of the video file without its extension.
    ///   - fileExtension: The file extension. Defaults to `mp4`.
    ///   - bundle: The bundle containing the resource.
    public init(name: String, fileExtension: String = "mp4", bundle: Bundle = .main) {
        self.url = bundle.url(forResource: name, withExtension: fileExtension)
    }

    /// The content and behavior of the view.
    public var body: some View {
        if let url {
            if hasElementAnimator {
                elementAnimatorWarning
            }
            else if isStaticRendering {
                placeholder
            }
            else {
                VideoPlayer(player: resolvedPlayer(url: url))
            }
        }
    }
}

private extension VideoView {
    func resolvedPlayer(url: URL) -> AVPlayer {
        if let player {
            return player
        }
        let created = AVPlayer(url: url)
        player = created
        return created
    }

    var placeholder: some View {
        Rectangle()
            .fill(.black)
            .overlay {
                Image(systemName: "play.circle")
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.8))
            }
    }

    var elementAnimatorWarning: some View {
        Rectangle()
            .fill(Color.red.opacity(0.1))
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                    Text("Use .mediaElementID() instead of .elementID()")
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    Text(
                        ".elementID() applies animation modifiers that prevent video rendering."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                }
            }
    }
}
