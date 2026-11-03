import ImageIO
import SwiftUI
import UniformTypeIdentifiers

/// Draws a figure into an image just big enough to hold it.
///
/// ```swift
/// var renderer = FigureRenderer(
///     content: FigureView(Kettle(), routing: .curved)
///         .background(.white)
/// )
/// renderer.scale = 2
/// renderer.margin = 24
/// try renderer.pngData()?.write(to: url)
/// ```
///
/// The content is any view with a figure in it — a ``FigureView``, with
/// whatever styles and background it is drawn with. The image is cut to what
/// the figure draws: its nodes, its lines, including those that reach past
/// its nodes, and the words on them, with ``margin`` around them. A
/// background the content draws fills the image; without one, the image is
/// clear where the figure draws nothing.
///
/// The figure is drawn at rest, where any change it is in the middle of would
/// leave it.
@MainActor
public struct FigureRenderer<Content: View> {
    /// The view the figure is drawn by.
    public var content: Content

    /// How many pixels the image has to a point.
    public var scale: CGFloat = 1

    /// The space around what the figure draws, in points.
    public var margin: CGFloat = 0

    /// Creates a renderer for a view with a figure in it.
    public init(content: Content) {
        self.content = content
    }

    /// The figure, as an image — or `nil` if the content has no figure in it,
    /// or one that draws nothing.
    public var cgImage: CGImage? {
        guard let extent = extent(), !extent.isNull, !extent.isEmpty else {
            return nil
        }

        // The figure sits in the middle of the room it is given, so the room
        // has to reach as far either side of the middle as the figure does on
        // its further side; what is left over on the other is cut away.
        let reach = CGSize(
            width: Swift.max(-extent.minX, extent.maxX) + margin,
            height: Swift.max(-extent.minY, extent.maxY) + margin
        )
        let room = CGSize(width: reach.width * 2, height: reach.height * 2)

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(room)
        renderer.scale = scale
        guard let image = renderer.cgImage else {
            return nil
        }

        // From the middle of the image, which is the middle of the view: a
        // view given less room than its figure needs takes what it needs.
        let middle = CGPoint(x: CGFloat(image.width) / scale / 2, y: CGFloat(image.height) / scale / 2)
        let kept =
            extent
            .insetBy(dx: -margin, dy: -margin)
            .offsetBy(dx: middle.x, dy: middle.y)
        let pixels = CGRect(
            x: kept.minX * scale,
            y: kept.minY * scale,
            width: kept.width * scale,
            height: kept.height * scale
        )
        .integral
        return image.cropping(to: pixels)
    }

    /// The figure, as a PNG — or `nil` if there is no image of it to be had.
    public func pngData() -> Data? {
        guard let image = cgImage else {
            return nil
        }
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        else {
            return nil
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
    }

    /// Where everything the figure draws reaches, measured from the middle of
    /// the view it is drawn in.
    ///
    /// Measured by drawing the figure once and throwing the picture away. The
    /// figure looks the same in any room, so any room will do; a small one is
    /// drawn at little cost.
    private func extent() -> CGRect? {
        let measured = MeasuredExtent()
        let renderer = ImageRenderer(
            content: content.environment(
                \.figureExtentAction,
                FigureExtentAction { measured.extent = $0 }
            )
        )
        renderer.proposedSize = ProposedViewSize(width: 1, height: 1)
        renderer.scale = 1
        _ = renderer.cgImage
        return measured.extent
    }
}

/// Where a figure's extent is written, when it is measured.
@MainActor
private final class MeasuredExtent {
    var extent: CGRect?
}
