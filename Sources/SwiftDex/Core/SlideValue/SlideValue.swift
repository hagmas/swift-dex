import SwiftUI

/// A property wrapper for slide-local state that stays in sync across every
/// window presenting the same deck.
///
/// Use it in place of `@State` inside a custom view when the state should be
/// shared between the presentation window and its mirrors (e.g. a presenter
/// display). The value is keyed by an `ElementID`, which the wrapper reads from
/// the environment. A view cannot write the environment for its own stored
/// properties, so take the identity in the initializer and hand it to a private
/// child view that declares the `@SlideValue`:
///
/// ```swift
/// public struct Counter: View {
///     private let elementID: ElementID
///
///     public init(elementID: ElementID = .none) {
///         self.elementID = elementID
///     }
///
///     public var body: some View {
///         CounterBody()
///             .environment(\.elementID, elementID)
///     }
/// }
///
/// private struct CounterBody: View {
///     @SlideValue private var count = 0
///
///     var body: some View {
///         Button("\(count)") { count += 1 }
///     }
/// }
/// ```
///
/// Without an `ElementID` (or outside a `DeckView`), the wrapper falls back
/// to plain view-local state and nothing is shared.
///
/// The value lives only while the presentation moves forward within the
/// current slide. Going backward, jumping to another slide, or any slide
/// transition resets it, so rewinds stay deterministic.
@propertyWrapper
public struct SlideValue<Value>: DynamicProperty {
    @Environment(\.elementID) private var elementID
    @Environment(\.slideValueStore) private var store

    @State private var localValue: Value
    private let initialValue: Value

    /// Creates the slide value with an initial value.
    public init(wrappedValue: Value) {
        self.initialValue = wrappedValue
        self._localValue = State(initialValue: wrappedValue)
    }

    /// The current value, shared across surfaces when an `ElementID` is set.
    public var wrappedValue: Value {
        get {
            if let store, elementID != .none {
                return store.value(of: Value.self, for: elementID) ?? initialValue
            }
            return localValue
        }
        nonmutating set {
            if let store, elementID != .none {
                store.setValue(newValue, for: elementID)
            }
            else {
                localValue = newValue
            }
        }
    }

    /// A binding to the value, for handing to controls.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
