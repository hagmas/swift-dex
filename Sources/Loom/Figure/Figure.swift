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
    /// drawn — which is the point of it being closed.
    ///
    /// Only what is wrong whatever the figure is showing. A line naming a node
    /// the arrangement does not hold is *not* among them: it is simply not
    /// drawn, which is what lets a figure's lines be written once while its
    /// arrangement decides what is there. The mistake that reading looks like
    /// — a misspelled identity — cannot survive the compiler, since identities
    /// are declared rather than written out at each use. What is left cannot be
    /// told apart from a node that is merely not showing yet, and a warning
    /// that cries wolf on a correct figure is worse than none.
    func issues() -> [FigureIssue] {
        let ids = nodeIDs

        var seen = Set<NodeID>()
        var duplicates: [FigureIssue] = []
        for id in ids where !seen.insert(id).inserted {
            duplicates.append(.duplicateNodeID(id))
        }

        // A side of a node is somewhere a line can meet, not something that can
        // be placed, so a node declared with one has been given an identity no
        // line will match.
        let sided = ids.filter { $0.edge != nil }.map(FigureIssue.nodeNamedWithASide)

        // A loop hangs off one side, so both ends have to name the same one.
        // Told nothing, or told two different sides, the only line left to draw
        // goes through the node.
        let loops =
            lines
            .filter { $0.isLoop && ($0.from[0].edge == nil || $0.from[0].edge != $0.to[0].edge) }
            .map { FigureIssue.loopWithoutASide($0.from[0].node) }

        // A line is known by its route and its name, so that a line still
        // there after a change stays the same line. Two that share both are one
        // line as far as that goes, and only the order they were written in
        // keeps them apart — which shifts the moment one of them is not drawn.
        var keys = Set<LineKey>()
        var indistinguishable: [FigureIssue] = []
        for key in lines.flatMap(\.branchKeys) where !keys.insert(key).inserted {
            indistinguishable.append(.indistinguishableLines(key.route))
        }

        return duplicates + sided + loops + indistinguishable
    }
}

/// Something wrong with a figure whatever it happens to be showing.
public enum FigureIssue: Hashable, Sendable {
    /// Two nodes claim the same identity, so a line to it is ambiguous.
    case duplicateNodeID(NodeID)

    /// A node was declared with one of its own sides named, which is an
    /// identity for a line to meet rather than one a node can have.
    case nodeNamedWithASide(NodeID)

    /// A line comes back to the node it left without naming one side for both
    /// of its ends, so there is nowhere for it to go but through the node.
    ///
    /// Write it as ``Line/init(looping:label:arrow:style:id:)``. A loop that leaves one
    /// side and arrives at another has to travel round the node, which nothing
    /// here does on its own — route it through waypoints instead.
    case loopWithoutASide(NodeID)

    /// Two lines take the same route with the same words on them, or none, so
    /// nothing tells them apart when the figure changes.
    ///
    /// They are still drawn. But a figure that shows one of them only some of
    /// the time can mistake one for the other, and readers cannot tell them
    /// apart either. Give them different labels, or give one an ``Line/id``.
    case indistinguishableLines([NodeID])
}
