import Foundation

struct SlideState: Equatable {
    var step: Int
    var activeActionIDs = Set<ActionID>()
    var latestUserOperation: UserOperation?

    mutating func activate(actionIDs: Set<ActionID>) {
        activeActionIDs.removeAll()
        activeActionIDs.formUnion(actionIDs)
    }

    mutating func deactivate(actionID: ActionID) {
        activeActionIDs.remove(actionID)
    }

    var isActive: Bool {
        !activeActionIDs.isEmpty
    }
}
