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

extension SlideState {
    /// The total number of clicks this slide consumes, given current registrations.
    var totalClicks: Int {
        actionContainer.totalClicks(clickCounts: clickCounts)
    }

    /// The resolved click index of the current position.
    var currentClick: Int {
        position.resolved(total: totalClicks)
    }

    /// The beat position of the current click: `0` before every beat, `i + 1` while beat `i` runs.
    var currentBeatIndex: Int {
        actionContainer.beatIndex(at: currentClick, clickCounts: clickCounts)
    }

    /// The click at which every beat before `index` has completed.
    func click(atBoundary index: Int) -> Int {
        actionContainer.click(atBoundary: index, clickCounts: clickCounts)
    }

    /// Derives the progress of the given element's action of the given type.
    func actionProgress<A: Action>(
        for elementID: ElementID,
        type: A.Type
    ) -> ActionProgress<A>? {
        actionContainer.actionProgress(
            for: elementID,
            type: type,
            at: currentClick,
            clickCounts: clickCounts
        )
    }
}

extension SlideState: Equatable {
    // The action container is constant for the state's lifetime, so equality is
    // defined by the mutable parts only.
    static func == (lhs: SlideState, rhs: SlideState) -> Bool {
        lhs.position == rhs.position
            && lhs.clickCounts == rhs.clickCounts
            && lhs.latestUserOperation == rhs.latestUserOperation
    }
}
