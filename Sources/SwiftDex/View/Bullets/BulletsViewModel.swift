import Foundation
import SwiftUI

class BulletsViewModel: ObservableObject {
    let items: [BulletItem]
    let numberOfItems: Int
    @Published
    private(set) var step = 0

    init(items: [BulletItem]) {
        self.items = items
        if let lastItemIndex = items.last?.lastItemIndex {
            numberOfItems = lastItemIndex + 1
        }
        else {
            numberOfItems = 0
        }
    }

    var isReachedEnd: Bool {
        step == numberOfItems - 1
    }

    func resetStep() {
        step = 0
    }

    func setLastStep() {
        step = numberOfItems - 1
    }

    func forward() {
        step += 1
    }
}
