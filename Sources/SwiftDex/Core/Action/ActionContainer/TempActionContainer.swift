import Foundation

/// `TempActionContainer` is a struct used by `@ActionContainerBuilder` during the process of generating an `ActionContainer`.
///
/// There is no need to handle instances of it directly.
public struct TempActionContainer {
    /// The kind of a composition group being assembled.
    public enum GroupKind {
        /// Children run one after another.
        case serial
        /// Children run at the same time.
        case parallel
    }

    private struct StructuralSlot: Hashable {
        let key: ClickCountKey
        let start: Int
    }

    private var beats: [TimelineNode] = []
    private var chains: [ElementID: ActionChainCollection] = [:]
    private var occupiedSlots: Set<StructuralSlot> = []
    private var structuralBase = 1

    // Nodes being assembled: the bottom collects the current line's nodes,
    // deeper entries are open Serial/Parallel groups.
    private var groupStack: [(kind: GroupKind, nodes: [TimelineNode])] = []

    /// Adds one builder line: a single action or a `Serial`/`Parallel` composition.
    mutating func addLine(_ component: some ActionComposable) {
        groupStack = [(.parallel, [])]
        component.visit(with: &self, structuralStart: structuralBase)
        let nodes = groupStack.removeLast().nodes
        if let node = nodes.first, nodes.count == 1 {
            beats.append(node)
        }
        else {
            beats.append(.parallel(nodes))
        }
        structuralBase += component.structuralDuration
    }

    /// Adds a leaf action at the given structural position.
    ///
    /// A duplicate of the same element and action type at the same structural
    /// position is ignored, mirroring the previous same-line deduplication.
    public mutating func addLeaf<A: Action>(action: A, structuralStart: Int) {
        let key = ClickCountKey(elementID: action.elementID, actionType: A.self)
        let slot = StructuralSlot(key: key, start: structuralStart)
        guard !occupiedSlots.contains(slot) else {
            return
        }
        occupiedSlots.insert(slot)

        let tagged = TaggedAction(id: ActionID(rawValue: UUID()), action: action)
        chains[action.elementID, default: ActionChainCollection()].append(tagged)
        groupStack[groupStack.count - 1].nodes.append(.action(key, tagged.id))
    }

    /// Opens a composition group; subsequent leaves belong to it until `endGroup()`.
    public mutating func beginGroup(_ kind: GroupKind) {
        groupStack.append((kind, []))
    }

    /// Closes the group opened by the matching `beginGroup(_:)`.
    public mutating func endGroup() {
        let group = groupStack.removeLast()
        let node: TimelineNode =
            switch group.kind {
            case .serial:
                .serial(group.nodes)

            case .parallel:
                .parallel(group.nodes)
            }
        groupStack[groupStack.count - 1].nodes.append(node)
    }

    mutating func finalize() -> ActionContainer {
        ActionContainer(beats: beats, chains: chains)
    }
}
