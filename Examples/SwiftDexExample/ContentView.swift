import SwiftDex
import SwiftUI

struct ContentView<T>: View where T: Deck {
    let deck: T

    var body: some View {
        DeckView(deck: deck)
    }
}
