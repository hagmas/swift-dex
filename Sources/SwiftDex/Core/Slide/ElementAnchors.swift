import SwiftUI

struct ElementAnchorsPreference: PreferenceKey {
    static var defaultValue: [ElementID: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [ElementID: Anchor<CGRect>],
        nextValue: () -> [ElementID: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

class ElementAnchors: ObservableObject {
    private(set) var value: [ElementID: Anchor<CGRect>] = [:]

    func update(value: [ElementID: Anchor<CGRect>]) {
        self.value = value
    }
}
