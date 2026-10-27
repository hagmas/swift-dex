import SwiftUI

/// A thing a figure connects.
///
/// `Node` is a protocol so that what a node *looks like* stays open while the
/// arrangement stays closed. Define a type per kind of node — the type is the
/// category, which is why nodes carry no `role` or `kind` tag:
///
/// ```swift
/// struct ServiceNode: Node {
///     let id: NodeID
///     var name: String
///
///     var body: some View {
///         Text(name)
///             .padding()
///             .background(Capsule().fill(.orange))
///     }
/// }
/// ```
///
/// Loom ships ``Box`` for the common case.
///
/// A node's bounds are published under its ``id`` so lines can find it; that is
/// the whole of what Loom does with a node beyond placing it.
public protocol Node: FigureElement {
    /// The view this node renders as.
    associatedtype Body: View

    /// The identity lines refer to.
    var id: NodeID { get }

    /// The node's appearance. Anything at all.
    @ViewBuilder var body: Body { get }
}

public extension Node {
    var elementBody: some View {
        body
            .anchorPreference(key: FigureMarksPreference.self, value: .bounds) {
                FigureMarks(anchors: [id: $0])
            }
    }

    var placements: [Placement] {
        [.node(id)]
    }
}

/// What the parts of a figure report upwards, for the lines to be drawn from.
///
/// Where each node ended up, in the figure's coordinate space — nodes are
/// placed by SwiftUI, so this is the only channel through which a line learns
/// a node's position — and how much of each line has appeared, from none
/// of it to all.
///
/// The two travel together because the lines can only read one preference,
/// and both have to arrive frame by frame while the figure animates.
struct FigureMarks {
    var anchors: [NodeID: Anchor<CGRect>] = [:]
    var lines: [DrawnLineID: CGFloat] = [:]
}

struct FigureMarksPreference: PreferenceKey {
    static let defaultValue = FigureMarks()

    static func reduce(value: inout FigureMarks, nextValue: () -> FigureMarks) {
        let next = nextValue()
        value.anchors.merge(next.anchors) { $1 }
        value.lines.merge(next.lines) { $1 }
    }
}
