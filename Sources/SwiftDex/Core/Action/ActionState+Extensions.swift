import SwiftUI

public extension ActionState {
    /// The action to be executed at the current step, or `nil` if the state is `.static`.
    var current: A? {
        switch self {
        case .static:
            nil

        case .activated(let value):
            value.current

        case .deactivated(let value):
            value.current
        }
    }

    /// The action executed at a previous step, if any.
    var previous: A? {
        switch self {
        case .static(let value):
            value.previous

        case .activated(let value):
            value.previous

        case .deactivated(let value):
            value.previous
        }
    }

    /// The action to be executed at a later step, if any.
    var next: A? {
        switch self {
        case .static(let value):
            value.next

        case .activated(let value):
            value.next

        case .deactivated(let value):
            value.next
        }
    }
}
