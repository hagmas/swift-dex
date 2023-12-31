import Foundation

/// Initialize a `DeckView` with an instance of a type conforming to this protocol to display a Deck.
public protocol Deck {
    associatedtype FlowType: Flow
    var flow: FlowType { get }
    static var deckStyle: DeckStyle.Type { get }
}

public extension Deck {
    static var deckStyle: DeckStyle.Type {
        DefaultDeckStyle.self
    }
}
