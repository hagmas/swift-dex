import Loom
import SwiftUI

/// One node many others point at.
struct HubScenario: Scenario {
    static let name = "Hub"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Hub(), routing: routing)
            .nodeStyle(.frosty(.soda))
            .lineStyle(.iceCandy)
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
        Column(spacing: 68) {
            Row(spacing: 44) {
                TextNode(.north, title: "Logger")
                TextNode(.northEast, title: "Metrics")
            }
            Row(spacing: 44) {
                TextNode(.west, title: "Settings")
                TextNode(.core, title: "Core").nodeStyle(.juicy(.grape))
                TextNode(.east, title: "Network")
            }
            Row(spacing: 44) {
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
