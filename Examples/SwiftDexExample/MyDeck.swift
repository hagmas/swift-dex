import SwiftDex
import SwiftUI

struct MyDeck: Deck {
    var flow: some Flow {
        Title(title: "Introducing SwiftDex")
            .next(Introduction(), transition: .customPush())
            .next(customViewsFlow, transition: .customPush())
            .next(customeAnimationFlow, transition: .customPush())
            .next(layoutFlow, transition: .customPush())
            .next(Title(title: "Thank you"), transition: .customPush())
    }
}

private extension MyDeck {
    var customeAnimationFlow: some Flow {
        Title(title: "Custom Animations")
            .next(AboutAction(), transition: .customPush())
            .next(AboutApply(), transition: .customPush())
            .next(AboutZoom(), transition: .customPush())
            .next(AboutTransition(), transition: .customPush())
            .next(AboutMatchedTransition0(), transition: .customPush())
            .next(AboutMatchedTransition1(), transition: .matched())
            .next(AboutHighlight(), transition: .customPush())
    }

    var customViewsFlow: some Flow {
        Title(title: "Custom Views")
            .next(AboutBullets(), transition: .customPush())
            .next(AboutCode(), transition: .customPush())
            .next(AboutFlipper(), transition: .customPush())
    }

    var layoutFlow: some Flow {
        Title(title: "Layout Flexibility")
            .next(AboutStandardLayout(), transition: .customPush())
            .next(Layout1(), transition: .customPush())
            .next(Layout2(), transition: .customPush())
    }
}

#Preview{
    DeckPreview(deck: MyDeck())
}
