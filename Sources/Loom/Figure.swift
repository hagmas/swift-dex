import SwiftUI

/// A diagram of nodes and the lines between them.
///
/// A figure is a description, not a view: conform a type to it, then render it
/// with ``FigureView``.
///
/// ```swift
/// struct RefactorFigure: Figure {
///     var arrangement: some FigureElement {
///         Column(spacing: 40) {
///             Row { Box(.viewModel, title: "ViewModel") }
///             Row { Box(.repository, title: "Repository") }
///         }
///     }
///
///     var lines: [Line] {
///         Line(from: .viewModel, to: .repository)
///     }
/// }
/// ```
///
/// Nodes are placed first and lines are added afterwards, which is also the
/// order the two properties are read in. A line can never move a node: the
/// arrangement is settled before any line is routed.
public protocol Figure {
    /// The tree of nodes this figure places.
    associatedtype Arrangement: FigureElement

    /// Where the nodes go.
    @FigureBuilder var arrangement: Arrangement { get }

    /// What connects them.
    @LineBuilder var lines: [Line] { get }
}

public extension Figure {
    /// Default value for `lines`: a figure of unconnected nodes.
    @LineBuilder var lines: [Line] {
        [Line]()
    }

    /// Every node identity in the arrangement, in arrangement order.
    var nodeIDs: [NodeID] {
        arrangement.nodeIDs
    }

    /// Problems that make the figure not mean what it says.
    ///
    /// The arrangement is a closed tree, so it can be walked before anything is
    /// drawn — which is the point of it being closed. Worth checking in a test
    /// for any figure whose lines were generated rather than typed.
    func issues() -> [FigureIssue] {
        let ids = nodeIDs
        let known = Set(ids)

        var seen = Set<NodeID>()
        var duplicates: [FigureIssue] = []
        for id in ids where !seen.insert(id).inserted {
            duplicates.append(.duplicateNodeID(id))
        }

        var missing: [FigureIssue] = []
        var reported = Set<NodeID>()
        for line in lines {
            for endpoint in [line.from, line.to]
            where !known.contains(endpoint) && reported.insert(endpoint).inserted {
                missing.append(.lineToUnknownNode(endpoint))
            }
        }

        return duplicates + missing
    }
}

/// Something wrong with a figure, found by walking its arrangement.
public enum FigureIssue: Hashable, Sendable {
    /// Two nodes claim the same identity, so a line to it is ambiguous.
    case duplicateNodeID(NodeID)

    /// A line refers to a node the arrangement does not contain, so it cannot
    /// be drawn.
    case lineToUnknownNode(NodeID)
}
