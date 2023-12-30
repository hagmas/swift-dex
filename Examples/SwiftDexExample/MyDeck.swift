import SwiftDex
import SwiftUI

struct MyDeck: Deck {
    var flow: some Flow {
        Slide01()
            .next(Slide02(), transition: .push())
            .next(Slide01(), transition: .matched())
    }
}

#Preview{
    DeckPreview(deck: MyDeck())
}
