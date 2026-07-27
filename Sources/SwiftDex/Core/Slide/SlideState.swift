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

struct SlideState: Equatable {
    var position: SlidePosition
    var clickCounts: [ClickCountKey: Int] = [:]
    var latestUserOperation: UserOperation?

    init(position: SlidePosition = .click(0)) {
        self.position = position
    }

    mutating func register(clicks: Int, for key: ClickCountKey) {
        clickCounts[key] = clicks
    }
}
