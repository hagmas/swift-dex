import Loom
import SwiftUI

extension Scenario {
    /// A class diagram: subclasses gathering under one hollow arrowhead,
    /// conformance dashed, and a dependency.
    static let classDiagram = Scenario(name: "Class diagram", steps: 0) { _ in
        AnyView(
            FigureView(ClassDiagram(), routing: .orthogonal)
                .lineStyle(LineStyle(cornerRadius: 8))
        )
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
    static let protocolType = NodeStyle(fill: Color(white: 0.96), fontWeight: .medium)
    static let classType = NodeStyle(fill: Color(red: 0.89, green: 0.93, blue: 1), stroke: .blue)
    static let structType = NodeStyle(
        shape: .roundedRectangle(cornerRadius: 3),
        fill: Color(red: 1, green: 0.94, blue: 0.86),
        stroke: .orange
    )
}

private extension LineStyle {
    static let inheritance = LineStyle(cornerRadius: 8, arrowHead: .hollow)
    static let conformance = LineStyle(cornerRadius: 8, dash: [7, 4], arrowHead: .hollow)
    static let dependency = LineStyle(cornerRadius: 8, dash: [7, 4], arrowHead: .open)
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
