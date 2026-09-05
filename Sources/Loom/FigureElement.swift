import SwiftUI

/// A member of a figure's arrangement.
///
/// The arrangement is a *closed* tree: only `Row`, `Column`, `Empty` and types
/// conforming to ``Node`` can appear in it. It is deliberately not a
/// `@ViewBuilder` — a figure that accepts arbitrary views is a figure with no
/// shape of its own, and the tree could no longer be walked to check that every
/// line refers to a node that exists.
///
/// Conform to ``Node`` rather than to this protocol directly.
public protocol FigureElement {
    /// The view this element renders as.
    ///
    /// Plumbing: Loom builds it, callers never write it. ``Node`` supplies it
    /// from the node's `body`.
    associatedtype ElementBody: View

    /// The rendered form of this element.
    @ViewBuilder var elementBody: ElementBody { get }

    /// Every node identity in this element, in arrangement order.
    var nodeIDs: [NodeID] { get }
}

/// Builds the closed tree of an arrangement.
///
/// Only ``FigureElement`` values are accepted, so `{ }` syntax costs nothing in
/// strictness: writing a `Text` inside a `Row` fails to compile.
@resultBuilder
public enum FigureBuilder {
    /// Starts a block with its first element.
    public static func buildPartialBlock<E: FigureElement>(first: E) -> E {
        first
    }

    /// Folds the next element onto the ones already gathered.
    public static func buildPartialBlock<Accumulated: FigureElement, Next: FigureElement>(
        accumulated: Accumulated,
        next: Next
    ) -> ElementPair<Accumulated, Next> {
        ElementPair(accumulated, next)
    }
}

/// Two elements, side by side in the tree.
///
/// The builder folds a block into left-nested pairs rather than erasing to
/// `any FigureElement`. Concrete types all the way down are what let SwiftUI
/// keep each node's structural identity, which is what makes a node's arrival
/// or departure animate rather than tear down and rebuild.
public struct ElementPair<First: FigureElement, Second: FigureElement>: FigureElement {
    private let first: First
    private let second: Second

    init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    /// Both elements, in order.
    public var elementBody: some View {
        TupleView((first.elementBody, second.elementBody))
    }

    /// The identities of both elements, in order.
    public var nodeIDs: [NodeID] {
        first.nodeIDs + second.nodeIDs
    }
}
