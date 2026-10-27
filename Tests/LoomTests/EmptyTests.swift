import AppKit
import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let box = NodeID("box")
}

@MainActor
final class EmptyTests: XCTestCase {
    /// A hole holds a node's width but, told no height, takes none — so a row
    /// with one in it is as tall as its boxes, however much room it is given.
    func test_aHoleTakesNoHeightOfItsOwn() {
        let withHole = Row {
            Empty()
            TextNode(.box, title: "Box")
        }
        let without = Row {
            TextNode(.box, title: "Box")
        }

        let room = CGSize(width: 1000, height: 1000)
        let height = NSHostingController(rootView: withHole.elementBody).sizeThatFits(in: room).height
        let boxHeight = NSHostingController(rootView: without.elementBody).sizeThatFits(in: room).height

        XCTAssertEqual(height, boxHeight)
    }

    /// Told a height, it takes that much.
    func test_aHoleTakesTheHeightItIsGiven() {
        let row = Row { Empty(height: 300) }

        let height = NSHostingController(rootView: row.elementBody)
            .sizeThatFits(in: CGSize(width: 1000, height: 1000)).height

        XCTAssertEqual(height, 300)
    }
}
