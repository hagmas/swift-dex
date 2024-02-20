import SwiftDex
import SwiftUI

struct MyDeck: Deck {
    var flow: some Flow {
        Title(title: "Introducing SwiftDex")
            .next(Introduction(), transition: .push())
            .next(customViewsFlow, transition: .push())
            .next(layoutFlow, transition: .push())
            .next(MatchedTitle(), transition: .push())
            .next(MatchedContent(), transition: .matched())
    }

    var customViewsFlow: some Flow {
        Title(title: "Custom Views")
            .next(AboutBullets(), transition: .push())
            .next(AboutCode(), transition: .push())
            .next(AboutFlipper(), transition: .push())
    }
    
    var layoutFlow: some Flow {
        Title(title: "Layout Flexibility")
            .next(AboutStandardLayout(), transition: .push())
            .next(Layout1(), transition: .push())
            .next(Layout2(), transition: .push())
    }
}

#Preview{
    DeckPreview(deck: MyDeck())
}
