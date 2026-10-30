import AppKit
import SwiftUI
import XCTest

@testable import Loom

private extension NodeID {
    static let client = NodeID("client")
    static let backend = NodeID("backend")
    static let api = NodeID("api")
    static let db = NodeID("db")
}

/// A client above a cluster of two.
private struct System: Figure {
    var arrangement: some FigureElement {
        Column {
            Row { TextNode(.client, title: "Client") }
            Cluster(.backend, title: "Backend") {
                Row {
                    TextNode(.api, title: "API")
                    TextNode(.db, title: "DB")
                }
            }
        }
    }

    var lines: [Line] {
        Line(from: .client, to: .db)
        Line(from: .client, to: .backend)
        Line(from: .api, to: .db)
    }
}

private func edges(_ from: NodeID, _ to: NodeID) -> (start: NodeEdge, end: NodeEdge)? {
    LineRouter.edges(from: from, to: to, addresses: Placement.addresses(in: System().arrangement.placements))
}

final class ClusterTests: XCTestCase {
    /// A cluster is one element, holding its elements, and a node lines can
    /// name.
    func test_aClusterHoldsItsElements() {
        XCTAssertEqual(
            System().arrangement.placements,
            [
                .group(
                    .vertical,
                    [
                        .group(.horizontal, [.node(.client)]),
                        .cluster(.backend, [.group(.horizontal, [.node(.api), .node(.db)])]),
                    ]
                )
            ]
        )
        XCTAssertEqual(System().nodeIDs, [.client, .backend, .api, .db])
    }

    /// A line from outside to a node in a cluster leaves the way it would for
    /// the cluster: the client is above it, so the line goes down — even to a
    /// node that sits off to the side in the cluster's own row.
    func test_aLineIntoAClusterLeavesAsForTheCluster() {
        XCTAssertEqual(edges(.client, .db)?.start, .bottom)
        XCTAssertEqual(edges(.client, .db)?.end, .top)
        XCTAssertEqual(edges(.client, .backend)?.start, .bottom)
        XCTAssertEqual(edges(.client, .backend)?.end, .top)
    }

    /// Inside, nodes are seated as they would be anywhere.
    func test_insideAClusterNodesAreSeatedAsUsual() {
        XCTAssertEqual(edges(.api, .db)?.start, .trailing)
        XCTAssertEqual(edges(.api, .db)?.end, .leading)
    }

    /// A line inside a cluster shows over the cluster's box, however solid
    /// its fill: the box is drawn beneath the lines.
    @MainActor
    func test_aLineInsideAClusterShowsOverItsBox() {
        struct Pair: Figure {
            var arrangement: some FigureElement {
                Cluster(.backend) {
                    Row(spacing: 80) {
                        TextNode(.api, title: "API")
                        TextNode(.db, title: "DB")
                    }
                }
            }

            var lines: [Line] {
                Line(from: .api, to: .db)
            }
        }

        let view = FigureView(Pair())
            .clusterStyle(ClusterStyle(fill: Color(white: 0.8)))
            .frame(width: 600, height: 200)
            .background(.white)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        guard let image = renderer.cgImage else {
            return XCTFail("Could not draw the figure")
        }

        // The line crosses the gap between the two nodes, which the middle of
        // the figure falls in.
        let bitmap = NSBitmapImageRep(cgImage: image)
        let column = (0..<200).compactMap { bitmap.colorAt(x: 300, y: $0)?.brightnessComponent }
        // A line a pixel and a half wide falls across two rows of pixels,
        // darkening both a long way short of black.
        XCTAssertTrue(column.contains { $0 < 0.4 }, "no line drawn over the box")
        XCTAssertTrue(column.contains { abs($0 - 0.8) < 0.05 }, "no box drawn")
    }
}
