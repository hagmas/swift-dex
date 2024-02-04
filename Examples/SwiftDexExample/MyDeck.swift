import SwiftDex
import SwiftUI

struct MyDeck: Deck {
    var flow: some Flow {
        Title()
            .next(Introduction(), transition: .push())
            .next(customViewsFlow, transition: .push())
            .next(Layout2(), transition: .push())
            .next(MatchedTitle(), transition: .push())
            .next(MatchedContent(), transition: .matched())
    }

    var customViewsFlow: some Flow {
        AboutBullets()
            .next(AboutCode(), transition: .push())
            .next(AboutFlipper(), transition: .push())
    }
}

#Preview{
    DeckPreview(deck: MyDeck())
}
