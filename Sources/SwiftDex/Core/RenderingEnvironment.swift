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

private struct IsMirrorKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// Whether this surface mirrors a presentation that is primarily shown
    /// elsewhere (e.g. a presenter display echoing the audience window).
    ///
    /// Views can read this to reduce rendering cost or substitute content
    /// that cannot exist on two surfaces at once. Set it on a secondary
    /// `DeckView`:
    ///
    /// ```swift
    /// DeckView(deck: deck, controller: controller)
    ///     .environment(\.isMirror, true)
    /// ```
    var isMirror: Bool {
        get { self[IsMirrorKey.self] }
        set { self[IsMirrorKey.self] = newValue }
    }
}
