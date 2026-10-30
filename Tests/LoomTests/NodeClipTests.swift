import AppKit
import SwiftUI
import XCTest

@testable import Loom

/// A node whose content draws a red square well to the right of where it is
/// laid out — as a node does that is still growing towards its content.
private struct Overreaching: Node {
    let id = NodeID("node")

    var body: some View {
        Color(red: 1, green: 0, blue: 0)
            .frame(width: 20, height: 20)
            .offset(x: 200)
    }
}

/// Whether the point 270 across, 50 down — where the red square is drawn,
/// outside the node's frame — comes out red.
@MainActor
private func showsBeyondTheFrame(_ shape: NodeShape) -> Bool {
    // The frame is the default minimum width, 140, with the square laid out in
    // its middle at 60...80 and drawn 200 further on.
    let view = Overreaching()
        .elementBody
        .nodeStyle(NodeStyle.standard.with { $0.shape = shape })
        .frame(width: 600, height: 100, alignment: .leading)
        .background(.white)
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    guard let image = renderer.cgImage, let color = NSBitmapImageRep(cgImage: image).colorAt(x: 270, y: 50) else {
        XCTFail("Could not draw the node")
        return false
    }
    return color.redComponent > 0.9 && color.greenComponent < 0.1
}

@MainActor
final class NodeClipTests: XCTestCase {
    /// A node's content is drawn inside its outline, never past it.
    func test_contentIsClippedToTheOutline() {
        XCTAssertFalse(showsBeyondTheFrame(.roundedRectangle(cornerRadius: 8)))
        XCTAssertFalse(showsBeyondTheFrame(.circle))
    }

    /// A node with no outline draws its own, wherever it likes.
    func test_aNodeWithNoOutlineIsNotClipped() {
        XCTAssertTrue(showsBeyondTheFrame(.none))
    }
}
