import SwiftUI

/// A struct that defines the layout information for `StandardLayoutSlide`.
public struct StandardScaffold<Head, Body, Auxiliary>: Scaffold
where Head: View, Body: View, Auxiliary: View {
    private let head: Head
    private let body: Body
    private let auxiliary: Auxiliary
    private let paddingForHeadTop: CGFloat = 40
    private let paddingForHorizontal: CGFloat = 80
    private let paddingForVertical: CGFloat = 80
    private let spaceForHeadAndBody: CGFloat = 40
    private let spaceForHStack: CGFloat = 40

    /// Creates an instance.
    ///
    /// - Parameters:
    ///  - head: A View for displaying the title.
    ///  - body: A View for displaying the main content.
    ///  - auxiliary: A View for displaying auxiliary content, which is displayed on the right half of the screen if defined.
    public init(
        @ViewBuilder head: @escaping () -> Head = { EmptyView() },
        @ViewBuilder body: @escaping () -> Body = { EmptyView() },
        @ViewBuilder auxiliary: @escaping () -> Auxiliary = { EmptyView() }
    ) {
        self.head = head()
        self.body = body()
        self.auxiliary = auxiliary()
    }

    /// The view constructed from the given subviews.
    @ViewBuilder
    public var view: some View {
        HStack(
            alignment: .center,
            spacing: spaceForHStack
        ) {
            leftView
                .padding(.top, paddingForLeftTop)
                .padding(.bottom, paddingForVertical)
            auxiliary
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, paddingForVertical)
        }
        .padding(.horizontal, paddingForHorizontal)
    }
}

private extension StandardScaffold {
    @ViewBuilder
    var leftView: some View {
        VStack(alignment: .leading, spacing: spaceForHeadAndBody) {
            head
                .textStyle(.title)
            body
                .textStyle(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var paddingForLeftTop: CGFloat {
        hasHead ? paddingForHeadTop : paddingForVertical
    }

    var hasHead: Bool {
        !(head is EmptyView)
    }
}
