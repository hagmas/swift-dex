import Loom
import SwiftUI

/// A statechart the size of a real one: a kettle's states, nested in
/// clusters, with a choice fanning out three ways, lines to and from the
/// clusters themselves, a transition that goes the long way round, a state
/// off to one side, and a legend.
struct StatechartScenario: Scenario {
    static let name = "Statechart"
    static let routing = Line.Routing.curved

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Kettle(), routing: routing)
            .lineStyle(LineStyle(cornerRadius: 8))
    }
}

private extension NodeID {
    static let start = NodeID("start")
    static let off = NodeID("off")
    static let pluggedIn = NodeID("pluggedIn")
    static let standingBy = NodeID("standingBy")
    static let choosing = NodeID("choosing")
    static let greenTea = NodeID("greenTea")
    static let coffee = NodeID("coffee")
    static let boil = NodeID("boil")
    static let heating = NodeID("heating")
    static let warming = NodeID("warming")
    static let holding = NodeID("holding")
    static let cooling = NodeID("cooling")
    static let dryBoil = NodeID("dryBoil")
    static let liftedOff = NodeID("liftedOff")
    static let legend = NodeID("legend")
    static let legendWaiting = NodeID("legendWaiting")
    static let legendWorking = NodeID("legendWorking")
    static let legendChoice = NodeID("legendChoice")
    static let legendFault = NodeID("legendFault")
}

private extension NodeStyle {
    static let waiting = NodeStyle(fill: Color(red: 0.9, green: 0.94, blue: 1), stroke: .blue)
    static let working = NodeStyle(fill: Color(red: 1, green: 0.94, blue: 0.86), stroke: .orange)
    static let choice = NodeStyle.standard.with {
        $0.shape = .capsule
        $0.fill = Color(white: 0.95)
        $0.stroke = .gray
        $0.minWidth = 168
    }
    static let fault = NodeStyle(fill: Color(red: 1, green: 0.9, blue: 0.9), stroke: .red, textColor: .red)
    static let start = NodeStyle(
        shape: .circle,
        fill: .black,
        padding: EdgeInsets(),
        minWidth: 24
    )
}

private extension ClusterStyle {
    static let heating = ClusterStyle.standard.with {
        $0.fill = Color(red: 1, green: 0.98, blue: 0.95)
        $0.stroke = .orange
        $0.titleColor = .orange
    }
    static let legend = ClusterStyle.standard.with {
        $0.fill = .white
        $0.dash = [6, 6]
    }
}

private struct Kettle: Figure {
    var arrangement: some FigureElement {
        Column(alignment: .columnSpine, spacing: 68) {
            Row { TextNode(.start, title: "").nodeStyle(.start).aligned(on: .columnSpine) }
            Row { TextNode(.off, title: "Off").nodeStyle(.waiting).aligned(on: .columnSpine) }
            // The fault off to the side, level with the heating it stops, so
            // the line to it runs straight out of both boxes.
            Row(alignment: .rowSpine, spacing: 112) {
                TextNode(.dryBoil, title: "Dry-boil cut-out").nodeStyle(.fault).aligned(on: .rowSpine)
                Cluster(.pluggedIn, title: "On the base") {
                    // A column of its own, since a cluster stacks what is in
                    // it close together, with no room for the words on the
                    // lines between.
                    Column(spacing: 68) {
                        Row { TextNode(.standingBy, title: "Standing by").nodeStyle(.waiting).aligned(on: .columnSpine) }
                        // Further apart than the rest, for the three lines
                        // between to turn and carry their words.
                        Column(spacing: 100) {
                            Row { TextNode(.choosing, title: "Choosing a drink").nodeStyle(.waiting) }
                            Row(spacing: 32) {
                                TextNode(.greenTea, title: "Green tea · 80°")
                                TextNode(.coffee, title: "Coffee · 92°")
                                TextNode(.boil, title: "Boil · 100°")
                            }
                            .nodeStyle(.choice)
                        }
                        Row {
                            Cluster(.heating, title: "Heating") {
                                Row(alignment: .rowSpine, spacing: 168) {
                                    TextNode(.warming, title: "Warming the water").aligned(on: .rowSpine)
                                    TextNode(.holding, title: "Holding the heat")
                                }
                                .nodeStyle(.working)
                            }
                            .clusterStyle(.heating)
                        }
                        Row { TextNode(.cooling, title: "Cooling down").nodeStyle(.waiting) }
                    }
                }
            }
            Row { TextNode(.liftedOff, title: "Lifted off").nodeStyle(.waiting).aligned(on: .columnSpine) }
            Row {
                Cluster(.legend, title: "Legend") {
                    Row(spacing: 24) {
                        TextNode(.legendWaiting, title: "Waiting").nodeStyle(.waiting)
                        TextNode(.legendWorking, title: "Working").nodeStyle(.working)
                        TextNode(.legendChoice, title: "Choice").nodeStyle(.choice)
                        TextNode(.legendFault, title: "Fault").nodeStyle(.fault)
                    }
                }
                .clusterStyle(.legend)
            }
        }
    }

    var lines: [Line] {
        Line(from: .start, to: .off)
        Line(from: .off, to: .standingBy, label: "set on the base")
        Line(from: .standingBy, to: .choosing, label: "button pressed")
        Line(from: .choosing, to: .greenTea, label: "tea")
        Line(from: .choosing, to: .coffee, label: "coffee")
        Line(from: .choosing, to: .boil, label: "boil")
        Line(from: .greenTea, .coffee, .boil, to: .warming)
        Line(from: .warming, to: .holding, label: "hot enough")
        // The long way round, back to the top of the base.
        Line(from: .holding.trailing, to: .standingBy.trailing, label: "after 30 min")
        Line(from: .warming.leading, to: .dryBoil, label: "no water")
        // From the boxes as a whole: whatever it was doing inside.
        Line(from: .heating, to: .cooling, label: "lid opened")
        Line(from: .pluggedIn, to: .liftedOff, label: "lifted off")
    }
}
