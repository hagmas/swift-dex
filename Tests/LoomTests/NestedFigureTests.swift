import AppKit
import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
}

private struct Pair: Figure {
    var arrangement: some FigureElement {
        Row {
            TextNode(.a, title: "A")
            TextNode(.b, title: "B")
        }
    }

    var lines: [Line] {
        Line(from: .a, to: .b)
    }
}

/// What reaches past a view, of what a figure's parts publish.
@MainActor
private final class Published {
    var anchors: Set<NodeID> = []
    var lines = 0
}

@MainActor
private func published(past view: some View) -> Published {
    let published = Published()
    let renderer = ImageRenderer(
        content: view.backgroundPreferenceValue(FigureMarksPreference.self) { marks in
            let _ = published.anchors = Set(marks.anchors.keys)
            let _ = published.lines = marks.lines.count
            Color.clear
        }
        .frame(width: 400, height: 200)
    )
    _ = renderer.nsImage
    return published
}

@MainActor
final class NestedFigureTests: XCTestCase {
    /// A figure keeps what its parts publish to itself, so that a figure it is
    /// drawn inside never mistakes its nodes for nodes of its own.
    func test_aFigureKeepsItsNodesToItself() {
        let outside = published(past: FigureView(Pair()))

        XCTAssertEqual(outside.anchors, [])
        XCTAssertEqual(outside.lines, 0)
    }

    /// Its nodes do publish, up to the figure.
    func test_theNodesPublishUpToTheFigure() {
        let inside = published(past: Pair().arrangement.elementBody)

        XCTAssertEqual(inside.anchors, [.a, .b])
    }

    /// A figure on its own takes the room it is given; one inside a figure
    /// takes only what its arrangement needs.
    func test_aFigureInsideAFigureIsOnlyAsBigAsItsArrangement() {
        let room = CGSize(width: 1000, height: 1000)
        let alone = NSHostingController(rootView: FigureView(Pair())).sizeThatFits(in: room)
        let inside = NSHostingController(rootView: FigureView(Pair()).environment(\.isInsideFigure, true))
            .sizeThatFits(in: room)

        XCTAssertEqual(alone, room)
        XCTAssertLessThan(inside.width, 500)
        XCTAssertLessThan(inside.height, 200)
    }
}
