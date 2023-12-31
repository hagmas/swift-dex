import Foundation
import SwiftUI

/// A protocol for defining Actions that are applied when advancing a slide.
///
/// When defining a custom `Action`, it is necessary to also define a custom `View` that can handle that `Action`.
public protocol Action: ActionTupleElement {
    /// `ElementID` for the target of this `Action`.
    var elementID: ElementID { get }
}

public extension Action {
    /// Default  value for `elementID`.
    var elementID: ElementID {
        .none
    }
}

public extension Action {
    /// Implementation for `ActionTupleElement` protocol.
    func visit(with container: inout TempActionContainer) {
        container.add(action: self)
    }
}
