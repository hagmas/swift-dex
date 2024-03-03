# SwiftDex
`SwiftDex` is a framework for describing presentations in SwiftUI.
1. Supports custom views like `Bullets`, `Code` and `Flipper`.
2. Supports animations with simple syntax.
3. Flexible layouts.

| Bullets | Code | Flipper |
| --- | --- | --- |
| <img src="https://github.com/hagmas/swift-dex/assets/7201608/9a9ec959-10ef-4385-8783-ec0911b899cb" width=300> | <img src="https://github.com/hagmas/swift-dex/assets/7201608/82c6b77c-20a8-4486-b888-92c6dcd92cdd" width=300> | <img src="https://github.com/hagmas/swift-dex/assets/7201608/c9ecbf05-d4cf-4ebb-b229-e6ce2ea4ace6" width=300> |

# Installation

# How to Use
A Deck consists of multiple slides, and each slide is composed of Content, Background Views, and Actions.

## 1. Defining a Slide
Each slide can be defined as a type conforming to the `Slide` protocol.
```swift
struct Slide01: Slide {
}
```
The size of the slide is fixed at 1920x1080, and a ScaleEffect is applied to fit the size of the displayed view.

### Custom Views
There are custom views such as Bullets, Code, Flipper, etc.

### `StandardLayoutSlide`
`Slide` can only set Foreground and Background and does not contain typical slide elements such as titles, contents, or layout information like padding. You can use these slide elements by using `StandardLayoutSlide`.

### `Action`
You can set `Action` on a slide. By executing an `Action`, animations can be applied to each element within the slide. You can use preset actions or create your own custom ones. For how to set up custom actions, please refer to ~~~.

## 2. Defining a Deck
A Deck can be defined from the types of each defined slide and information about transitions between slides.

### `Flow` and `SlideTransition`
`Flow` is a struct for specifying the sequence of slides and transition information. You can define the sequence of slides as follows:
```swift
var flow: some Flow {
    Slide01()
        .next(Slide02(), transition: .push())
        .next(Slide01(), transition: .matched())
}
```

### `DeckStyle`
You can also specify a `DeckStyle` to be applied to the entire Deck. Define a type that conforms to the `DeckStyle` protocol and set it within the Deck.

## 3. Displaying a Deck with `DeckView`
A DeckView can be initialized from an instance of a Deck. The `DeckView` scales the slides while maintaining the aspect ratio to fit the size of the view.

## 4. Interacting with the Screen
The `DeckView` can be clicked to advance the scenario set in the Deck (move the slide forward, execute an action). The left half of the screen is assigned the "backward" operation, and the right half is assigned the "forward" operation.

