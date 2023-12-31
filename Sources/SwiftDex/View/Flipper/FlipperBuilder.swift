import SwiftUI

/// A result builder for constructing an array of views for the `Flipper` view.
@resultBuilder
public struct FlipperBuilder {
    /// Builds an array of `AnyView` from a single view content.
    ///
    /// - Parameter content: The first view content to be included in the array.
    /// - Returns: An array containing the provided view content as an `AnyView`.
    public static func buildPartialBlock<Content: View>(first content: Content) -> [AnyView] {
        [AnyView(content)]
    }

    /// Appends a view to an existing array of `AnyView`.
    ///
    /// - Parameters:
    ///   - accumulated: The existing array of `AnyView`.
    ///   - next: The next view content to be appended to the array.
    /// - Returns: An updated array containing the existing and the newly added view content as `AnyView`.
    public static func buildPartialBlock<Content: View>(
        accumulated: [AnyView],
        next: Content
    ) -> [AnyView] {
        accumulated + [AnyView(next)]
    }
}
