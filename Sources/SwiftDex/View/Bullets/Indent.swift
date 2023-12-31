import Foundation

/// A structure representing an indent level in a list of bullet items.
///
/// `Indent` is used to create a nested structure within bullet lists, allowing for hierarchical organization of items.
public struct Indent {
    var items: [BulletItem]

    /// Initializes an `Indent` with a list of bullet items.
    ///
    /// - Parameter items: A `BulletsBuilder` closure returning an array of `BulletItem`s representing the content of this indent level.
    public init(@BulletsBuilder items: () -> [BulletItem]) {
        self.items = items()
    }
}

extension Indent {
    mutating func increment(offset: Int) {
        items = items.map {
            var item = $0
            item.increment(offset: offset)
            return item
        }
    }
}

extension Indent: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        var strings = [String]()
        for item in items {
            strings.append(String(reflecting: item).insertTab())
        }
        return strings.joined(separator: "\n")
    }
}

private extension String {
    func insertTab() -> String {
        let lines = split(separator: "\n")
        let tabbedLines = lines.map { "\t\($0)" }
        return tabbedLines.joined(separator: "\n")
    }
}
