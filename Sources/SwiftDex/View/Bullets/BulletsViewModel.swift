import Foundation
import SwiftUI

@Observable
class BulletsViewModel {
    let items: [BulletItem]
    let numberOfItems: Int
    private(set) var step = 0

    init(items: [BulletItem]) {
        self.items = items
        numberOfItems = items.numberOfItems
    }

    var isReachedEnd: Bool {
        step == numberOfItems
    }

    func resetStep() {
        step = 0
    }

    func setLastStep() {
        step = numberOfItems
    }

    func forward() {
        step += 1
    }
}
