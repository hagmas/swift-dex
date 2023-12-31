import Foundation

/// `ActionContainer` is a container for storing the `Action`s given to a slide, organized by each `ElementID`.
///
/// It is intended to be instantiated via `@ActionContainerBuilder`, so there is no need to handle instances directly.
public struct ActionContainer {
    private var collections: [ElementID: LinkedActionSequenceCollection]
    private var actionIDs: [Set<ActionID>]

    var capacity: Int {
        actionIDs.count
    }

    init(
        collections: [ElementID: LinkedActionSequenceCollection],
        actionIDs: [Set<ActionID>]
    ) {
        self.collections = collections
        self.actionIDs = actionIDs
    }

    func actionIDs(for step: Int) -> Set<ActionID> {
        guard 0 <= step && step <= step else {
            return .init()
        }
        return actionIDs[step]
    }

    subscript<A: Action>(elementID: ElementID, step: Int) -> ActionSequenceNode<A>? {
        guard let elementID = collections[elementID],
            let nodes = elementID[A.self]
        else {
            return nil
        }
        return nodes[step]
    }
}

extension ActionContainer {
    static var empty: ActionContainer {
        ActionContainer(collections: [:], actionIDs: [])
    }
}

struct LinkedActionSequenceCollection {
    private var sequences: [ActionTypeKey: Any]
    init(sequences: [ActionTypeKey: Any]) {
        self.sequences = sequences
    }

    subscript<A: Action>(_: A.Type) -> [ActionSequenceNode<A>]? {
        guard let nodes = sequences[ActionTypeKey(A.self)] as? [ActionSequenceNode<A>] else {
            return nil
        }
        return nodes
    }
}

struct ActionTypeKey: Hashable {
    private let identifier: ObjectIdentifier

    init<A: Action>(_: A.Type) {
        identifier = ObjectIdentifier(A.self)
    }
}
