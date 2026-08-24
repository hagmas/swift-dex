import Foundation

/// An `Action` that starts playback of a `VideoView`.
///
/// The video waits on its first frame until this action fires, then plays on.
/// Later clicks on the same slide do not interrupt it: playback is driven by
/// the clock, not by the timeline. Leaving the slide or rewinding past this
/// action discards the player, so the video starts over on re-entry.
///
/// Only the click that fires the action starts playback. Entering the slide
/// backward leaves the video at rest on its first frame, since its elapsed
/// time cannot be reconstructed from a click position.
///
/// ```swift
/// VideoView(name: "demo", elementID: .video)
/// ```
/// ```swift
/// @ActionContainerBuilder
/// var actionContainer: ActionContainer {
///     Apply(.fade, to: .video)
///     PlayVideo(.video)
/// }
/// ```
public struct PlayVideo: Action {
    /// The `ElementID` of the `VideoView`.
    public let elementID: ElementID

    /// Create a new instance.
    public init(_ elementID: ElementID) {
        self.elementID = elementID
    }
}
