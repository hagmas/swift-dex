import SwiftUI

struct ScaleEffectView<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: () -> Content

    init(size: CGSize, @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let ratio = size.width / size.height
            let proxySize = proxy.size
            let scale =
                proxySize.width > proxySize.height * ratio
                ? proxySize.height / size.height : proxySize.width / size.width
            Color(.clear)
                .overlay(
                    content()
                        .frame(width: size.width, height: size.height)
                        .scaleEffect(
                            CGSize(width: scale, height: scale)
                        )
                )
        }
    }
}
