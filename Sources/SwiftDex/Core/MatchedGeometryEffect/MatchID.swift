import SwiftUI

/// `MatchID` is an identifier used when applying `matchedGeometryEffect` to two different Views in consecutive slides.
///
/// Specify the `MatchID` to the Views you want to match using the `matchID` function,
/// and use a `SlideTransition` with `isMatched` set to `true` for the transition.
/// This will apply the `matchedGeometryEffect` to the specified Views.
///
public struct MatchID: Hashable {
    /// String representation of `MatchID`.
    public let rawValue: String

    /// Create a new instance.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    func append(_ s: String) -> MatchID {
        MatchID(rawValue: rawValue + "_" + s)
    }
}

public extension View {
    /// Give a match ID to a view.
    func matchID(_ id: MatchID) -> some View {
        self
            .modifier(MatchIDModifier(id: id))
    }
}

private struct MatchIDModifier: ViewModifier {
    @Environment(\.namespaceID) var namespaceID
    @Environment(\.matchProperties) var matchProperties
    var id: MatchID

    func body(content: Content) -> some View {
        if let namespaceID {
            content
                .add(
                    matchID: id,
                    additionalID: matchProperties?.insertionID,
                    namespaceID: namespaceID
                )
                .add(
                    matchID: id,
                    additionalID: matchProperties?.removalID,
                    namespaceID: namespaceID
                )
        }
        else {
            content
        }
    }
}

private extension View {
    @ViewBuilder
    func add(
        matchID: MatchID,
        additionalID: String?,
        namespaceID: Namespace.ID
    ) -> some View {
        if let additionalID {
            self.matchedGeometryEffect(
                id: matchID.append(additionalID),
                in: namespaceID
            )
        }
        else {
            self
        }
    }
}
