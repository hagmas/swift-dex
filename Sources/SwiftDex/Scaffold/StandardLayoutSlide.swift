import SwiftUI

/// A protocol for defining a Slide using `StandardScaffold`.
public protocol StandardLayoutSlide: Slide {
    associatedtype Head: View
    associatedtype Body: View
    associatedtype Auxiliary: View

    /// The `View` that is displayed in the title part of the slide.
    var head: Head { get }

    /// The `View` that is displayed as the main content of the slide.
    var body: Body { get }

    /// The `View` that is displayed as auxiliary content on the right half of the slide.
    var auxiliary: Auxiliary { get }
}

public extension StandardLayoutSlide {
    var head: some View {
        EmptyView()
    }

    var body: some View {
        EmptyView()
    }

    var auxiliary: some View {
        EmptyView()
    }

    var content: some View {
        StandardScaffold(
            head: { head },
            body: { body },
            auxiliary: { auxiliary }
        ).view
    }
}
