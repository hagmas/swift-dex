import Loom
import SwiftUI

/// A class diagram: subclasses gathering under one hollow arrowhead,
/// conformance dashed, and a dependency.
struct ClassDiagramScenario: Scenario {
    static let name = "Class diagram"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(ClassDiagram(), routing: routing)
            .lineStyle(.iceCandy(cornerRadius: 8))
    }
}

private extension NodeID {
    static let animal = NodeID("animal")
    static let dog = NodeID("dog")
    static let cat = NodeID("cat")
    static let bird = NodeID("bird")
    static let named = NodeID("named")
    static let food = NodeID("food")
}

private extension NodeStyle {
    /// A protocol is only a promise, so it is left frosty; the types that
    /// keep it are poured solid.
    static let protocolType = NodeStyle.frosty(.grape)
    static let classType = NodeStyle.juicy(.soda)
    static let structType = NodeStyle.juicy(.orange)
}

private extension LineStyle {
    static let inheritance = LineStyle.iceCandy(cornerRadius: 8).with { $0.arrowHead = .hollow }
    static let conformance = LineStyle.iceCandy(cornerRadius: 8).with {
        $0.dash = [7, 4]
        $0.arrowHead = .hollow
    }
    static let dependency = LineStyle.iceCandy(cornerRadius: 8).with {
        $0.dash = [7, 4]
        $0.arrowHead = .open
    }
}

private struct ClassDiagram: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 80) {
            Row(spacing: 56) {
                TextNode(.named, title: "Named").nodeStyle(.protocolType)
                TextNode(.animal, title: "Animal").nodeStyle(.classType)
            }
            Row(spacing: 32) {
                TextNode(.dog, title: "Dog").nodeStyle(.classType)
                TextNode(.cat, title: "Cat").nodeStyle(.classType)
                TextNode(.bird, title: "Bird").nodeStyle(.classType)
            }
            Row { TextNode(.food, title: "Food").nodeStyle(.structType) }
        }
    }

    var lines: [Line] {
        Line(from: .dog, .cat, .bird, to: .animal, style: .inheritance)
        Line(from: .animal, to: .named, style: .conformance)
        Line(from: .dog, .cat, to: .food, label: "eats", style: .dependency)
    }
}
