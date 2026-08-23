import SwiftUI

/// Makes a view a target of the `Apply` action and publishes its bounds.
///
/// Every view can be faded, offset, scaled or blurred, so carrying an
/// `ElementID` implies `Apply` support. `ActionReader` installs this for its
/// own element, which is how a view that consumes an action of its own also
/// becomes an `Apply` target without doing anything.
///
/// A view without an identity (`.none`) is left untouched: an un-identified
/// element cannot be an action target, and publishing its bounds under `.none`
/// would shadow the full-slide rect that `Zoom(.out)` relies on.
struct ElementAnimator: ViewModifier {
    let elementID: ElementID
    var isEnabled: Bool = true

    func body(content: Content) -> some View {
        if isEnabled && elementID != .none {
            // `isApplyTarget: false` is required: this reader *implements* the
            // Apply path, so letting it install another would recurse forever.
            ActionReader(Apply.self, elementID: elementID, clicks: 1, isApplyTarget: false) {
                progress in
                let elementModifier = progress.elementModifier
                if !(elementModifier?.isHidden ?? false) {
                    content.apply(elementModifier ?? .identity)
                }
            } animation: { progress in
                progress.transitionAnimation
            }
            // Published outside the modifier so bounds stay in untransformed
            // slide coordinates: a zoom already in effect must not distort a
            // later target.
            .modifier(ElementAnchorPublisher(elementID: elementID))
        }
        else {
            content
        }
    }
}

/// Publishes a view's bounds so `Zoom` and `Highlight` can resolve it by
/// `ElementID`.
///
/// Purely a measurement: it installs no rendering effect, so it is safe on
/// views that cannot be flattened — which is why `VideoView` uses it alone.
struct ElementAnchorPublisher: ViewModifier {
    let elementID: ElementID

    func body(content: Content) -> some View {
        content
            .transformAnchorPreference(
                key: ElementAnchorsPreference.self,
                value: .bounds
            ) {
                // `.none` must stay absent: `Zoom(.out)` resolves to the full
                // slide precisely by finding no anchor for it.
                if elementID != .none {
                    $0[elementID] = $1
                }
            }
    }
}
