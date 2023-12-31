import SwiftUI

struct ScaleEffectView<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let ratio: CGFloat = width / height
            let size = proxy.size
            let scale = size.width > size.height * ratio ? size.height / height : size.width / width
            Color(.clear)
                .overlay(
                    content()
                        .frame(width: width, height: height)
                        .scaleEffect(
                            CGSize(width: scale, height: scale)
                        )
                )
        }
    }
}
