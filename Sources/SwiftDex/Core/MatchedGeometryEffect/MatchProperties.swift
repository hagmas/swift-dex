import SwiftUI

struct MatchProperties {
    let insertionID: String?
    let removalID: String?
}

private struct MatchPropertiesKey: EnvironmentKey {
    static let defaultValue: MatchProperties? = nil
}

extension EnvironmentValues {
    var matchProperties: MatchProperties? {
        get { self[MatchPropertiesKey.self] }
        set { self[MatchPropertiesKey.self] = newValue }
    }
}
