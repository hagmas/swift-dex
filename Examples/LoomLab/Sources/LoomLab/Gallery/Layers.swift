import Loom
import SwiftUI

/// Layers of an app, each a row of boxes, with many lines between
/// neighbouring layers.
struct LayersScenario: Scenario {
    static let name = "Layers"

    let step: Int
    let routing: Line.Routing

    var body: some View {
        FigureView(Layers(), routing: routing)
    }
}

private extension NodeID {
    static let home = NodeID("home")
    static let search = NodeID("search")
    static let profile = NodeID("profile")
    static let feedModel = NodeID("feedModel")
    static let userModel = NodeID("userModel")
    static let api = NodeID("api")
    static let cache = NodeID("cache")
    static let auth = NodeID("auth")
}

private struct Layers: Figure {
    var arrangement: some FigureElement {
        Column(spacing: 88) {
            Row(spacing: 32) {
                TextNode(.home, title: "HomeView")
                TextNode(.search, title: "SearchView")
                TextNode(.profile, title: "ProfileView")
            }
            Row(spacing: 32) {
                TextNode(.feedModel, title: "FeedModel")
                TextNode(.userModel, title: "UserModel")
            }
            Row(spacing: 32) {
                TextNode(.api, title: "APIClient")
                TextNode(.cache, title: "Cache")
                TextNode(.auth, title: "Auth")
            }
        }
    }

    var lines: [Line] {
        Line(from: .home, to: .feedModel)
        Line(from: .search, to: .feedModel)
        Line(from: .search, to: .userModel)
        Line(from: .profile, to: .userModel)
        Line(from: .feedModel, to: .api, .cache)
        Line(from: .userModel, to: .api, .auth)
    }
}
