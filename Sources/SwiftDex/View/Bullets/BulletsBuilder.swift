import SwiftUI

/// A Result Builder for creating an array of `BulletItem`s.
///
/// It can accept items of types `String`, `View`, or `Indent`.
@resultBuilder
public struct BulletsBuilder {
    /// Creates an array of `BulletItem`s from a single string.
    public static func buildPartialBlock(first content: String) -> [BulletItem] {
        [BulletItem(index: 0, itemNumber: 0, kind: .text(content))]
    }

    /// Creates an array of `BulletItem`s from a single view.
    public static func buildPartialBlock<Content: View>(first content: Content) -> [BulletItem] {
        [BulletItem(index: 0, itemNumber: 0, kind: .view(AnyView(content)))]
    }

    /// Creates an array of `BulletItem`s from a single indent.
    public static func buildPartialBlock(first content: Indent) -> [BulletItem] {
        [BulletItem(index: 0, itemNumber: 0, kind: .indent(content))]
    }

    /// Appends a string as a `BulletItem` to an existing array of `BulletItem`s.
    public static func buildPartialBlock(accumulated: [BulletItem], next: String) -> [BulletItem] {
        var accumulated = accumulated
        if let last = accumulated.last {
            accumulated.append(
                BulletItem(
                    index: last.lastItemIndex + 1,
                    itemNumber: last.itemNumber + 1,
                    kind: .text(next)
                )
            )
        }
        else {
            accumulated.append(
                BulletItem(
                    index: 0,
                    itemNumber: 0,
                    kind: .text(next)
                )
            )
        }
        return accumulated
    }

    /// Appends a view as a `BulletItem` to an existing array of `BulletItem`s.
    public static func buildPartialBlock<Content: View>(accumulated: [BulletItem], next: Content)
        -> [BulletItem]
    {
        var accumulated = accumulated
        if let last = accumulated.last {
            accumulated.append(
                BulletItem(
                    index: last.lastItemIndex + 1,
                    itemNumber: last.itemNumber + 1,
                    kind: .view(AnyView(next))
                )
            )
        }
        else {
            accumulated.append(
                BulletItem(
                    index: 0,
                    itemNumber: 0,
                    kind: .view(AnyView(next))
                )
            )
        }
        return accumulated
    }

    /// Appends an indent as a `BulletItem` to an existing array of `BulletItem`s.
    public static func buildPartialBlock(accumulated: [BulletItem], next: Indent) -> [BulletItem] {
        var accumulated = accumulated
        if let last = accumulated.last {
            var next = next
            next.increment(offset: last.lastItemIndex + 1)
            accumulated.append(
                BulletItem(
                    index: last.lastItemIndex + 1,
                    itemNumber: last.itemNumber,
                    kind: .indent(next)
                )
            )
        }
        else {
            accumulated.append(
                BulletItem(
                    index: 0,
                    itemNumber: 0,
                    kind: .indent(next)
                )
            )
        }
        return accumulated
    }
}
