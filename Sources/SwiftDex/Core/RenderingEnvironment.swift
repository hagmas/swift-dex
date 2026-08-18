import SwiftUI

private struct StaticRenderingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isStaticRendering: Bool {
        get { self[StaticRenderingKey.self] }
        set { self[StaticRenderingKey.self] = newValue }
    }
}
