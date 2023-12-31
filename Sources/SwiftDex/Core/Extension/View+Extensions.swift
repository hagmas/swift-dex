import SwiftUI

extension View {
    func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        self
            .modifier(FirstAppearModifier(action: action))
    }
}

private struct FirstAppearModifier: ViewModifier {
    @State var isFirst: Bool = true
    var action: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isFirst {
                    action?()
                    isFirst = false
                }
            }
    }
}
