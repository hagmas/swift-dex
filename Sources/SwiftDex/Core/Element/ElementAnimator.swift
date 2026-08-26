import SwiftUI

/// Makes a view a target of the `Apply` action and publishes its bounds for
/// `Camera` and `Highlight`.
///
/// Every view can be faded, offset, scaled or blurred, so carrying an
/// `ElementID` implies this. `ActionReader` installs it for its own element,
/// which is how a view that consumes an action of its own also becomes an
/// `Apply` target without doing anything for it.
///
/// A view without an identity is left untouched. `.none` is the sentinel for
/// "no identity", so it can be neither an action target nor an anchor — the
/// slide-scoped readers register under `.none`, and an anchor published there
/// would make the sentinel itself addressable as a target.
struct ElementAnimator: ViewModifier {
    let elementID: ElementID

    @ViewBuilder
    func body(content: Content) -> some View {
        if elementID == .none {
            content
        }
        else {
            // Built on `ActionProgressReader`, not `ActionReader`: the latter
            // installs this modifier, so going through it would recurse.
            ActionProgressReader(Apply.self, elementID: elementID, clicks: 1) { progress in
                let elementModifier = progress.elementModifier
                if !(elementModifier?.isHidden ?? false) {
                    content.apply(elementModifier ?? .identity)
                }
            } animation: { progress in
                progress.transitionAnimation
            }
            // Outside the modifier, so bounds stay in untransformed slide
            // coordinates: a zoom already in effect must not distort a later
            // target.
            .transformAnchorPreference(
                key: ElementAnchorsPreference.self,
                value: .bounds
            ) {
                $0[elementID] = $1
            }
        }
    }
}
