import SwiftUI

/// A store for slide-local element state, shared by every surface observing
/// the same `DeckController`.
///
/// Values survive only forward movement within one slide: any backward step,
/// random access, or slide transition clears the store, so a rewound or
/// re-entered slide renders exactly as it did on first entry.
///
/// Entries are keyed by `(ElementID, value type)`, mirroring the action
/// system's rule that an element's identity is its `ElementID`.
@Observable
final class SlideValueStore {
    private var storage: [Key: Any] = [:]

    private struct Key: Hashable {
        let elementID: ElementID
        let valueType: ObjectIdentifier
    }

    func value<Value>(of type: Value.Type, for elementID: ElementID) -> Value? {
        storage[Key(elementID: elementID, valueType: ObjectIdentifier(type))] as? Value
    }

    func setValue<Value>(_ value: Value, for elementID: ElementID) {
        storage[Key(elementID: elementID, valueType: ObjectIdentifier(Value.self))] = value
    }

    func clear() {
        guard !storage.isEmpty else {
            return
        }
        storage.removeAll()
    }
}

private struct SlideValueStoreKey: EnvironmentKey {
    static let defaultValue: SlideValueStore? = nil
}

extension EnvironmentValues {
    var slideValueStore: SlideValueStore? {
        get { self[SlideValueStoreKey.self] }
        set { self[SlideValueStoreKey.self] = newValue }
    }
}
