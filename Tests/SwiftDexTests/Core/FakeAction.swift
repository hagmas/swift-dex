import Foundation
import SwiftDex

struct FakeAction: Action, Equatable {
    let elementID: ElementID
}

struct FakeAction1: Action, Equatable {
    let elementID: ElementID
}

struct FakeAction2: Action, Equatable {
    let id: String
    let elementID: ElementID

    init(id: String = "", elementID: ElementID) {
        self.id = id
        self.elementID = elementID
    }
}
