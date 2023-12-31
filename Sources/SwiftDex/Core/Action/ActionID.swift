import Foundation

/// `ActionID` is an identifier automatically assigned to each `Action` within an `ActionContainer`.
///
/// Each View is responsible for notifying the `SlideViewModel` after executing an action, and this `ActionID` is used for that purpose.
public struct ActionID: Hashable {
    /// A `String` representation of the `ActionID`.
    public let rawValue: UUID

    /// Create a new instance.
    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }
}
