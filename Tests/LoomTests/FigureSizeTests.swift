import AppKit
import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
    static let c = NodeID("c")
}

private struct Wide: Figure {
    var arrangement: some FigureElement {
        Row(spacing: 40) {
            TextNode(.a, title: "A service with a long name")
            TextNode(.b, title: "Another service with a long name")
            TextNode(.c, title: "And a third one, longer still")
        }
    }

    var lines: [Line] {
        Line(from: .a, to: .b)
        Line(from: .b, to: .c)
    }
}

/// The sizes a figure reported, drawn in a given room.
@MainActor
private func reportedSizes(in room: CGSize) -> [CGSize] {
    var sizes: [CGSize] = []
    let renderer = ImageRenderer(
        content: FigureView(Wide())
            .onFigureSizeChange { sizes.append($0) }
            .frame(width: room.width, height: room.height)
    )
    _ = renderer.nsImage
    return sizes
}

@MainActor
final class FigureSizeTests: XCTestCase {
    /// A figure tells how big it is, which the room it was given does not say.
    func test_aFigureReportsItsOwnSize() throws {
        let size = try XCTUnwrap(reportedSizes(in: CGSize(width: 2000, height: 1000)).last)

        XCTAssertLessThan(size.width, 2000)
        XCTAssertLessThan(size.height, 1000)
        XCTAssertGreaterThan(size.width, 0)
    }

    /// A figure is laid out the same however much room it is given: too
    /// little, and it is drawn past it rather than squeezed.
    func test_aFigureIsTheSameSizeInAnyRoom() throws {
        let roomy = try XCTUnwrap(reportedSizes(in: CGSize(width: 2000, height: 1000)).last)
        let cramped = try XCTUnwrap(reportedSizes(in: CGSize(width: 200, height: 100)).last)

        XCTAssertEqual(roomy, cramped)
        XCTAssertGreaterThan(cramped.width, 200)
    }

    /// A figure inside a node does not report its size to whoever asked the
    /// figure outside.
    func test_aFigureInsideAFigureDoesNotReport() {
        var sizes: [CGSize] = []
        let renderer = ImageRenderer(
            content: FigureView(Wide())
                .environment(\.isInsideFigure, true)
                .onFigureSizeChange { sizes.append($0) }
                .frame(width: 2000, height: 1000)
        )
        _ = renderer.nsImage

        XCTAssertEqual(sizes, [])
    }
}
