import Loom
import SwiftUI

/// A pipeline that grows a stage at a time, its fan widening as it goes.
struct GrowingFanScenario: Scenario {
    static let name = "Growing fan"
    static let steps = 3

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(GrowingFan(step: step), routing: routing)
            .nodeStyle(.juicy(.soda))
            .lineStyle(.iceCandy(cornerRadius: 8))
    }
}

private extension NodeID {
    static let source = NodeID("source")
    static let stage1 = NodeID("stage1")
    static let stage2 = NodeID("stage2")
    static let stage3 = NodeID("stage3")
    static let stage4 = NodeID("stage4")
}

private struct GrowingFan: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 80) {
            Row { TextNode(.source, title: "Source").nodeStyle(.juicy(.orange)) }
            Row(spacing: 32) {
                TextNode(.stage1, title: "Parse")
                if step >= 1 { TextNode(.stage2, title: "Validate") }
                if step >= 2 { TextNode(.stage3, title: "Enrich") }
                if step >= 3 { TextNode(.stage4, title: "Store") }
            }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .stage1, .stage2, .stage3, .stage4, label: "feeds")
    }
}
