import Foundation
import SwiftUI

/// `Flow` is a protocol for specifying the sequence of slides and information about transitions.
///
/// The sequence of slides can be created using the `.next` function.
///
/// Isolated to the main actor, which `Slide` inherits rather than restating:
/// describing a deck is view-building work. A flow could not be put to use off
/// the main actor in any case, since a slide reached through one keeps its
/// `content` behind the same isolation.
@MainActor
public protocol Flow {
    func flatten() -> [(any Slide, SlideTransition)]
}

public extension Flow {
    func next<T>(
        _ element: T,
        transition: SlideTransition = .none
    ) -> some Flow where T: Flow {
        SubFlow(self, element, transition: transition)
    }
}
