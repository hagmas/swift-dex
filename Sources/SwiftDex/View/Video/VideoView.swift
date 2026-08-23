import AVKit
import SwiftUI

/// A view that plays a video.
///
/// Playback uses SwiftUI's native `VideoPlayer`, with hover-revealed controls.
/// Pass an `elementID` and the underlying `AVPlayer` is shared through
/// `@SlideValue`: every window presenting the same deck drives one player, so
/// there is a single audio stream and scrubbing on any surface moves all of
/// them. Without an `elementID` the player is local to the view.
///
/// The player follows the slide-value lifecycle: leaving the slide or rewinding
/// discards it, so re-entry starts from the beginning.
///
/// ```swift
/// VideoView(name: "demo", elementID: .video)
///     .frame(width: 800, height: 450)
/// ```
///
/// > Note: Do not wrap a `VideoView` in an ``Element``. The animation and
/// > visual-effect modifiers it applies force SwiftUI to flatten the video
/// > layer, which fails.
public struct VideoView: View {
    private let url: URL?
    private let elementID: ElementID

    /// Creates a video view for the given file URL.
    ///
    /// - Parameters:
    ///   - url: The video file to play.
    ///   - elementID: The identity under which the shared `AVPlayer` is stored.
    ///     Omit it to keep the player local to this view.
    public init(url: URL?, elementID: ElementID = .none) {
        self.url = url
        self.elementID = elementID
    }

    /// Creates a video view from a bundle resource.
    ///
    /// - Parameters:
    ///   - name: The name of the video file without its extension.
    ///   - fileExtension: The file extension. Defaults to `mp4`.
    ///   - bundle: The bundle containing the resource.
    ///   - elementID: The identity under which the shared `AVPlayer` is stored.
    ///     Omit it to keep the player local to this view.
    public init(
        name: String,
        fileExtension: String = "mp4",
        bundle: Bundle = .main,
        elementID: ElementID = .none
    ) {
        self.url = bundle.url(forResource: name, withExtension: fileExtension)
        self.elementID = elementID
    }

    /// The content and behavior of the view.
    public var body: some View {
        if let url {
            // `@SlideValue` reads its identity from the environment, which a view
            // cannot write for its own stored properties — hence the private child.
            VideoPlayerView(url: url)
                .environment(\.elementID, elementID)
        }
    }
}

private struct VideoPlayerView: View {
    @Environment(\.isStaticRendering) private var isStaticRendering
    @SlideValue private var player: AVPlayer? = nil

    let url: URL

    var body: some View {
        if isStaticRendering {
            placeholder
        }
        else {
            VideoPlayer(player: resolvedPlayer())
        }
    }
}

private extension VideoPlayerView {
    func resolvedPlayer() -> AVPlayer {
        if let player {
            return player
        }
        let created = AVPlayer(url: url)
        player = created
        return created
    }

    /// Stands in for the player where an `NSView` cannot be captured —
    /// `ImageRenderer` thumbnails and overview transitions.
    var placeholder: some View {
        Rectangle()
            .fill(.black)
            .overlay {
                Image(systemName: "play.circle")
                    .font(.system(size: 96))
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
}
