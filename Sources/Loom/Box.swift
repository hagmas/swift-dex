import SwiftUI

/// A rounded rectangle with a label in it — the node nine figures out of ten
/// are made of.
///
/// `Box` is to ``Node`` what `Text` is to `View`: the concrete type you reach
/// for until you need your own.
///
/// ```swift
/// Box(.repository, title: "Repository")
/// ```
///
/// A minimum width is applied so that boxes whose labels differ in length still
/// line up; a long label wraps and the box grows taller instead of wider.
public struct Box: Node {
    /// The width every box is at least, unless told otherwise.
    ///
    /// Ragged box widths are the first thing that makes a figure look untidy,
    /// so the default is a width rather than none.
    public static let defaultMinWidth: CGFloat = 140

    /// The identity lines refer to.
    public let id: NodeID

    /// The text shown in the box.
    public var title: String

    /// The width the box will not shrink below.
    public var minWidth: CGFloat

    /// Creates a box.
    ///
    /// - Parameters:
    ///   - id: The identity lines refer to.
    ///   - title: The text shown in the box.
    ///   - minWidth: The width the box will not shrink below.
    public init(
        _ id: NodeID,
        title: String,
        minWidth: CGFloat = Box.defaultMinWidth
    ) {
        self.id = id
        self.title = title
        self.minWidth = minWidth
    }

    /// The content and behavior of the view.
    public var body: some View {
        Text(title)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minWidth: minWidth)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.secondary)
            )
    }
}
