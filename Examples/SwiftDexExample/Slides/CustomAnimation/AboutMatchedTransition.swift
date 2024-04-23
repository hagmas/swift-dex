import SwiftDex
import SwiftUI

struct AboutMatchedTransition0: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Matched Transition"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            "The **`.matched()`** transition lets you creating seamless animations with **`matchedGeometryEffect`**."
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "hare.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.cyan)
                    .matchID(.init(rawValue: "hare"))
                Spacer()
                Image(systemName: "tortoise.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.green)
                    .matchID(.init(rawValue: "tortoise"))
                Spacer()
                Image(systemName: "lizard.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.pink)
                    .matchID(.init(rawValue: "lizard"))
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AboutMatchedTransition1: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Matched Transition"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            "The **`.matched()`** transition lets you creating seamless animations with **`matchedGeometryEffect`**."
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "tortoise.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.green)
                    .matchID(.init(rawValue: "tortoise"))
                Spacer()
                Image(systemName: "lizard.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.pink)
                    .matchID(.init(rawValue: "lizard"))
                Spacer()
                Image(systemName: "hare.fill")
                    .font(.system(size: 280))
                    .foregroundColor(.cyan)
                    .matchID(.init(rawValue: "hare"))
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview{
    SlidePreview(slide: AboutMatchedTransition1())
}
