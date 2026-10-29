import Loom
import SwiftUI

// Figures of the kinds a talk tends to draw, each written the way an author
// would write it, to look through for whatever reads oddly.

extension Scenario {
    /// A class diagram: subclasses gathering under one hollow arrowhead,
    /// conformance dashed, and a dependency.
    static let classDiagram = Scenario(name: "Class diagram", steps: 0) { _ in
        AnyView(
            FigureView(ClassDiagram(), routing: .orthogonal)
                .lineStyle(LineStyle(cornerRadius: 6))
        )
    }

    /// A state machine: transitions both ways between two states, loops on
    /// two states, and a transition that goes round the outside.
    static let stateMachine = Scenario(name: "State machine", steps: 0) { _ in
        AnyView(FigureView(StateMachine(), routing: .orthogonal))
    }

    /// Layers of an app, each a row of boxes, with many lines between
    /// neighbouring layers.
    static let layers = Scenario(name: "Layers", steps: 0) { _ in
        AnyView(FigureView(Layers(), routing: .orthogonal))
    }

    /// The same layers with straight lines.
    static let layersStraight = Scenario(name: "Layers, straight", steps: 0) { _ in
        AnyView(FigureView(Layers(), routing: .straight))
    }

    /// A flowchart whose "no" branch loops back up round the side.
    static let flowchart = Scenario(name: "Flowchart", steps: 0) { _ in
        AnyView(FigureView(Flowchart(aligned: false), routing: .orthogonal))
    }

    /// The same flowchart with its boxes lined up on a spine, so the lines
    /// down it run straight.
    static let flowchartAligned = Scenario(name: "Flowchart, aligned", steps: 0) { _ in
        AnyView(FigureView(Flowchart(aligned: true), routing: .orthogonal))
    }

    /// Nodes of every shape, with lines sitting side by side and a loop on
    /// them, so that their ends are off the middle of a side.
    static let shapes = Scenario(name: "Shapes", steps: 0) { _ in
        AnyView(FigureView(Shapes(), routing: .orthogonal))
    }

    /// One node many others point at.
    static let hub = Scenario(name: "Hub", steps: 0) { _ in
        AnyView(FigureView(Hub(), routing: .orthogonal))
    }

    /// Titles long and short, some wrapping inside a width limit, and rows of
    /// uneven length held in columns with holes.
    static let ragged = Scenario(name: "Ragged titles", steps: 0) { _ in
        AnyView(
            FigureView(Ragged(), routing: .orthogonal)
                .nodeStyle(NodeStyle(maxWidth: 180))
        )
    }

    /// A pipeline that grows a stage at a time, its fan widening as it goes.
    static let growingFan = Scenario(name: "Growing fan", steps: 3) { step in
        AnyView(
            FigureView(GrowingFan(step: step), routing: .orthogonal)
                .lineStyle(LineStyle(cornerRadius: 6))
        )
    }
}

private extension NodeStyle {
    static let protocolType = NodeStyle(fill: Color(white: 0.96), fontWeight: .medium)
    static let classType = NodeStyle(fill: Color(red: 0.89, green: 0.93, blue: 1), stroke: .blue)
    static let structType = NodeStyle(
        shape: .roundedRectangle(cornerRadius: 2),
        fill: Color(red: 1, green: 0.94, blue: 0.86),
        stroke: .orange
    )

    // Shapes
    static let state = NodeStyle.standard.with {
        $0.shape = .circle
        $0.minWidth = 0
    }
    static let decision = NodeStyle.standard.with {
        $0.shape = .diamond
        $0.minWidth = 0
    }
    static let terminal = NodeStyle.standard.with { $0.shape = .capsule }
    static let note = NodeStyle.standard.with {
        $0.shape = .ellipse
        $0.minWidth = 0
    }
}

private extension LineStyle {
    static let inheritance = LineStyle(cornerRadius: 6, arrowHead: .hollow)
    static let conformance = LineStyle(cornerRadius: 6, dash: [5, 3], arrowHead: .hollow)
    static let dependency = LineStyle(cornerRadius: 6, dash: [5, 3], arrowHead: .open)
}

private extension NodeID {
    // Class diagram
    static let animal = NodeID("animal")
    static let dog = NodeID("dog")
    static let cat = NodeID("cat")
    static let bird = NodeID("bird")
    static let named = NodeID("named")
    static let food = NodeID("food")

    // State machine
    static let idle = NodeID("idle")
    static let loading = NodeID("loading")
    static let loaded = NodeID("loaded")
    static let failed = NodeID("failed")

    // Layers
    static let home = NodeID("home")
    static let search = NodeID("search")
    static let profile = NodeID("profile")
    static let feedModel = NodeID("feedModel")
    static let userModel = NodeID("userModel")
    static let api = NodeID("api")
    static let cache = NodeID("cache")
    static let auth = NodeID("auth")

    // Flowchart
    static let start = NodeID("start")
    static let fetch = NodeID("fetch")
    static let valid = NodeID("valid")
    static let save = NodeID("save")
    static let done = NodeID("done")
    static let back = NodeID("back")

    // Shapes
    static let begin = NodeID("begin")
    static let ready = NodeID("ready")
    static let saving = NodeID("saving")
    static let check = NodeID("check")
    static let ok = NodeID("ok")
    static let retrying = NodeID("retrying")
    static let aside = NodeID("aside")

    // Hub
    static let core = NodeID("core")
    static let north = NodeID("north")
    static let east = NodeID("east")
    static let south = NodeID("south")
    static let west = NodeID("west")
    static let northEast = NodeID("northEast")
    static let southWest = NodeID("southWest")

    // Ragged
    static let short = NodeID("short")
    static let long = NodeID("long")
    static let longer = NodeID("longer")
    static let tiny = NodeID("tiny")

    // Growing fan
    static let source = NodeID("source")
    static let stage1 = NodeID("stage1")
    static let stage2 = NodeID("stage2")
    static let stage3 = NodeID("stage3")
    static let stage4 = NodeID("stage4")
}

private struct ClassDiagram: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 56) {
            Row(spacing: 40) {
                TextNode(.named, title: "Named").nodeStyle(.protocolType)
                TextNode(.animal, title: "Animal").nodeStyle(.classType)
            }
            Row(spacing: 24) {
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

private struct StateMachine: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 56) {
            Row(spacing: 48) {
                TextNode(.idle, title: "Idle")
                TextNode(.loading, title: "Loading")
            }
            Row(spacing: 48) {
                TextNode(.loaded, title: "Loaded")
                TextNode(.failed, title: "Failed")
            }
        }
    }

    var lines: [Line] {
        Line(from: .idle, to: .loading, label: "load")
        Line(from: .loading, to: .idle, label: "cancel")
        Line(from: .loading, to: .loaded, label: "success")
        Line(from: .loading, to: .failed, label: "error")
        Line(from: .failed.trailing, to: .loading.trailing, label: "retry")
        Line(looping: .loading.top, label: "progress")
        Line(looping: .loaded.bottom, label: "refresh")
    }
}

private struct Layers: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 64) {
            Row(spacing: 24) {
                TextNode(.home, title: "HomeView")
                TextNode(.search, title: "SearchView")
                TextNode(.profile, title: "ProfileView")
            }
            Row(spacing: 24) {
                TextNode(.feedModel, title: "FeedModel")
                TextNode(.userModel, title: "UserModel")
            }
            Row(spacing: 24) {
                TextNode(.api, title: "APIClient")
                TextNode(.cache, title: "Cache")
                TextNode(.auth, title: "Auth")
            }
        }
    }

    var lines: [Line] {
        Line(from: .home, to: .feedModel)
        Line(from: .search, to: .feedModel)
        Line(from: .search, to: .userModel)
        Line(from: .profile, to: .userModel)
        Line(from: .feedModel, to: .api, .cache)
        Line(from: .userModel, to: .api, .auth)
    }
}

private struct Flowchart: Figure {
    /// Whether the boxes are lined up on the column's spine.
    ///
    /// Without it, the waypoint beside "Fetch data" pulls that row's middle
    /// off the others', and every line through it bends.
    var aligned: Bool

    var arrangement: some FigureElement {
        Column(alignment: aligned ? .columnSpine : .center, spacing: 40) {
            Row { TextNode(.start, title: "Start") }
            Row(spacing: 64) {
                TextNode(.fetch, title: "Fetch data").aligned(on: .columnSpine)
                Waypoint(.back)
            }
            Row { TextNode(.valid, title: "Valid?") }
            Row { TextNode(.save, title: "Save") }
            Row { TextNode(.done, title: "Done") }
        }
    }

    var lines: [Line] {
        Line(from: .start, to: .fetch)
        Line(from: .fetch, to: .valid)
        Line(from: .valid, to: .save, label: "yes")
        Line(from: .valid.trailing, to: .fetch.trailing, through: .back, label: "no")
        Line(from: .save, to: .done)
    }
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

private struct GrowingFan: Figure {
    var step: Int

    var arrangement: some FigureElement {
        Column(spacing: 56) {
            Row { TextNode(.source, title: "Source") }
            Row(spacing: 24) {
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

private struct Shapes: Figure {
    var arrangement: some FigureElement {
        Column(alignment: .columnSpine, spacing: 32) {
            Row { TextNode(.begin, title: "Begin").nodeStyle(.terminal) }
            Row(spacing: 48) {
                TextNode(.ready, title: "Ready").nodeStyle(.state).aligned(on: .columnSpine)
                TextNode(.aside, title: "Logs").nodeStyle(.note)
            }
            Row(spacing: 48) {
                TextNode(.saving, title: "Saving").nodeStyle(.state)
                TextNode(.check, title: "Valid?").nodeStyle(.decision).aligned(on: .columnSpine)
            }
            Row(spacing: 48) {
                TextNode(.ok, title: "Done").nodeStyle(.state)
                TextNode(.retrying, title: "Retry").nodeStyle(.state)
            }
        }
    }

    var lines: [Line] {
        Line(from: .begin, to: .ready)
        Line(from: .ready, to: .aside)
        Line(from: .ready, to: .check, label: "submit")
        Line(from: .ready.leading, to: .saving.top, label: "autosave")
        Line(from: .saving, to: .check)
        Line(from: .check, to: .ok, .retrying)
        Line(from: .retrying.top, to: .check.trailing)
        Line(looping: .retrying.trailing, label: "wait")
    }
}
