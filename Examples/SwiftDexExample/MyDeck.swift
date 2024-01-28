import SwiftDex
import SwiftUI

struct MyDeck: Deck {
    var flow: some Flow {
        Title()
            .next(Introduction(), transition: .push())
            .next(AboutBullets(), transition: .push())
            .next(AboutFlipper(), transition: .push())
            .next(AboutCode(), transition: .push())
            .next(Layout2(), transition: .push())
    }
}

#Preview{
    DeckPreview(deck: MyDeck())
}
