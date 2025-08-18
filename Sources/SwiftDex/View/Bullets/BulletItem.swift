import SwiftUI

/// `BulletItem` represents each item within a `Bullets` view.
///
/// It holds information about the item's attributes and other relevant details.
/// Instead of creating instances directly, use `@BulletsBuilder` for proper construction within `Bullets`.
public struct BulletItem {
    enum Kind {
        case text(String)
        case view(AnyView)
        case indent(Indent)
    }

    private(set) var index: Int
    let itemNumber: Int
    private(set) var kind: Kind
}

extension BulletItem {
    mutating func increment(offset: Int) {
        index += offset

        switch kind {
        case .indent(let indent):
            var indent = indent
            indent.increment(offset: offset)
            kind = .indent(indent)

        default:
            break
        }
    }

    var lastItemIndex: Int {
        switch kind {
        case .indent(let indent):
            indent.items.last?.lastItemIndex ?? 0

        default:
            index
        }
    }

    var numberOfItems: Int {
        switch kind {
        case .indent(let indent):
            indent.items.reduce(0) { $0 + $1.numberOfItems }

        default:
            1
        }
    }
}

extension BulletItem: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        switch kind {
        case .text(let text):
            "index: \(index), kind: text(\(text))"

        case .view:
            "index: \(index), kind: view"

        case .indent(let indent):
            """
            index: \(index), kind: indent [
            \(String(reflecting: indent))
            ]
            """
        }
    }
}

extension Array where Element == BulletItem {
    var numberOfItems: Int {
        reduce(0) { $0 + $1.numberOfItems }
    }
}
