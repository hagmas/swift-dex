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
            .lineStyle(.iceCandy)
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
                TextNode(.home, title: "HomeView").nodeStyle(.frosty(.grape))
                TextNode(.search, title: "SearchView").nodeStyle(.frosty(.grape))
                TextNode(.profile, title: "ProfileView").nodeStyle(.frosty(.grape))
            }
            Row(spacing: 32) {
                TextNode(.feedModel, title: "FeedModel").nodeStyle(.frosty(.soda))
                TextNode(.userModel, title: "UserModel").nodeStyle(.frosty(.soda))
            }
            Row(spacing: 32) {
                TextNode(.api, title: "APIClient").nodeStyle(.frosty(.melon))
                TextNode(.cache, title: "Cache").nodeStyle(.frosty(.melon))
                TextNode(.auth, title: "Auth").nodeStyle(.frosty(.melon))
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
