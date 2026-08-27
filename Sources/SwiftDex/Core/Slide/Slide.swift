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

    /// The area this slide lays its content out in.
    ///
    /// Defaults to the viewport, which is the whole of the slide. A larger
    /// canvas gives the slide room the viewport cannot show at once, reached
    /// with `Camera`.
    var canvas: SlideCanvas { get }
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

    /// Default value for `canvas`.
    var canvas: SlideCanvas {
        .slide
    }

    /// Default implemenation for `flatten()`.
    func flatten() -> [(any Slide, SlideTransition)] {
        [(self, .none)]
    }
}

extension Slide {
    func createView(state: Binding<SlideState>) -> AnyView {
        AnyView(
            SlideView(
                slide: self,
                state: state
            )
        )
    }

    func createStaticView() -> AnyView {
        AnyView(
            SlideView(slide: self)
        )
    }
}
