# SwiftDex
`SwiftDex` is a framework for describing presentations in SwiftUI.
1. Supports custom views like `Bullets`, `Code` and `Flipper`.
2. Supports animations with simple syntax.
3. Flexible layouts.

| Bullets + Animation | Bullets + Flipper + Animation |
| --- | --- |
| <img src="https://github.com/hagmas/swift-dex/assets/7201608/9a9ec959-10ef-4385-8783-ec0911b899cb"> | <img src="https://github.com/hagmas/swift-dex/assets/7201608/c9ecbf05-d4cf-4ebb-b229-e6ce2ea4ace6"> |

# Installation
## Xcode Package Dependency
File -> Add Package Dependencies... and search for this package with the URL below:
```
https://github.com/hagmas/swift-dex
```

# How to Use
To create a presentation, you need to define a `Deck` that contains multiple slides with their transition information, and `Slide`s that define the content of each slide.

## 1. Defining a Slide
Each slide can be defined as a type conforming to the `Slide` protocol.
```swift
struct Slide01: Slide {
    var content: some View { ... }

    var background: some View { ... }
}
```
> [!NOTE]
> Currently the size of the slide is fixed at 1920x1080, and a ScaleEffect is applied to fit the size of the displayed view.

### `StandardLayoutSlide`
`Slide` can only set Foreground and Background and does not contain any layout information or typical slide elements such as titles, contents, or layout information like padding. You can use these slide elements by using `StandardLayoutSlide`.
```swift
struct Slide01: StandardLayoutSlide {
    var head: some View { ... }

    var body: some View { ... }
}
```
`StandardLayoutSlide` serves as a scaffold for foreground elements, positioning them at the forefront of the `Slide`.

### Custom Views
There are custom views such as `Bullets`, `Code`, `Flipper`, etc.
- `Bullets`: A custom view for displaying text or views in a bulleted list format.
- `Code`: A view that displays code with syntax highlighting.
- `Flipper`: A view that displays multiple views split into steps.

### `Action`
`Slide` is stateless, meaning its content cannot be dynamically changed using SwiftUI's property wrappers like `@State`. However, you can make the slide content dynamic by using `Action`. For instance, adding an `Apply` action allows animations to be applied to views identified by an `elementID`.
```swift
struct Slide01: StandardLayoutSlide {
    @ViewBuilder
    var body: some View {
        "Title"
            .textStyle(.title)
            .elementID(.element(0))
    }
    
    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Apply(.fade, to: .element(0))
    }
}
```
![Apply_Sample](https://github.com/hagmas/swift-dex/assets/7201608/ec94ab50-433a-4af1-9ec8-db31fea2d39b)

It's possible to specify multiple `Action`s within a Slide. Advancing the slide (either by tapping on the left side of the slide view or pressing the left arrow key on the keyboard) triggers the actions sequentially, starting with the first one. There are several preset actions available, such as `ApplyByItem`, `Zoom`, and `FlipByItem`. Additionally, custom Actions can be created using custom views.

## 2. Defining a Deck
A Deck can be defined with the slide instances and information about transitions between slides.
```swift
struct MyDeck: Deck {
    var flow: some Flow {
        Slide01()
            .next(Slide02(), transition: .push())
            .next(Slide01(), transition: .matched())
    }

    static var deckStyle: DeckStyle.Type {
        CustomDeckStyle.self
    }
}
```
`Flow` is a struct for specifying the sequence of slides and transition information. You can also specify a `DeckStyle` to be applied to the entire Deck. Define a type that conforms to the `DeckStyle` protocol and set it within the Deck.

## 3. Displaying a Deck with `DeckView`
`DeckView` can be initialized from an instance of a Deck. The `DeckView` scales the slides while maintaining the aspect ratio to fit the size of the view.

## 4. Interacting with the Screen
The `DeckView` can be clicked to advance the scenario set in the Deck (move the slide forward, execute an action). The left half of the screen is assigned the "backward" operation, and the right half is assigned the "forward" operation.

