import CoreGraphics
import XCTest

@testable import Loom

private extension NodeID {
    static let top = NodeID("top")
    static let left = NodeID("left")
    static let right = NodeID("right")
}

/// A round node above two others, with two separate lines down from it.
private struct Tree: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { TextNode(.top, title: "Top") }
            Row {
                TextNode(.left, title: "Left")
                TextNode(.right, title: "Right")
            }
        }
    }

    var lines: [Line] {
        Line(from: .top, to: .left)
        Line(from: .top, to: .right)
        Line(looping: .top.trailing)
    }
}

private let rects: [NodeID: CGRect] = [
    // A circle of radius 50 around (150, 50).
    .top: CGRect(x: 100, y: 0, width: 100, height: 100),
    .left: CGRect(x: 0, y: 200, width: 100, height: 50),
    .right: CGRect(x: 200, y: 200, width: 100, height: 50),
]

private func routes(top shape: NodeShape) -> [RoutedLine] {
    let figure = Tree()
    let placements = figure.arrangement.placements
    return LineRouter.routes(
        for: figure.lines,
        rects: rects,
        outlines: [.top: Outline(shape: shape, scale: 1)],
        addresses: Placement.addresses(in: placements),
        waypointAxes: Placement.waypointAxes(in: placements),
        routing: .orthogonal,
        spacing: 40
    )
}

private func distanceFromCentre(_ point: CGPoint) -> CGFloat {
    point.distance(to: CGPoint(x: 150, y: 50))
}

/// How far from a true circle SwiftUI's `Ellipse` may be: it is drawn with
/// four Bézier curves, which miss the circle by a few hundredths.
private let bezier: CGFloat = 0.05

final class OutlineTests: XCTestCase {
    /// Lines held apart along a round node's side start on its outline, not on
    /// the rectangle around it.
    func test_sideLanesMeetACircle() {
        let drawn = routes(top: .circle)

        for line in drawn.prefix(2) {
            XCTAssertEqual(distanceFromCentre(line.points[0]), 50, accuracy: bezier)
        }
    }

    /// So do both ends of a loop, which sit off the middle of the side.
    func test_aLoopMeetsACircle() {
        let loop = routes(top: .circle)[2]

        XCTAssertEqual(distanceFromCentre(loop.points.first!), 50, accuracy: bezier)
        XCTAssertEqual(distanceFromCentre(loop.points.last!), 50, accuracy: bezier)
    }

    /// A diamond's sides slope, and the lines meet them where they are.
    func test_sideLanesMeetADiamond() {
        let start = routes(top: .diamond)[0].points[0]

        // On the lower-left edge, from (100, 50) to (150, 100): x - y = 50.
        XCTAssertEqual(start.x - start.y, 50, accuracy: 0.01)
    }

    /// On a node with square corners nothing moves.
    func test_aRectangleLeavesTheEndsAlone() {
        let square = routes(top: .roundedRectangle(cornerRadius: 0))
        let unframed = routes(top: .none)

        XCTAssertEqual(square.map(\.points), unframed.map(\.points))
        XCTAssertEqual(square[0].points[0].y, 100)
    }
}
