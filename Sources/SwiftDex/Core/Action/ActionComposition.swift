import Foundation

/// A value that can be placed on a slide's action timeline.
///
/// An `Action` is a leaf. `Parallel` (the `&` operator) runs its children at the
/// same time; `Serial` (the `then(_:)` method) runs its children one after another.
/// Compositions nest freely: `A & B.then(C)` runs `A` alongside the sequence `B → C`.
public protocol ActionComposable {
    /// The duration in clicks assuming every action consumes one click.
    ///
    /// Actual durations are only known at render time; this structural duration
    /// distinguishes build-time positions (e.g. for duplicate detection).
    var structuralDuration: Int { get }

    /// Recursively adds this composition to the container.
    func visit(with container: inout TempActionContainer, structuralStart: Int)
}

public extension Action {
    var structuralDuration: Int {
        1
    }

    func visit(with container: inout TempActionContainer, structuralStart: Int) {
        container.addLeaf(action: self, structuralStart: structuralStart)
    }
}

/// A ResultBuilder that collects the children of a `Serial` or `Parallel` composition.
@resultBuilder
public struct ActionCompositionBuilder {
    /// Collects each line of the block as one child of the composition.
    public static func buildBlock(_ components: any ActionComposable...) -> [any ActionComposable] {
        components
    }
}

/// Actions that run at the same time.
///
/// Produced by the `&` operator, or written as a block:
///
/// ```swift
/// Parallel {
///     ApplyByItem(.fadeInFromUp, to: .bullets)
///     Serial {
///         Apply(.fade, to: .flipper)
///         FlipByItem(.flipper)
///     }
/// }
/// ```
public struct Parallel: ActionComposable {
    let children: [any ActionComposable]

    /// Creates a parallel composition; each line of the block runs at the same time.
    public init(@ActionCompositionBuilder _ children: () -> [any ActionComposable]) {
        self.children = children()
    }

    init(children: [any ActionComposable]) {
        self.children = children
    }

    /// The maximum of the children's structural durations.
    public var structuralDuration: Int {
        max(1, children.map(\.structuralDuration).max() ?? 1)
    }

    /// Recursively adds this composition to the container.
    public func visit(with container: inout TempActionContainer, structuralStart: Int) {
        container.beginGroup(.parallel)
        for child in children {
            child.visit(with: &container, structuralStart: structuralStart)
        }
        container.endGroup()
    }
}

/// Actions that run one after another.
///
/// Produced by the `then(_:)` method, or written as a block:
///
/// ```swift
/// Serial {
///     Apply(.fade, to: .flipper)
///     FlipByItem(.flipper)
/// }
/// ```
public struct Serial: ActionComposable {
    let children: [any ActionComposable]

    /// Creates a serial composition; each line of the block runs after the previous one.
    public init(@ActionCompositionBuilder _ children: () -> [any ActionComposable]) {
        self.children = children()
    }

    init(children: [any ActionComposable]) {
        self.children = children
    }

    /// The sum of the children's structural durations.
    public var structuralDuration: Int {
        children.reduce(0) { $0 + $1.structuralDuration }
    }

    /// Recursively adds this composition to the container.
    public func visit(with container: inout TempActionContainer, structuralStart: Int) {
        container.beginGroup(.serial)
        var start = structuralStart
        for child in children {
            child.visit(with: &container, structuralStart: start)
            start += child.structuralDuration
        }
        container.endGroup()
    }
}

/// Combines two compositions to run at the same time.
public func & (lhs: some ActionComposable, rhs: some ActionComposable) -> Parallel {
    var children = [any ActionComposable]()
    if let parallel = lhs as? Parallel {
        children += parallel.children
    }
    else {
        children.append(lhs)
    }
    if let parallel = rhs as? Parallel {
        children += parallel.children
    }
    else {
        children.append(rhs)
    }
    return Parallel(children: children)
}

public extension ActionComposable {
    /// Runs `next` after this composition completes.
    ///
    /// Binds tighter than `&`, so `A & B.then(C)` runs `A` in parallel with `B → C`.
    func then(_ next: some ActionComposable) -> Serial {
        var children = [any ActionComposable]()
        if let serial = self as? Serial {
            children += serial.children
        }
        else {
            children.append(self)
        }
        if let serial = next as? Serial {
            children += serial.children
        }
        else {
            children.append(next)
        }
        return Serial(children: children)
    }
}
