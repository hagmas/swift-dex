import Loom
import SwiftUI

extension Scenario {
    /// Titles long and short, some wrapping inside a width limit, and rows of
    /// uneven length held in columns with holes.
    static let ragged = Scenario(name: "Ragged titles", steps: 0) { _ in
        AnyView(
            FigureView(Ragged(), routing: .orthogonal)
                .nodeStyle(NodeStyle(maxWidth: 180))
        )
    }
}

private extension NodeID {
    static let short = NodeID("short")
    static let long = NodeID("long")
    static let longer = NodeID("longer")
    static let tiny = NodeID("tiny")
}

private struct Ragged: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 48) {
            Row(spacing: 24) {
                TextNode(.short, title: "DB")
                TextNode(.long, title: "A service whose name goes on for a while")
                TextNode(.tiny, title: "X")
            }
            Row(spacing: 24) {
                Empty()
                TextNode(.longer, title: "Something with an even longer name than that one, really")
                Empty()
            }
        }
    }

    var lines: [Line] {
        Line(from: .short, to: .longer, label: "a label longer than the gap")
        Line(from: .long, to: .longer)
        Line(from: .tiny, to: .longer)
    }
}
