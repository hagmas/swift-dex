import SwiftUI

/// `DeckPreview` is a View that displays all the Slides in a Deck in a list format.
///
/// Use it with the `#Preview` macro.
public struct DeckPreview<T: Deck>: View {
    private let deck: T
    @Bindable private var viewModel: DeckPreviewViewModel

    /// Initializes a `DeckPreview` view for a given deck.
    ///
    /// This initializer creates a preview for the entire deck, setting up a `DeckPreviewViewModel` based on the deck's flow. The viewModel manages the state and navigation through the slides within the deck preview.
    ///
    /// - Parameter deck: The deck of type `T` whose slides are to be previewed.
    public init(deck: T) {
        self.deck = deck
        let flow = deck.flow.flatten()
        viewModel = DeckPreviewViewModel(flow: flow)
    }

    /// The body of the `DeckPreview` view.
    @ViewBuilder
    public var body: some View {
        NavigationSplitView {
            List(
                0..<viewModel.numberOfSlides,
                id: \.self,
                selection: $viewModel.slideNumber
            ) {
                listRow(index: $0)
            }
        } detail: {
            DeckView(deck: deck, slideNumberBinding: $viewModel.slideNumber)
        }
    }
}

private extension DeckPreview {
    @MainActor func listRow(index: Int) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text(String(format: "%2d", index))
                .font(.system(.body, design: .monospaced))
            if let image = image(slideNumber: index) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .cornerRadius(4.0)
            }
            else {
                Color(.gray)
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .cornerRadius(4.0)
            }
        }
        .padding(4)
    }

    @MainActor func image(slideNumber: Int) -> NSImage? {
        if let image = viewModel.imageCache[slideNumber] {
            return image
        }
        let renderer = ImageRenderer(
            content: staticContent(slideNumber: slideNumber)
        )

        if let image = renderer.nsImage {
            viewModel.imageCache[slideNumber] = image
            return image
        }

        return nil
    }

    func staticContent(slideNumber: Int) -> some View {
        ScaleEffectView(width: 1920, height: 1080) {
            viewModel.flow[slideNumber].0.createStaticView()
                .background {
                    Color(T.deckStyle.colorStyle.backgroundColor)
                }
                .environmentObject(EventDispatcher())
                .environment(\.fontStyle, T.deckStyle.fontStyle.self)
                .environment(\.colorStyle, T.deckStyle.colorStyle.self)
        }
        .frame(width: 192 * 3, height: 108 * 3)
    }
}
