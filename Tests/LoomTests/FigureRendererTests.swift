import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let one = NodeID("one")
    static let two = NodeID("two")
}

/// Two nodes side by side, with a loop off the second if asked for.
private struct Pair: Figure {
    var loop = false

    var arrangement: some FigureElement {
        Row {
            TextNode(.one, title: "One")
            TextNode(.two, title: "Two")
        }
    }

    var lines: [Line] {
        Line(from: .one, to: .two)
        if loop {
            Line(looping: .two.trailing, label: "again")
        }
    }
}

@MainActor
private func size(of figure: Pair, scale: CGFloat = 1, margin: CGFloat = 0) throws -> CGSize {
    var renderer = FigureRenderer(content: FigureView(figure))
    renderer.scale = scale
    renderer.margin = margin
    let image = try XCTUnwrap(renderer.cgImage)
    return CGSize(width: image.width, height: image.height)
}

/// The colours of the image of `content`, pixel by pixel.
@MainActor
private func pixels(of content: some View) throws -> Data {
    let image = try XCTUnwrap(FigureRenderer(content: content).cgImage)
    // Drawn again into rows of exactly the image's width: the image's own
    // rows may be padded with bytes that mean nothing.
    var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
    try bytes.withUnsafeMutableBytes { buffer in
        let context = try XCTUnwrap(
            CGContext(
                data: buffer.baseAddress,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        )
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    }
    return Data(bytes)
}

final class FigureRendererTests: XCTestCase {
    /// The margin goes all the way round.
    @MainActor
    func test_theMarginGoesRoundTheFigure() throws {
        let bare = try size(of: Pair())
        let framed = try size(of: Pair(), margin: 10)

        XCTAssertEqual(framed.width - bare.width, 20, accuracy: 1)
        XCTAssertEqual(framed.height - bare.height, 20, accuracy: 1)
    }

    @MainActor
    func test_theScaleIsPixelsToAPoint() throws {
        let points = try size(of: Pair())
        let pixels = try size(of: Pair(), scale: 2)

        XCTAssertEqual(pixels.width, points.width * 2, accuracy: 2)
        XCTAssertEqual(pixels.height, points.height * 2, accuracy: 2)
    }

    /// A line that reaches past the nodes — a loop off the side, with its
    /// words beyond it — is kept in the image rather than cut off.
    @MainActor
    func test_theImageHoldsLinesThatReachPastTheNodes() throws {
        let plain = try size(of: Pair())
        let looped = try size(of: Pair(loop: true))

        XCTAssertGreaterThan(looped.width, plain.width + 20)
    }

    /// A view with no figure in it has no image to give.
    @MainActor
    func test_noFigureNoImage() {
        XCTAssertNil(FigureRenderer(content: Color.red.frame(width: 10, height: 10)).cgImage)
    }

    @MainActor
    func test_aPNGIsAPNG() throws {
        let png = try XCTUnwrap(FigureRenderer(content: FigureView(Pair())).pngData())

        XCTAssertEqual(Array(png.prefix(4)), [0x89, 0x50, 0x4E, 0x47])
    }

    /// Whatever flows along a figure's lines is drawn where it starts out, so
    /// the same figure makes the same picture whenever it is drawn.
    @MainActor
    func test_aFlowingFigureIsDrawnTheSameEveryTime() async throws {
        let figure = FigureView(Pair(loop: true)).lineStyle(LineStyle(flow: .dots))
        // The first figure drawn in a process can differ from the rest by a
        // few pixels along its bottom edge, flowing or not.
        _ = try pixels(of: figure)
        let first = try pixels(of: figure)
        try await Task.sleep(for: .milliseconds(300))
        let second = try pixels(of: figure)

        XCTAssertEqual(first, second)
    }
}
