import SwiftUI

/// Reports each overview cell's bounds so the deck surface can dock the live
/// presentation layer onto the current slide's cell.
struct OverviewCellAnchorsKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [Int: Anchor<CGRect>],
        nextValue: () -> [Int: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { $1 }
    }
}

/// The grid overview presented on a deck surface.
///
/// Shows every slide as a thumbnail; tapping one reports the selection to the
/// deck surface, which jumps there and dismisses the overview. Thumbnails are
/// rendered lazily with `ImageRenderer` and cached.
struct DeckOverviewView<T: Deck>: View {
    let controller: DeckController
    let onSelect: (Int) -> Void

    @State private var thumbnails = [Int: NSImage]()

    private let columns = [GridItem](
        repeating: GridItem(.flexible(), spacing: 48),
        count: 4
    )

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 48) {
                    ForEach(0..<controller.slideCount, id: \.self) { index in
                        cell(index: index)
                            .id(index)
                    }
                }
                .padding(64)
            }
            .onAppear {
                proxy.scrollTo(controller.slideNumber, anchor: .center)
            }
            .onChange(of: controller.slideNumber) { _, newValue in
                withAnimation(.spring(duration: 0.35)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .background(
            Color(T.deckStyle.colorStyle.backgroundColor).opacity(0.92)
        )
    }
}

private extension DeckOverviewView {
    @MainActor
    func cell(index: Int) -> some View {
        Button {
            onSelect(index)
        } label: {
            Group {
                if let image = thumbnail(index: index) {
                    Image(nsImage: image)
                        .resizable()
                }
                else {
                    Color.gray
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        index == controller.slideNumber
                            ? Color.accentColor : Color.primary.opacity(0.15),
                        lineWidth: index == controller.slideNumber ? 6 : 1
                    )
            }
            .overlay(alignment: .bottomLeading) {
                Text("\(index + 1)")
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(10)
            }
            .shadow(radius: 8, y: 4)
            .anchorPreference(key: OverviewCellAnchorsKey.self, value: .bounds) {
                [index: $0]
            }
        }
        .buttonStyle(.plain)
    }

    @MainActor
    func thumbnail(index: Int) -> NSImage? {
        if let image = thumbnails[index] {
            return image
        }

        let renderer = ImageRenderer(
            content: ScaleEffectView(width: 1920, height: 1080) {
                controller.flow[index].0.createStaticView()
                    .background {
                        Color(T.deckStyle.colorStyle.backgroundColor)
                    }
                    .environment(\.fontStyle, T.deckStyle.fontStyle.self)
                    .environment(\.colorStyle, T.deckStyle.colorStyle.self)
            }
            .frame(width: 192 * 3, height: 108 * 3)
        )

        guard let image = renderer.nsImage else {
            return nil
        }
        thumbnails[index] = image
        return image
    }
}
