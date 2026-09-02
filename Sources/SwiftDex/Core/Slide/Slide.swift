import SwiftUI

/// A protocol for defining the contents of a slide and a series of actions to apply to it.
@MainActor
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

    /// Who is allowed to move this slide's camera.
    ///
    /// Derived from `canvas` by default: a slide with somewhere to go can be
    /// moved. Write it to override that in either direction.
    var cameraControl: CameraControl { get }
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

    /// Default value for `cameraControl`.
    ///
    /// A slide that declared a canvas has somewhere to go, and a presenter who
    /// tries to travel there should not first have to discover a flag. A slide
    /// that did not declare one is untouched, so nothing a deck already
    /// contains gains behaviour it never asked for.
    var cameraControl: CameraControl {
        canvas == .slide ? .scripted : .interactive
    }

    /// Default implemenation for `flatten()`.
    nonisolated func flatten() -> [(any Slide, SlideTransition)] {
        [(self, .none)]
    }
}

extension Slide {
    @MainActor
    func createView(state: Binding<SlideState>) -> AnyView {
        AnyView(
            SlideView(
                slide: self,
                state: state
            )
        )
    }

    @MainActor
    func createStaticView() -> AnyView {
        AnyView(
            SlideView(slide: self)
        )
    }
}
