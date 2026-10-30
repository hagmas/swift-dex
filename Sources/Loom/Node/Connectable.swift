import SwiftUI

/// Something in a figure that lines can connect to.
///
/// Every ``Node`` is connectable, and so is a ``Waypoint``: a line leaves and
/// arrives at one, or passes through the other. What they share is an identity
/// lines can name, and that they report where they ended up, so that the lines
/// can be drawn to them.
public protocol Connectable: FigureElement {
    /// The identity lines refer to.
    var id: NodeID { get }
}

extension View {
    /// Reports this view's bounds under `id`, for lines to find it by.
    func reportsBounds(as id: NodeID) -> some View {
        // Added to what the view's content reports rather than set, which
        // would replace it — the node's frame reports its outline from inside.
        transformAnchorPreference(key: FigureMarksPreference.self, value: .bounds) { marks, anchor in
            marks.anchors[id] = anchor
        }
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
    var outlines: [NodeID: Outline] = [:]
    var lines: [DrawnLineID: CGFloat] = [:]

    /// The space the figure draws its lines in — see ``FigureSpace``.
    var space: Anchor<CGRect>?
}

struct FigureMarksPreference: PreferenceKey {
    static let defaultValue = FigureMarks()

    static func reduce(value: inout FigureMarks, nextValue: () -> FigureMarks) {
        let next = nextValue()
        value.anchors.merge(next.anchors) { $1 }
        value.outlines.merge(next.outlines) { $1 }
        value.lines.merge(next.lines) { $1 }
        value.space = next.space ?? value.space
    }
}
