import Foundation
import SwiftUI

struct SubFlow<Previous, Current>: Flow where Previous: Flow, Current: Flow {
    let previous: Previous?
    let current: Current
    let transition: SlideTransition?

    init(
        _ previous: Previous?,
        _ current: Current,
        transition: SlideTransition
    ) {
        self.previous = previous
        self.current = current
        self.transition = transition
    }
}

extension SubFlow {
    func flatten() -> [(any Slide, SlideTransition)] {
        let previous = previous?.flatten() ?? []
        var current = current.flatten()
        current[0] = (current[0].0, transition ?? .none)
        return previous + current
    }
}
