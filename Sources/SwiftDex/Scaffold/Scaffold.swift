import SwiftUI

/// `Scaffold` is a protocol for defining the layout information of a Slide.
public protocol Scaffold {
    associatedtype Content: View
    var view: Content { get }
}
