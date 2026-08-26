import SwiftUI

/// A container that makes an arbitrary view addressable by an `Action`.
///
/// Wrap any view to give it an identity that actions can target. `Element`
/// applies the `Apply` action's `ElementModifier` to its content and publishes
/// the content's bounds so that `Camera` and `Highlight` can find it.
///
/// ```swift
/// Element(.title) {
///     Text("Hello")
/// }
/// ```
/// ```swift
/// @ActionContainerBuilder
/// var actionContainer: ActionContainer {
///     Apply(.fade, to: .title)
/// }
/// ```
///
/// Views that consume an action themselves — `Bullets`, `Flipper`, `VideoView` —
/// take their `ElementID` in their initializer instead, and get `Apply` support
/// from their own `ActionReader`. `Element` is for views that know nothing about
/// actions.
public struct Element<Content: View>: View {
    private let elementID: ElementID
    private let content: Content

    /// Creates an addressable element.
    ///
    /// - Parameters:
    ///   - elementID: The identity actions use to target this element.
    ///   - content: The view to make addressable.
    public init(_ elementID: ElementID, @ViewBuilder content: () -> Content) {
        self.elementID = elementID
        self.content = content()
    }

    /// The content and behavior of the view.
    public var body: some View {
        content
            .modifier(ElementAnimator(elementID: elementID))
    }
}
