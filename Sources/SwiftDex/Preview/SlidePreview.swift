import SwiftUI

/// `SlidePreview` is a View that displays all the steps in a Slide in a list format.
///
/// Use it with the `#Preview` macro.
public struct SlidePreview<T: Slide, S: DeckStyle>: View {
    private let slide: T
    private let deckStyle: S.Type
    @Bindable private var viewModel: SlidePreviewViewModel

    /// Initialize a `SlidePreview` view for a given slide and deck style.
    ///
    /// This initializer sets up the preview for a specific slide, along with an optional custom deck style.
    /// It creates a `SlidePreviewViewModel` based on the action container of the slide, which manages the actions and state transitions within the slide preview.
    ///
    /// - Parameters:
    ///   - slide: The specific slide of type `T` to be previewed.
    ///   - deckStyle: The deck style of type `S` to be applied to the slide preview. Defaults to `DefaultDeckStyle` if not specified.
    public init(
        slide: T,
        deckStyle: S.Type = DefaultDeckStyle.self
    ) {
        self.slide = slide
        self.viewModel = SlidePreviewViewModel(actionContainer: slide.actionContainer)
        self.deckStyle = deckStyle
    }

    /// The body of the `SlidePreview` view.
    public var body: some View {
        NavigationSplitView {
            GeometryReader { geometry in
                List(0..<numberOfSteps + 1, id: \.self, selection: selection) { index in
                    listRow(index: index)
                }
            }
        } detail: {
            content
                .environment(\.fontStyle, deckStyle.fontStyle.self)
                .environment(\.colorStyle, deckStyle.colorStyle.self)
                .environment(\.slideSize, deckStyle.slideSize)
        }
    }
}

private extension SlidePreview {
    var selection: Binding<Int> {
        Binding {
            viewModel.state.currentBeatIndex
        } set: { newValue in
            viewModel.randomAccess(boundary: newValue)
        }
    }

    var numberOfSteps: Int {
        viewModel.state.actionContainer.capacity
    }

    var content: some View {
        ScaleEffectView(size: deckStyle.slideSize) {
            TapHandlerView(isEnabled: true) {
                SlideView(
                    slide: slide,
                    state: $viewModel.state
                )
                .background {
                    Color(deckStyle.colorStyle.backgroundColor)
                }
            } onLeftTap: {
                viewModel.backward()
            } onRightTap: {
                viewModel.forward()
            }
        }
    }

    @MainActor func listRow(index: Int) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            Text(String(format: "%2d", index))
                .font(.system(.body, design: .monospaced))
            if let image = image(stepNumber: index) {
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

    @MainActor func image(stepNumber: Int) -> NSImage? {
        if let image = viewModel.imageCache[stepNumber] {
            return image
        }
        let renderer = ImageRenderer(
            content: staticContent(step: stepNumber)
        )

        if let image = renderer.nsImage {
            viewModel.imageCache[stepNumber] = image
            return image
        }

        return nil
    }

    func staticContent(step: Int) -> some View {
        let size = deckStyle.slideSize
        return ScaleEffectView(size: size) {
            SlideView(
                slide: slide,
                step: step
            )
            .background {
                Color(deckStyle.colorStyle.backgroundColor)
            }
            .environment(\.fontStyle, deckStyle.fontStyle.self)
            .environment(\.colorStyle, deckStyle.colorStyle.self)
            .environment(\.slideSize, size)
            .environment(\.isStaticRendering, true)
        }
        .frame(width: 192 * 3, height: 108 * 3)
    }
}
