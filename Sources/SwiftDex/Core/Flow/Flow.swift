import Foundation
import SwiftUI

/// `Flow` is a struct for specifying the sequence of slides and information about transitions.
///
/// The sequence of slides can be created using the `.next` function.
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
