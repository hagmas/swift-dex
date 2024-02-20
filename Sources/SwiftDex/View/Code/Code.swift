import Splash
import SwiftUI

/// A view that displays code with syntax highlighting.
///
/// This view takes in raw code as a string and applies syntax highlighting based on the specified `XcodeTheme`.
/// It supports displaying the code in a scrollable view.
public struct Code: View {
    private let theme: XcodeTheme
    private let lineGroup: LineGroup
    private var viewModel: CodeViewModel

    /// Initializes a `Code` view with the specified theme and code string.
    ///
    /// - Parameters:
    ///   - theme: The `XcodeTheme` to be used for syntax highlighting. Defaults to `BasicTheme` if not specified.
    ///   - fitWidthToParent: A Boolean indicating whether the content should scale to fit the parent view's width. When `true`, the view expands as much as possible in the parent view; otherwise, it sizes according to the content.
    ///   - isScrollViewEnabled: A Boolean indicating if the content is placed on a `ScrollView`.
    ///   - code: The raw code string to be displayed and highlighted.
    public init(
        theme: XcodeTheme = BasicTheme(),
        fitWidthToParent: Bool = false,
        isScrollViewEnabled: Bool = false,
        code: String
    ) {
        self.theme = theme
        let grammer = SwiftGrammar()
        let syntaxHighlighter = SyntaxHighlighter(
            format: CodeOutputFormat(),
            grammar: grammer
        )
        self.lineGroup = syntaxHighlighter.highlight(code)
        viewModel = CodeViewModel(
            fitWidthToParent: fitWidthToParent,
            isScrollViewEnabled: isScrollViewEnabled
        )
    }

    /// The content of the view.
    @ViewBuilder
    public var body: some View {
        if viewModel.isScrollViewEnabled {
            ScrollView(viewModel.scrollViewAxes) {
                idealSizedContent
            }
        } else {
            idealSizedContent
        }
    }
}

private extension Code {
    @ViewBuilder
    var idealSizedContent: some View {
        if let idealSize = viewModel.idealSize {
            content
                .frame(width: idealSize.width, height: idealSize.height)
        } else {
            content
        }
    }
    
    private var content: some View {
        GeometryReader { proxy in
            Color.clear
                .overlay {
                    LineGroupView(theme: theme, lineGroup: lineGroup)
                        .font(.system(size: 36, weight: .regular, design: .monospaced))
                        .padding(24)
                        .background(
                            theme.background
                        )
                        .scaleEffect(CGSize(width: viewModel.ratio, height: viewModel.ratio), anchor: .center)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: ContentSizePreference.self, value: proxy.size)
                                    .onPreferenceChange(ContentSizePreference.self) { value in
                                        viewModel.set(contentSize: value)
                                    }
                            }
                        )
                }
                .preference(key: ParentSizePreference.self, value: proxy.size)
                .onPreferenceChange(ParentSizePreference.self) { value in
                    viewModel.set(parentSize: value)
                }
        }
    }
}

private struct LineGroupView: View {
    let theme: XcodeTheme
    let lineGroup: LineGroup

    @ViewBuilder
    var body: some View {
        let elements = lineGroup.elements
        VStack(alignment: .leading) {
            ForEach(0..<elements.endIndex, id: \.self) { i in
                let element = elements[i]
                switch element {
                case .singleLine(let elements):
                    LineView(theme: theme, elements: elements)

                case .lineGroup(let group):
                    LineGroupView(theme: theme, lineGroup: group)
                }
            }
        }
        .fixedSize()
    }
}

private struct LineView: View {
    let theme: XcodeTheme
    let elements: [HorizontalElement]

    @ViewBuilder
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<elements.endIndex, id: \.self) { j in
                let element = elements[j]
                switch element {
                case .token(let text, let tokenType):
                    Text(.init(text))
                        .foregroundStyle(theme.color(for: tokenType))

                case .plainText(let text):
                    Text(.init(text))
                        .foregroundStyle(theme.plainText)

                case .whiteSpace(let text):
                    Text(.init(text))
                }
            }
        }
    }
}

private extension XcodeTheme {
    func color(for token: TokenType) -> SwiftUI.Color {
        switch token {
        case .keyword:
            keyword

        case .string:
            string

        case .type:
            type

        case .call:
            call

        case .number:
            number

        case .comment:
            comment

        case .property:
            property

        case .dotAccess:
            dotAccess

        case .preprocessing:
            preprocessing

        case .custom(_):
            plainText
        }
    }
}

private struct ContentSizePreference: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(
        value: inout CGSize,
        nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}

private struct ParentSizePreference: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(
        value: inout CGSize,
        nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}
