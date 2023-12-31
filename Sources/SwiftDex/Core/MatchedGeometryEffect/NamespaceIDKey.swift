import SwiftUI

private struct NamespaceIDKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var namespaceID: Namespace.ID? {
        get { self[NamespaceIDKey.self] }
        set { self[NamespaceIDKey.self] = newValue }
    }
}
