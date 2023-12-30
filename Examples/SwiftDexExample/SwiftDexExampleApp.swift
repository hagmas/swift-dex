import SwiftDex
import SwiftUI

@main
struct SwiftDexExample: App {
    var body: some Scene {
        WindowGroup {
            ContentView(deck: MyDeck())
        }
    }
}
