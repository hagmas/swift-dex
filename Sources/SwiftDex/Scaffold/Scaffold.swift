import SwiftUI

/// `Scaffold` is a protocol for defining the layout information of a Slide.
@MainActor
public protocol Scaffold {
    associatedtype Content: View
    var view: Content { get }
}
