import SwiftUI

/// A point a line is routed through.
///
/// Reach for it whenever a line should go somewhere the two nodes alone would
/// not send it. A waypoint is placed in the arrangement like anything else,
/// which is the whole point of it: a detour written as a coordinate would be
/// wrong the moment the figure reflowed, whereas one that lives in a row moves
/// with the row.
///
/// ```swift
/// Row {
///     Box(.viewModel, title: "ViewModel")
///     Waypoint(.sideChannel)
/// }
///
/// Line(from: .viewModel, to: .store, through: .sideChannel)
/// ```
///
/// A line names as many as it needs, in the order it meets them, and each hop
/// picks its own edges — so a line leaves aimed at its first waypoint rather
/// than at where it eventually ends up.
///
/// Several lines may share one. When they do they are held apart rather than
/// laid on top of each other, and the waypoint widens to hold the bundle — so
/// its size is decided by the lines, not by the author. That is the one
/// direction in which lines reach back into the layout, and it is safe because
/// it is a count, not a judgement: nothing about where a node sits is up for
/// reconsideration. A waypoint no line uses takes no space at all.
public struct Waypoint: Node {
    /// The identity lines refer to.
    public let id: NodeID

    /// The direction a line leaves along.
    ///
    /// Under ``Line/Routing/orthogonal`` this is what decides where the turn
    /// falls: a `.vertical` waypoint sends the line away downwards, so the
    /// corner lands on the waypoint itself, while a `.horizontal` one keeps it
    /// running sideways and the turn happens further along. It is also the
    /// direction a bundle lies across, since lines spread over the travel
    /// rather than along it.
    public var axis: Axis

    /// Creates a waypoint.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to.
    ///   - axis: The direction a line leaves along.
    public init(_ id: NodeID, axis: Axis = .vertical) {
        self.id = id
        self.axis = axis
    }

    /// The content and behavior of the view.
    public var body: some View {
        WaypointBody(id: id, axis: axis)
    }

    /// The waypoint, and the direction it sends its lines.
    public var placements: [Placement] {
        [.waypoint(id, axis)]
    }
}

/// The space a waypoint holds open, read from the environment.
///
/// A waypoint cannot know how many lines use it — only the figure knows that —
/// so the span is worked out once and handed down.
private struct WaypointBody: View {
    @Environment(\.waypointSpans) private var spans

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
    /// How wide each waypoint's bundle is.
    @Entry var waypointSpans: [NodeID: CGFloat] = [:]
}

/// Works out how much room each waypoint's bundle needs.
enum WaypointSpans {
    /// The span each waypoint holds open, given the lines that pass through it.
    ///
    /// A waypoint carrying one line is a point; every line after that adds a
    /// lane.
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
