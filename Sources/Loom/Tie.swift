import SwiftUI

/// A point a line is routed through — a cable tie, holding a bundle on its way
/// past.
///
/// A tie is placed in the arrangement like anything else, which is the whole
/// point of it: a waypoint written as a coordinate would be wrong the moment
/// the figure reflowed, whereas a waypoint that lives in a row moves with the
/// row.
///
/// ```swift
/// Row {
///     Box(.viewModel, title: "ViewModel")
///     Tie(.sideChannel, axis: .vertical)
/// }
///
/// Line(from: .viewModel, to: .store, through: .sideChannel)
/// ```
///
/// Ties take no space until lines use them. Every line passing through one is
/// held a little apart from its neighbours, and the tie widens to hold the
/// bundle — so a tie's size is decided by the lines, not by the author. That is
/// the one direction in which lines reach back into the layout, and it is safe
/// because it is a count, not a judgement: nothing about where a node sits is
/// up for reconsideration.
public struct Tie: Node {
    /// The identity lines refer to.
    public let id: NodeID

    /// The direction lines run as they pass through.
    ///
    /// A `.vertical` tie carries lines up and down, so the bundle widens it
    /// sideways.
    public var axis: Axis

    /// Creates a tie.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to.
    ///   - axis: The direction lines run as they pass through.
    public init(_ id: NodeID, axis: Axis = .vertical) {
        self.id = id
        self.axis = axis
    }

    /// The content and behavior of the view.
    public var body: some View {
        TieBody(id: id, axis: axis)
    }
}

/// The space a tie holds open, read from the environment.
///
/// A tie cannot know how many lines use it — only the figure knows that — so
/// the span is worked out once and handed down.
private struct TieBody: View {
    @Environment(\.tieSpans) private var spans

    let id: NodeID
    let axis: Axis

    var body: some View {
        let span = spans[id] ?? 0
        Color.clear
            .frame(
                width: axis == .vertical ? span : 0,
                height: axis == .vertical ? 0 : span
            )
    }
}

extension EnvironmentValues {
    /// How wide each tie's bundle is.
    @Entry var tieSpans: [NodeID: CGFloat] = [:]
}

/// Works out how much room each tie's bundle needs.
enum TieSpans {
    /// The span each tie holds open, given the lines that pass through it.
    ///
    /// A tie carrying one line is a point; every line after that adds a lane.
    static func spans(for lines: [Line], spacing: CGFloat) -> [NodeID: CGFloat] {
        var counts: [NodeID: Int] = [:]
        for line in lines {
            for waypoint in line.waypoints {
                counts[waypoint, default: 0] += 1
            }
        }
        return counts.mapValues { CGFloat($0 - 1) * spacing }
    }
}
