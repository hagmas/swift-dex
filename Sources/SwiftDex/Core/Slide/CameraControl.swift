import Foundation

/// Who is allowed to move a slide's camera.
///
/// A slide that declares a `canvas` is interactive by default, because a slide
/// with somewhere to go that cannot be moved is a surprise. Write the value
/// explicitly to take that back: a canvas whose tour is scripted, and must stay
/// on script, is `.scripted`.
public enum CameraControl: Equatable {
    /// The camera goes only where the slide's `Camera` actions put it.
    case scripted

    /// The presenter can also move the camera, with the trackpad.
    ///
    /// Manual movement is a temporary layer over the actions: the next `Camera`
    /// action discards it, as does the control that appears while it is in
    /// effect.
    case interactive
}
