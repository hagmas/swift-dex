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
/// The container only knows the *structure* of the timeline: a serial list of
/// top-level beats (one per builder line), each an arbitrary `Serial`/`Parallel`
/// composition, plus each element's actions in build order. How many clicks each
/// action consumes is registered at render time and supplied as `clickCounts`.
public struct ActionContainer {
    private var beats: [TimelineNode]
    private var chains: [ElementID: ActionChainCollection]

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

// MARK: - Timeline

extension ActionContainer {
    /// The active span of a single action occurrence on the timeline.
    struct ActionInterval: Equatable {
        /// The first click of the action.
        let start: Int
        /// The number of clicks the action consumes.
        let clicks: Int
        /// The first click after the enclosing top-level beat; the action renders
        /// as completed until then, and as idle afterwards.
        let beatEnd: Int
    }

    /// The number of clicks each top-level beat consumes.
    ///
    /// Serial compositions add up; parallel compositions take the maximum.
    /// Unregistered actions fall back to one click, which keeps the timeline
    /// deadlock-free and matches one-shot actions.
    func beatDurations(clickCounts: [ClickCountKey: Int]) -> [Int] {
        beats.map { max(1, duration(of: $0, clickCounts: clickCounts)) }
    }

    /// The total number of clicks this slide consumes.
    func totalClicks(clickCounts: [ClickCountKey: Int]) -> Int {
        beatDurations(clickCounts: clickCounts).reduce(0, +)
    }

    /// The click at which every beat before `index` has completed.
    ///
    /// `0` is the start of the slide; `capacity` is the end.
    func click(atBoundary index: Int, clickCounts: [ClickCountKey: Int]) -> Int {
        beatDurations(clickCounts: clickCounts).prefix(index).reduce(0, +)
    }

    /// The beat position of a click: `0` before every beat, `i + 1` while beat `i` runs.
    func beatIndex(at click: Int, clickCounts: [ClickCountKey: Int]) -> Int {
        guard click > 0 else {
            return 0
        }
        var start = 1
        for (i, duration) in beatDurations(clickCounts: clickCounts).enumerated() {
            if click < start + duration {
                return i + 1
            }
            start += duration
        }
        return beats.count
    }

    /// Resolves the interval of every action occurrence for the given click counts.
    func intervals(clickCounts: [ClickCountKey: Int]) -> [ActionID: ActionInterval] {
        var result = [ActionID: ActionInterval]()
        var start = 1

        func walk(_ node: TimelineNode, start: Int, beatEnd: Int) {
            switch node {
            case .action(let key, let id):
                result[id] = ActionInterval(
                    start: start,
                    clicks: max(1, clickCounts[key] ?? 1),
                    beatEnd: beatEnd
                )

            case .serial(let children):
                var childStart = start
                for child in children {
                    walk(child, start: childStart, beatEnd: beatEnd)
                    childStart += duration(of: child, clickCounts: clickCounts)
                }

            case .parallel(let children):
                for child in children {
                    walk(child, start: start, beatEnd: beatEnd)
                }
            }
        }

        for beat in beats {
            let duration = max(1, duration(of: beat, clickCounts: clickCounts))
            walk(beat, start: start, beatEnd: start + duration)
            start += duration
        }
        return result
    }

    private func duration(of node: TimelineNode, clickCounts: [ClickCountKey: Int]) -> Int {
        switch node {
        case .action(let key, _):
            max(1, clickCounts[key] ?? 1)

        case .serial(let children):
            children.reduce(0) { $0 + duration(of: $1, clickCounts: clickCounts) }

        case .parallel(let children):
            max(1, children.map { duration(of: $0, clickCounts: clickCounts) }.max() ?? 1)
        }
    }
}

// MARK: - Progress derivation

extension ActionContainer {
    /// Derives the progress of the given element's action of the given type at a click.
    ///
    /// Returns `nil` when the element has no action of that type. Otherwise the
    /// element's occurrences are ordered by their interval starts, and the latest
    /// one at or before the click determines the progress: active within its
    /// interval, completed until its beat ends, idle in between and outside.
    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type,
        at click: Int,
        clickCounts: [ClickCountKey: Int]
    ) -> ActionProgress<A>? {
        guard let chain: [TaggedAction<A>] = chains[elementID]?[A.self], !chain.isEmpty else {
            return nil
        }

        let intervals = intervals(clickCounts: clickCounts)
        let sorted =
            chain
            .compactMap { tagged in intervals[tagged.id].map { (tagged, $0) } }
            .sorted { $0.1.start < $1.1.start }

        guard let index = sorted.lastIndex(where: { $0.1.start <= click }) else {
            return .idle(previous: nil, next: sorted.first?.0.action)
        }

        let (tagged, interval) = sorted[index]
        if click < interval.start + interval.clicks {
            return .active(current: tagged.action, step: click - interval.start + 1)
        }
        if click < interval.beatEnd {
            return .completed(current: tagged.action)
        }
        let next = index + 1 < sorted.count ? sorted[index + 1].0.action : nil
        return .idle(previous: tagged.action, next: next)
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
