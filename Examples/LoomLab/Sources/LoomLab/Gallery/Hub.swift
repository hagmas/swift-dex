import Loom
import SwiftUI

extension Scenario {
    /// One node many others point at.
    static let hub = Scenario(name: "Hub", steps: 0) { _ in
        AnyView(FigureView(Hub(), routing: .orthogonal))
    }
}

private extension NodeID {
    static let core = NodeID("core")
    static let north = NodeID("north")
    static let east = NodeID("east")
    static let south = NodeID("south")
    static let west = NodeID("west")
    static let northEast = NodeID("northEast")
    static let southWest = NodeID("southWest")
}

private struct Hub: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 48) {
            Row(spacing: 32) {
                TextNode(.north, title: "Logger")
                TextNode(.northEast, title: "Metrics")
            }
            Row(spacing: 32) {
                TextNode(.west, title: "Settings")
                TextNode(.core, title: "Core")
                TextNode(.east, title: "Network")
            }
            Row(spacing: 32) {
                TextNode(.southWest, title: "Storage")
                TextNode(.south, title: "UI")
            }
        }
    }

    var lines: [Line] {
        Line(from: .north, to: .core)
        Line(from: .northEast, to: .core)
        Line(from: .west, to: .core)
        Line(from: .east, to: .core)
        Line(from: .southWest, to: .core)
        Line(from: .south, to: .core)
    }
}
