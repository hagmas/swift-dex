import Foundation

enum ActionSequenceNode<A: Action> {
    struct Static {
        let previous: TaggedAction<A>?
        let next: TaggedAction<A>?
    }

    struct Dynamic {
        let preivous: TaggedAction<A>?
        let current: TaggedAction<A>
        let next: TaggedAction<A>?
    }

    case `static`(Static)
    case dynamic(Dynamic)
}
