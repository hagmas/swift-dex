import SwiftUI

/// A protocol for defining the contents of a slide and a series of actions to apply to it.
public protocol Slide: Flow {
    associatedtype Content: View
    associatedtype Background: View

    /// The `view` that is displayed as the main content of the slide.
    var content: Content { get }

    /// The `background` is a `view` that is always positioned behind the `content`.
    var background: Background { get }

    /// The `actionContainer` defines a series of Actions that are applied to this slide.
    ///
    /// Define it using the `@ActionContainerBuilder` result builder.
    var actionContainer: ActionContainer { get }
}

public extension Slide {
    /// Default value for `background`.
    var background: some View {
        EmptyView()
    }

    /// Default value for `actionContainer`.
    var actionContainer: ActionContainer {
        ActionContainer.empty
    }

    /// Default implemenation for `flatten()`.
    func flatten() -> [(any Slide, SlideTransition)] {
        [(self, .none)]
    }
}

extension Slide {
    func createView(
        state: Binding<SlideState>,
        actionContainer: ActionContainer
    ) -> AnyView {
        AnyView(
            SlideView(
                slide: self,
                state: state,
                actionContainer: actionContainer
            )
        )
    }

    func createStaticView() -> AnyView {
        AnyView(
            SlideView(slide: self)
        )
    }
}
