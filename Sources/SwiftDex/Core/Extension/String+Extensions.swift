import SwiftUI

public extension String {
    func elementID(_ elemenetID: ElementID) -> some View {
        Text(self)
            .elementID(elemenetID)
    }
}
