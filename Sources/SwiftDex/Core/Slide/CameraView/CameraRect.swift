import Foundation

/// Resolves the rectangle the camera has arrived at on a slide's timeline.
///
/// The camera is the fold of every `Camera` operation that has started, over the
/// slide's home rectangle. Folding — rather than reading the latest operation —
/// is what lets `pan` be relative: it carries the size the rectangle already
/// had, so panning after a zoom stays at that zoom level.
///
/// The result is a pure function of the timeline, so it is identical on every
/// surface showing the same presentation and in static rendering.
enum CameraRect {

    /// - Parameters:
    ///   - history: The operations that have started, in timeline order.
    ///   - home: The rectangle the camera starts from and `reset` returns to.
    ///   - elementRect: The bounds of an element, or `nil` when it has no
    ///     published anchor. An operation with an unresolvable target leaves the
    ///     camera where it is, which also covers the render before anchors arrive.
    /// - Returns: The rectangle of the slide the viewport shows.
    static func resolve(
        history: [Camera],
        home: CGRect,
        elementRect: (ElementID) -> CGRect?
    ) -> CGRect {
        history.reduce(home) { rect, camera in
            switch camera.operation {
            case .reset:
                return home

            case .zoom(let elementID, let ratio):
                guard let target = elementRect(elementID), ratio > 0 else {
                    return rect
                }
                // The target keeps its centre and grows to `1 / ratio` of its
                // size, so `CameraEffect` fits it to that proportion of the
                // viewport.
                return target.insetBy(
                    dx: -(target.width / ratio - target.width) / 2,
                    dy: -(target.height / ratio - target.height) / 2
                )

            case .pan(let elementID):
                guard let target = elementRect(elementID) else {
                    return rect
                }
                return CGRect(
                    x: target.midX - rect.width / 2,
                    y: target.midY - rect.height / 2,
                    width: rect.width,
                    height: rect.height
                )
            }
        }
    }
}
