import SwiftUI

/// `DeckPreview` is a View that displays all the Slides in a Deck in a list format.
///
/// Use it with the `#Preview` macro.
public struct DeckPreview<T: Deck>: View {
    private let deck: T
    @State private var controller: DeckController

    /// Initializes a `DeckPreview` view for a given deck.
    ///
    /// This initializer creates a preview for the entire deck. Selecting a slide
    /// in the sidebar jumps the presentation to it, and advancing the
    /// presentation follows in the sidebar.
    ///
    /// - Parameter deck: The deck of type `T` whose slides are to be previewed.
    public init(deck: T) {
        self.deck = deck
        self._controller = State(initialValue: DeckController(deck: deck))
    }

    /// The body of the `DeckPreview` view.
    @ViewBuilder
    public var body: some View {
        NavigationSplitView {
            List(
                0..<controller.slideCount,
                id: \.self,
                selection: selection
            ) {
                listRow(index: $0)
            }
        } detail: {
            DeckView(deck: deck, controller: controller)
        }
    }
}

extension DeckPreview {
    private var selection: Binding<Int?> {
        Binding(
            get: { controller.slideNumber },
            set: { newValue in
                if let newValue {
                    controller.randomAccess(slideNumber: newValue)
                }
            }
        )
    }

    @MainActor private func listRow(index: Int) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text(String(format: "%2d", index))
                .font(.system(.body, design: .monospaced))
            if let image = controller.thumbnails[index] {
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
}
