import Foundation

struct TaggedAction<A: Action> {
    let id: ActionID
    let action: A
}
