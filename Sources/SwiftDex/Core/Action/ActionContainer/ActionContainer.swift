import Foundation

/// A node of the built action timeline.
indirect enum TimelineNode {
    case action(ClickCountKey, ActionID)
    case serial([TimelineNode])
    case parallel([TimelineNode])
}

/// `ActionContainer` is a container for storing the `Action`s given to a slide.
///
/// It is intended to be instantiated via `@ActionContainerBuilder`, so there is no need to handle instances directly.
///
/// The container is pure structure: a serial list of top-level beats (one per
/// builder line), each an arbitrary `Serial`/`Parallel` composition, plus each
/// element's actions in build order. All timeline math (durations, intervals,
/// progress) lives on `SlideState`, which combines this structure with the
/// click counts registered at render time.
public struct ActionContainer {
    let beats: [TimelineNode]
    let chains: [ElementID: ActionChainCollection]

    /// The number of top-level beats (builder lines).
    var capacity: Int {
        beats.count
    }

    init(
        beats: [TimelineNode],
        chains: [ElementID: ActionChainCollection]
    ) {
        self.beats = beats
        self.chains = chains
    }
}

extension ActionContainer {
    static var empty: ActionContainer {
        ActionContainer(beats: [], chains: [:])
    }
}

/// Identifies the click-count registration for an element and action type.
///
/// All occurrences of the same action type on the same element share one count,
/// because the count always originates from the same view.
struct ClickCountKey: Hashable {
    let elementID: ElementID
    let actionType: ActionTypeKey

    init<A: Action>(elementID: ElementID, actionType: A.Type) {
        self.elementID = elementID
        self.actionType = ActionTypeKey(A.self)
    }
}

/// An element's actions grouped by action type, in build order.
struct ActionChainCollection {
    private var chains: [ActionTypeKey: Any] = [:]

    mutating func append<A: Action>(_ action: TaggedAction<A>) {
        var chain = chains[ActionTypeKey(A.self)] as? [TaggedAction<A>] ?? []
        chain.append(action)
        chains[ActionTypeKey(A.self)] = chain
    }

    subscript<A: Action>(_: A.Type) -> [TaggedAction<A>]? {
        chains[ActionTypeKey(A.self)] as? [TaggedAction<A>]
    }
}

struct ActionTypeKey: Hashable {
    private let identifier: ObjectIdentifier

    init<A: Action>(_: A.Type) {
        identifier = ObjectIdentifier(A.self)
    }
}
