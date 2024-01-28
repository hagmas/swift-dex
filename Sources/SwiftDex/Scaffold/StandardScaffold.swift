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
        head: Head,
        body: Body,
        auxiliary: Auxiliary
    ) {
        self.head = head
        self.body = body
        self.auxiliary = auxiliary
    }

    /// The view constructed from the given subviews.
    @ViewBuilder
    public var view: some View {
        VStack(alignment: .leading, spacing: spaceForHeadAndBody) {
            head
                .textStyle(.title)
                .padding(.top, paddingForHeadTop)
            HStack(
                alignment: .center,
                spacing: spaceForHStack
            ) {
                body
                    .textStyle(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, paddingForContentTop)
                    .padding(.bottom, paddingForVertical)
                auxiliary
                    .textStyle(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, paddingForContentTop)
                    .padding(.bottom, paddingForVertical)
            }
        }
        .padding(.horizontal, paddingForHorizontal)
    }
}

private extension StandardScaffold {
    var paddingForContentTop: CGFloat {
        hasHead ? 0 : paddingForVertical
    }

    var hasHead: Bool {
        !(head is EmptyView)
    }
}
