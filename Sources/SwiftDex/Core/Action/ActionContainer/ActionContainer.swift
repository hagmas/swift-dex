import Foundation

/// `ActionContainer` is a container for storing the `Action`s given to a slide, organized by each `ElementID`.
///
/// It is intended to be instantiated via `@ActionContainerBuilder`, so there is no need to handle instances directly.
///
/// The container only knows the *structure* of the timeline (which actions run on which line,
/// and in what order per element). How many clicks each action consumes is registered at
/// render time by `ActionReader` and supplied to the timeline methods as `clickCounts`.
public struct ActionContainer {
    private var collections: [ElementID: LinkedActionSequenceCollection]
    private var actionIDs: [Set<ActionID>]
    private var lineActions: [[ClickCountKey]]

    var capacity: Int {
        actionIDs.count
    }

    init(
        collections: [ElementID: LinkedActionSequenceCollection],
        actionIDs: [Set<ActionID>],
        lineActions: [[ClickCountKey]]
    ) {
        self.collections = collections
        self.actionIDs = actionIDs
        self.lineActions = lineActions
    }

    func actionIDs(for step: Int) -> Set<ActionID> {
        guard 0 <= step && step <= actionIDs.count - 1 else {
            return .init()
        }
        return actionIDs[step]
    }

    subscript<A: Action>(elementID: ElementID, index: Int) -> ActionSequenceNode<A>? {
        guard let elementID = collections[elementID],
            let nodes = elementID[A.self],
            0 <= index && index < nodes.count
        else {
            return nil
        }
        return nodes[index]
    }
}

// MARK: - Timeline

extension ActionContainer {
    /// A position on the slide timeline.
    ///
    /// `index` addresses the sequence nodes: `0` is before every line, and `i + 1` is line `i`.
    /// `offset` is the number of clicks spent inside the current line, starting at `0`.
    struct TimelinePosition: Equatable {
        let index: Int
        let offset: Int
    }

    /// The number of clicks each line consumes: the maximum click count over its actions.
    ///
    /// Unregistered actions fall back to one click, which both keeps the timeline
    /// deadlock-free and matches one-shot actions.
    func lineDurations(clickCounts: [ClickCountKey: Int]) -> [Int] {
        lineActions.map { line in
            max(1, line.map { clickCounts[$0] ?? 1 }.max() ?? 1)
        }
    }

    /// The total number of clicks this slide consumes.
    func totalClicks(clickCounts: [ClickCountKey: Int]) -> Int {
        lineDurations(clickCounts: clickCounts).reduce(0, +)
    }

    /// Resolves a click index into a timeline position.
    func position(at click: Int, clickCounts: [ClickCountKey: Int]) -> TimelinePosition {
        guard click > 0 else {
            return TimelinePosition(index: 0, offset: 0)
        }

        var start = 1
        for (i, duration) in lineDurations(clickCounts: clickCounts).enumerated() {
            if click < start + duration {
                return TimelinePosition(index: i + 1, offset: click - start)
            }
            start += duration
        }
        // Past the end of the timeline: everything is completed.
        return TimelinePosition(index: lineActions.count, offset: .max)
    }

    /// The click at which every line before `index` has completed.
    ///
    /// `0` is the start of the slide; `capacity` is the end.
    func click(atBoundary index: Int, clickCounts: [ClickCountKey: Int]) -> Int {
        lineDurations(clickCounts: clickCounts).prefix(index).reduce(0, +)
    }
}

extension ActionContainer {
    static var empty: ActionContainer {
        ActionContainer(collections: [:], actionIDs: [], lineActions: [])
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

    init(elementID: ElementID, actionType: ActionTypeKey) {
        self.elementID = elementID
        self.actionType = actionType
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
