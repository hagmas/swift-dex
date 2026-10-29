import AppKit
import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let node = NodeID("node")
}

/// A title that fills its lines almost to the width it is offered.
///
/// Short words leave little room at the end of a line, which is when a circle
/// comes out widest: offered the whole width inside a circle 160 across, this
/// one's diagonal is more than the circle, and the circle used to be squeezed
/// into an oval taller than it was wide.
private let long = String(repeating: "ab ", count: 10)

/// How big a text node framed in `shape` comes out, given plenty of room.
@MainActor
private func frame(_ title: String, _ shape: NodeShape, maxWidth: CGFloat? = nil) -> CGSize {
    let style = NodeStyle.standard.with {
        $0.shape = shape
        $0.minWidth = 0
        $0.maxWidth = maxWidth
    }
    let node = TextNode(.node, title: title).nodeStyle(style)
    return NSHostingController(rootView: node.elementBody).sizeThatFits(in: CGSize(width: 1000, height: 1000))
}

@MainActor
final class EnclosureTests: XCTestCase {
    /// A width limit holds whatever the shape, by wrapping the content.
    func test_everyShapeKeepsToItsWidthLimit() {
        for shape in [NodeShape.roundedRectangle(cornerRadius: 8), .capsule, .circle, .ellipse, .diamond] {
            XCTAssertLessThanOrEqual(frame(long, shape, maxWidth: 160).width, 160.5, "\(shape)")
        }
    }

    /// A circle wraps its content onto narrower lines to keep within the
    /// limit, and stays round.
    func test_aLimitedCircleStaysRound() {
        let size = frame(long, .circle, maxWidth: 160)

        XCTAssertEqual(size.width, size.height, accuracy: 0.5)
    }

    /// A limit wider than the circle needs changes nothing.
    func test_aCircleWithRoomToSpareIsLeftAlone() {
        XCTAssertEqual(frame("Ready", .circle, maxWidth: 500), frame("Ready", .circle))
    }
}
