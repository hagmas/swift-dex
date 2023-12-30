import SwiftUI

extension View {
    func apply(_ value: ElementModifier) -> some View {
        self
            .modifier(ElementViewModifier(elementModifier: value))
    }
}
