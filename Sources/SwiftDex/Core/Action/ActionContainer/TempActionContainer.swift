import Foundation

/// `TempActionContainer` is a struct used by `@ActionContainerBuilder` during the process of generating an `ActionContainer`.
///
/// There is no need to handle instances of it directly.
public struct TempActionContainer {
    private var collections: [ElementID: ActionSequenceCollection] = [:]
    private var actionIDs: [Set<ActionID>] = [.init()]

    mutating func increaseCapacity() {
        actionIDs.append(.init())
    }

    mutating func add<A: Action>(action: A) {
        var sequenceCollection = collections[action.elementID, default: .init()]
        let actionID = ActionID(rawValue: UUID())
        let taggedAction = TaggedAction(id: actionID, action: action)
        guard sequenceCollection.add(step: currentStep, action: taggedAction) else {
            return
        }
        collections[action.elementID] = sequenceCollection
        actionIDs[actionIDs.count - 1].insert(actionID)
    }

    mutating func finalize() -> ActionContainer {
        var result = [ElementID: LinkedActionSequenceCollection]()
        for elementID in collections.keys {
            var collection = collections[elementID]
            if let collection = collection?.finalize(for: actionIDs.count) {
                result[elementID] = collection
            }
        }
        return ActionContainer(collections: result, actionIDs: actionIDs)
    }
}

private extension TempActionContainer {
    var capacity: Int {
        actionIDs.count
    }

    var currentStep: Int {
        capacity - 1
    }
}

private struct ActionSequenceCollection {
    private var sequences: [ActionTypeKey: Any] = [:]

    mutating func add<A: Action>(step: Int, action: TaggedAction<A>) -> Bool {
        let actionTypeKey = ActionTypeKey(A.self)

        var sequence = sequences[actionTypeKey] as? ActionSequence<A> ?? .init()
        guard sequence.add(step: step, action: action) else {
            return false
        }
        sequences[actionTypeKey] = sequence
        return true
    }

    mutating func finalize(for capacity: Int) -> LinkedActionSequenceCollection {
        var result = [ActionTypeKey: Any]()
        for key in sequences.keys {
            if var container = sequences[key] as? ActionSequenceNodeContainer {
                result[key] = container.finalize(for: capacity)
            }
        }
        return LinkedActionSequenceCollection(sequences: result)
    }
}

private protocol ActionSequenceNodeContainer {
    mutating func finalize(for capacity: Int) -> Any
}

private struct ActionSequence<A: Action>: ActionSequenceNodeContainer {
    private var actions = [Int: TaggedAction<A>]()

    mutating func add(step: Int, action: TaggedAction<A>) -> Bool {
        guard actions[step] == nil else {
            return false
        }
        actions[step] = action
        return true
    }

    mutating func finalize(for capacity: Int) -> Any {
        var result = [ActionSequenceNode<A>]()

        var previous: TaggedAction<A>?
        var previousStep = -2
        let sortedSteps = actions.keys.sorted()
        for (i, step) in sortedSteps.enumerated() {
            guard let current = actions[step] else {
                continue
            }
            if step - previousStep > 1 {
                let newStaticNode = ActionSequenceNode.Static(
                    previous: previous,
                    next: current
                )
                let nodes = Array(
                    repeating: newStaticNode,
                    count: step - previousStep - 1
                )
                result += nodes.map { .static($0) }
            }

            var next: TaggedAction<A>?
            if i + 1 < actions.count {
                next = actions[sortedSteps[i + 1]]
            }
            let newDynamicNode = ActionSequenceNode.Dynamic(
                previous: previous,
                current: current,
                next: next
            )
            result.append(.dynamic(newDynamicNode))

            previous = current
            previousStep = step
        }

        if capacity - 1 > previousStep {
            let newStaticNode = ActionSequenceNode.Static(
                previous: previous,
                next: nil
            )
            let newNodes = Array(
                repeating: newStaticNode,
                count: capacity - 1 - previousStep
            )
            result += newNodes.map { .static($0) }
        }

        return result
    }
}
