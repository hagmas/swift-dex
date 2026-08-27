import Foundation

/// The extent of one axis of a slide's canvas.
public enum CanvasExtent: Equatable {
    /// The deck's slide size: the extent the viewport itself has.
    case slide

    /// A fixed number of points.
    case points(CGFloat)

    /// Whatever the content lays out to on this axis.
    ///
    /// The axis is left unconstrained, so the content takes its ideal size —
    /// which means content that stretches to `.infinity` on this axis has no
    /// defined extent and cannot use it.
    case content
}

/// The area a slide lays its content out in.
///
/// A canvas defaults to the viewport on both axes, which is what every slide
/// that has never heard of one gets. Declaring a larger canvas gives a slide
/// room the viewport cannot show at once; `Camera` is how the presentation
/// travels over it.
///
/// ```swift
/// struct SystemMap: Slide {
///     var canvas: SlideCanvas { .init(width: .points(5760)) }   // three screens wide
/// }
/// ```
///
/// The axes are independent: a slide can be three screens wide and exactly one
/// screen tall, or as tall as its content and no wider than the viewport.
public struct SlideCanvas: Equatable {

    /// The extent of the horizontal axis.
    public var width: CanvasExtent

    /// The extent of the vertical axis.
    public var height: CanvasExtent

    /// Create a new instance.
    ///
    /// - Parameters:
    ///   - width: The extent of the horizontal axis. Defaults to the viewport's.
    ///   - height: The extent of the vertical axis. Defaults to the viewport's.
    public init(width: CanvasExtent = .slide, height: CanvasExtent = .slide) {
        self.width = width
        self.height = height
    }

    /// The canvas that matches the viewport exactly, on both axes.
    public static let slide = SlideCanvas()
}

extension CanvasExtent {
    /// The length to impose on this axis, or `nil` when the content decides it.
    func length(slide: CGFloat) -> CGFloat? {
        switch self {
        case .slide:
            slide

        case .points(let points):
            points

        case .content:
            nil
        }
    }

    var isContent: Bool {
        self == .content
    }
}
