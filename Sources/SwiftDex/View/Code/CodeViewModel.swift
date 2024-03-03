import SwiftUI

@Observable
class CodeViewModel {
    let fitWidthToParent: Bool
    let isScrollViewEnabled: Bool
    private var contentSize: CGSize? = nil
    private var parentSize: CGSize? = nil
    private(set) var idealSize: CGSize? = nil
    private(set) var ratio: CGFloat = 1.0

    init(fitWidthToParent: Bool, isScrollViewEnabled: Bool) {
        self.fitWidthToParent = fitWidthToParent
        self.isScrollViewEnabled = isScrollViewEnabled
    }

    func set(contentSize: CGSize) {
        self.contentSize = contentSize
        calculate()
    }

    func set(parentSize: CGSize) {
        self.parentSize = parentSize
        calculate()
    }

    var scrollViewAxes: Axis.Set {
        if fitWidthToParent {
            [.vertical]
        }
        else {
            [.vertical, .horizontal]
        }
    }
}

private extension CodeViewModel {
    func calculate() {
        guard let contentSize, let parentSize else {
            return
        }

        if fitWidthToParent {
            let ratio = parentSize.width / contentSize.width
            idealSize = CGSize(width: parentSize.width, height: contentSize.height * ratio)
            self.ratio = ratio
        }
        else {
            idealSize = contentSize
        }
    }
}
