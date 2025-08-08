import Foundation
import SwiftUI

@Observable
class FlipperViewModel {
    let numberOfItems: Int
    private(set) var step = 0

    init(numberOfItems: Int) {
        self.numberOfItems = numberOfItems
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
