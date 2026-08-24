import AVKit
import SwiftUI

/// A view that plays a video.
///
/// Playback uses SwiftUI's native `VideoPlayer`, with hover-revealed controls.
/// The video rests on its first frame until a ``PlayVideo`` action fires; from
/// then on it plays on its own clock, undisturbed by later clicks.
///
/// Pass an `elementID` and the underlying `AVPlayer` is shared through
/// `@SlideValue`: every window presenting the same deck drives one player, so
/// there is a single audio stream and scrubbing on any surface moves all of
/// them. Without an `elementID` the player is local to the view — and no
/// action can reach it.
///
/// The player follows the slide-value lifecycle: leaving the slide or rewinding
/// past the `PlayVideo` action discards it, so the video starts over.
///
/// Playback begins on the click that fires the action and on nothing else.
/// Time cannot be rewound, so a slide entered backward shows the video at rest
/// on its first frame even though its timeline sits past the play beat.
///
/// ```swift
/// VideoView(name: "demo", elementID: .video)
///     .frame(width: 800, height: 450)
/// ```
public struct VideoView: View {
    private let url: URL?
    private let elementID: ElementID

    /// Creates a video view for the given file URL.
    ///
    /// - Parameters:
    ///   - url: The video file to play.
    ///   - elementID: The identity actions target, and under which the shared
    ///     `AVPlayer` is stored. Omit it to keep the player local to this view.
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
    ///   - elementID: The identity actions target, and under which the shared
    ///     `AVPlayer` is stored. Omit it to keep the player local to this view.
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
            ActionReader(PlayVideo.self, elementID: elementID, clicks: 1) { progress in
                // `@SlideValue` reads its identity from the environment, which a
                // view cannot write for its own stored properties — hence the
                // private child.
                VideoPlayerView(url: url, hasFired: progress.hasFired)
            }
            .environment(\.elementID, elementID)
        }
    }
}

private extension ActionProgress<PlayVideo> {
    /// Whether the timeline sits at or beyond the play beat.
    ///
    /// `nearestAction` is the action running, completed, or most recently
    /// passed. This is a level, not an event: it is equally true on the click
    /// that fires the action, on a slide entered backward, and while the slide
    /// transitions away. Only its rising edge means "start playing".
    var hasFired: Bool {
        nearestAction != nil
    }
}

private struct VideoPlayerView: View {
    @Environment(\.isStaticRendering) private var isStaticRendering
    @SlideValue private var player: AVPlayer? = nil

    let url: URL
    let hasFired: Bool

    var body: some View {
        if isStaticRendering {
            placeholder
        }
        else {
            VideoPlayer(player: player)
                // Creating the player is a store write, so it must not happen
                // during body evaluation. Keying on its absence also covers the
                // slide value being cleared out from under this view — by a
                // rewind, or by leaving the slide while it is still on screen
                // for the transition. A new player is never started here: that
                // would give the departing slide a second of audio, and would
                // start playback on a slide entered backward.
                .onChange(of: player == nil, initial: true) { _, isMissing in
                    if isMissing {
                        player = AVPlayer(url: url)
                    }
                }
                // Playback follows the rising edge of the action, not the
                // timeline's position relative to it. Time cannot be rewound,
                // so a video reached by any route other than clicking onto its
                // beat rests on its first frame.
                .onChange(of: hasFired) { _, hasFired in
                    hasFired ? player?.play() : player?.pause()
                }
        }
    }
}

private extension VideoPlayerView {
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
