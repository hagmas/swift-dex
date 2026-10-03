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
    @MainActor @ViewBuilder var elementBody: ElementBody { get }

    /// What this element contributes to the shape of the arrangement.
    ///
    /// One element can contribute several placements — a block of three boxes
    /// is three of them, side by side in whatever container encloses it.
    var placements: [Placement] { get }
}

public extension FigureElement {
    /// Every node identity in this element, in arrangement order.
    var nodeIDs: [NodeID] {
        placements.flatMap(\.nodeIDs)
    }
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

    /// Keeps an element that an `if` may or may not have reached.
    public static func buildOptional<E: FigureElement>(_ element: E?) -> PerhapsElement<E> {
        PerhapsElement(element)
    }

    /// Takes the `if` branch of an `if`/`else`.
    public static func buildEither<First: FigureElement, Second: FigureElement>(
        first: First
    ) -> EitherElement<First, Second> {
        .first(first)
    }

    /// Takes the `else` branch of an `if`/`else`.
    public static func buildEither<First: FigureElement, Second: FigureElement>(
        second: Second
    ) -> EitherElement<First, Second> {
        .second(second)
    }
}

/// An element an `if` may or may not have reached.
///
/// Absent, it contributes nothing at all — not a gap. A node that is not there
/// is not a hole where it would have been; the arrangement closes up, and the
/// nodes that remain move to suit, which is the whole point of writing the
/// figure as a function of what it should be showing.
public struct PerhapsElement<Wrapped: FigureElement>: FigureElement {
    private let wrapped: Wrapped?

    init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }

    /// The element, or nothing.
    @ViewBuilder public var elementBody: some View {
        if let wrapped {
            wrapped.elementBody
        }
    }

    /// The element's placements, or none.
    public var placements: [Placement] {
        wrapped?.placements ?? []
    }
}

/// Whichever branch of an `if`/`else` was taken.
public enum EitherElement<First: FigureElement, Second: FigureElement>: FigureElement {
    case first(First)
    case second(Second)

    /// The branch that was taken.
    @ViewBuilder public var elementBody: some View {
        switch self {
        case .first(let element): element.elementBody
        case .second(let element): element.elementBody
        }
    }

    /// The placements of the branch that was taken.
    public var placements: [Placement] {
        switch self {
        case .first(let element): element.placements
        case .second(let element): element.placements
        }
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

    /// Both elements' placements, in order.
    ///
    /// A pair is how a block is folded together, not a container in its own
    /// right, so it adds no level to the tree.
    public var placements: [Placement] {
        first.placements + second.placements
    }
}
