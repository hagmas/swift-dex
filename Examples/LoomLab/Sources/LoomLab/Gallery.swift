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
    /// several states, and a transition that goes round by a waypoint.
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
        AnyView(FigureView(Flowchart(), routing: .orthogonal))
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
                .boxStyle(BoxStyle(maxWidth: 180))
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

private extension BoxStyle {
    static let protocolType = BoxStyle(fill: Color(white: 0.96), fontWeight: .medium)
    static let classType = BoxStyle(fill: Color(red: 0.89, green: 0.93, blue: 1), stroke: .blue)
    static let structType = BoxStyle(fill: Color(red: 1, green: 0.94, blue: 0.86), stroke: .orange, cornerRadius: 2)
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
    static let retry = NodeID("retry")

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
                Box(.named, title: "Named").boxStyle(.protocolType)
                Box(.animal, title: "Animal").boxStyle(.classType)
            }
            Row(spacing: 24) {
                Box(.dog, title: "Dog").boxStyle(.classType)
                Box(.cat, title: "Cat").boxStyle(.classType)
                Box(.bird, title: "Bird").boxStyle(.classType)
            }
            Row { Box(.food, title: "Food").boxStyle(.structType) }
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
                Box(.idle, title: "Idle")
                Box(.loading, title: "Loading")
            }
            Row(spacing: 48) {
                Box(.failed, title: "Failed")
                Box(.loaded, title: "Loaded")
                Waypoint(.retry)
            }
        }
    }

    var lines: [Line] {
        Line(from: .idle, to: .loading, label: "load")
        Line(from: .loading, to: .idle, label: "cancel")
        Line(from: .loading, to: .loaded, label: "success")
        Line(from: .loading, to: .failed, label: "error")
        Line(from: .failed, to: .loading, through: .retry, label: "retry")
        Line(looping: .loading.trailing, label: "progress")
        Line(looping: .loaded.bottom, label: "refresh")
    }
}

private struct Layers: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 64) {
            Row(spacing: 24) {
                Box(.home, title: "HomeView")
                Box(.search, title: "SearchView")
                Box(.profile, title: "ProfileView")
            }
            Row(spacing: 24) {
                Box(.feedModel, title: "FeedModel")
                Box(.userModel, title: "UserModel")
            }
            Row(spacing: 24) {
                Box(.api, title: "APIClient")
                Box(.cache, title: "Cache")
                Box(.auth, title: "Auth")
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
    var arrangement: some FigureElement {
        Column(spacing: 40) {
            Row { Box(.start, title: "Start") }
            Row(spacing: 64) {
                Box(.fetch, title: "Fetch data")
                Waypoint(.back)
            }
            Row { Box(.valid, title: "Valid?") }
            Row { Box(.save, title: "Save") }
            Row { Box(.done, title: "Done") }
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
                Box(.north, title: "Logger")
                Box(.northEast, title: "Metrics")
            }
            Row(spacing: 32) {
                Box(.west, title: "Settings")
                Box(.core, title: "Core")
                Box(.east, title: "Network")
            }
            Row(spacing: 32) {
                Box(.southWest, title: "Storage")
                Box(.south, title: "UI")
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
                Box(.short, title: "DB")
                Box(.long, title: "A service whose name goes on for a while")
                Box(.tiny, title: "X")
            }
            Row(spacing: 24) {
                Empty()
                Box(.longer, title: "Something with an even longer name than that one, really")
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
            Row { Box(.source, title: "Source") }
            Row(spacing: 24) {
                Box(.stage1, title: "Parse")
                if step >= 1 { Box(.stage2, title: "Validate") }
                if step >= 2 { Box(.stage3, title: "Enrich") }
                if step >= 3 { Box(.stage4, title: "Store") }
            }
        }
    }

    var lines: [Line] {
        Line(from: .source, to: .stage1, .stage2, .stage3, .stage4, label: "feeds")
    }
}
