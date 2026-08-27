import Foundation

/// A position on a slide's click timeline.
enum SlidePosition: Equatable {
    /// A concrete click index; `0` means nothing has run yet.
    case click(Int)

    /// The end of the slide, before the total click count is known.
    ///
    /// Used when entering a slide backward: the concrete index can only be
    /// resolved once the slide has rendered and click counts are registered.
    case end

    func resolved(total: Int) -> Int {
        switch self {
        case .click(let click):
            min(click, total)

        case .end:
            total
        }
    }
}

/// The complete interaction state of one slide.
///
/// The action container is the immutable timeline structure the position lives on;
/// `clickCounts` is the registry of how many clicks each action consumes, reported
/// by `ActionReader`s at render time. Everything else is derived.
struct SlideState {
    /// The timeline structure of the slide.
    ///
    /// Constant for the state's lifetime.
    let actionContainer: ActionContainer

    var position: SlidePosition
    var clickCounts: [ClickCountKey: Int] = [:]
    var latestUserOperation: UserOperation?

    /// The presenter's own movement of the camera, if any.
    ///
    /// Held raw: whether it still applies is decided by the timeline, in
    /// `effectiveCameraOverride`.
    var cameraOverride: CameraOverride?

    init(
        actionContainer: ActionContainer = .empty,
        position: SlidePosition = .click(0)
    ) {
        self.actionContainer = actionContainer
        self.position = position
    }

    mutating func register(clicks: Int, for key: ClickCountKey) {
        clickCounts[key] = clicks
    }
}

extension SlideState: Equatable {
    // The action container is constant for the state's lifetime, so equality is
    // defined by the mutable parts only.
    static func == (lhs: SlideState, rhs: SlideState) -> Bool {
        lhs.position == rhs.position
            && lhs.clickCounts == rhs.clickCounts
            && lhs.latestUserOperation == rhs.latestUserOperation
            && lhs.cameraOverride == rhs.cameraOverride
    }
}

// MARK: - Timeline

extension SlideState {
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
    var beatDurations: [Int] {
        actionContainer.beats.map { max(1, duration(of: $0)) }
    }

    /// The total number of clicks this slide consumes, given current registrations.
    var totalClicks: Int {
        beatDurations.reduce(0, +)
    }

    /// The resolved click index of the current position.
    var currentClick: Int {
        position.resolved(total: totalClicks)
    }

    /// The beat position of the current click: `0` before every beat, `i + 1` while beat `i` runs.
    var currentBeatIndex: Int {
        beatIndex(at: currentClick)
    }

    /// The beat position of a click.
    func beatIndex(at click: Int) -> Int {
        guard click > 0 else {
            return 0
        }
        var start = 1
        for (i, duration) in beatDurations.enumerated() {
            if click < start + duration {
                return i + 1
            }
            start += duration
        }
        return actionContainer.beats.count
    }

    /// The click at which every beat before `index` has completed.
    func click(atBoundary index: Int) -> Int {
        beatDurations.prefix(index).reduce(0, +)
    }

    /// Resolves the interval of every action occurrence.
    func intervals() -> [ActionID: ActionInterval] {
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
                    childStart += duration(of: child)
                }

            case .parallel(let children):
                for child in children {
                    walk(child, start: start, beatEnd: beatEnd)
                }
            }
        }

        for beat in actionContainer.beats {
            let duration = max(1, duration(of: beat))
            walk(beat, start: start, beatEnd: start + duration)
            start += duration
        }
        return result
    }

    /// Derives the progress of the given element's action of the given type.
    ///
    /// Returns `nil` when the element has no action of that type. Otherwise the
    /// element's occurrences are ordered by their interval starts, and the latest
    /// one at or before the current click determines the progress: active within
    /// its interval, completed until its beat ends, idle in between and outside.
    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        guard let chain: [TaggedAction<A>] = actionContainer.chains[elementID]?[A.self],
            !chain.isEmpty
        else {
            return nil
        }

        let click = currentClick
        let intervals = intervals()
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

    /// Every occurrence of the given element's action of the given type that has
    /// started at or before the current click, in timeline order.
    ///
    /// `actionProgress(for:type:)` answers what an action is doing now, which is
    /// all a view needs when each occurrence stands on its own. An action whose
    /// occurrences build on one another — the camera, where a pan is relative
    /// to the operation before it — needs the sequence instead.
    func actionHistory<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> [A] {
        guard let chain: [TaggedAction<A>] = actionContainer.chains[elementID]?[A.self] else {
            return []
        }

        let click = currentClick
        let intervals = intervals()
        return
            chain
            .enumerated()
            .compactMap { order, tagged in
                intervals[tagged.id].map { (tagged.action, $0.start, order) }
            }
            .filter { $0.1 <= click }
            // Build order breaks ties so the fold is deterministic, even though
            // distinct structural positions cannot currently share a click.
            .sorted { ($0.1, $0.2) < ($1.1, $1.2) }
            .map { $0.0 }
    }

    /// The click the most recently started occurrence of `A` began on, or `0`
    /// when none has started.
    func latestActionStart<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> Int {
        guard let chain: [TaggedAction<A>] = actionContainer.chains[elementID]?[A.self] else {
            return 0
        }

        let click = currentClick
        let intervals = intervals()
        return
            chain
            .compactMap { intervals[$0.id]?.start }
            .filter { $0 <= click }
            .max() ?? 0
    }

    /// The presenter's camera movement, if the timeline has not overruled it.
    ///
    /// A `Camera` action that started after the movement did is the slide
    /// taking the camera back, so the movement is dropped. Deciding this by
    /// comparing clicks rather than by reacting to the action keeps it a pure
    /// function: a mirrored surface reaches the same answer without being told,
    /// and the composite rectangle animates from wherever the presenter left it
    /// to wherever the action points, because only one value changed.
    var effectiveCameraOverride: CameraOverride? {
        guard let override = cameraOverride else {
            return nil
        }
        return latestActionStart(for: .none, type: Camera.self) > override.anchorClick
            ? nil : override
    }

    private func duration(of node: TimelineNode) -> Int {
        switch node {
        case .action(let key, _):
            max(1, clickCounts[key] ?? 1)

        case .serial(let children):
            children.reduce(0) { $0 + duration(of: $1) }

        case .parallel(let children):
            max(1, children.map { duration(of: $0) }.max() ?? 1)
        }
    }
}
