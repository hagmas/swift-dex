import SwiftUI

/// `Bullets` is a custom view for displaying text or views in a bulleted list format.
///
/// It allows for animations on each item using the `ApplyByItem` action, enabling dynamic visual effects for list presentations.
public struct Bullets: View {
    let style: BulletStyle
    private let items: [BulletItem]

    /// Creates an instance.
    ///
    /// - Parameters:
    ///  - style: Type of bullets.
    ///  - items: A closure to create a list of `BulletItem`. Use the `BulletsBuilder` result builder.
    public init(
        style: BulletStyle = .bullet,
        @BulletsBuilder items: () -> [BulletItem]
    ) {
        self.style = style
        self.items = items()
    }

    /// The content and behavior of the view.
    public var body: some View {
        ActionStepper(ApplyByItem.self, count: items.numberOfItems) { step, state in
            BulletsChildView(
                style: style,
                items: items,
                step: step,
                actionState: state
            )
        } animation: { state in
            state?.transitionAnimation
        }
    }
}

private struct BulletsChildView: View {
    let style: BulletStyle
    let items: [BulletItem]
    let step: Int
    let actionState: ActionState<ApplyByItem>?

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(0..<items.endIndex, id: \.self) {
                let item = items[$0]
                switch item.kind {
                case .text(let text):
                    if !isHidden(for: items[$0].index) {
                        HStack(alignment: .top) {
                            bulletView(for: item.itemNumber)
                            if let markdown = try? AttributedString(markdown: text) {
                                Text(markdown)
                            }
                            else {
                                Text(text)
                            }
                        }
                        .apply(elementModifier(for: items[$0].index) ?? .identity)
                    }

                case .view(let view):
                    if !isHidden(for: items[$0].index) {
                        HStack(alignment: .top) {
                            bulletView(for: item.itemNumber)
                            view
                        }
                        .apply(elementModifier(for: items[$0].index) ?? .identity)
                    }

                case .indent(let indent):
                    HStack(alignment: .top) {
                        Text("\t\t")
                        BulletsChildView(
                            style: style,
                            items: indent.items,
                            step: step,
                            actionState: actionState
                        )
                    }
                }
            }
        }
    }
}

private extension BulletsChildView {
    @ViewBuilder
    func bulletView(for index: Int) -> some View {
        switch style {
        case .none:
            EmptyView()

        case .bullet:
            Text("・ ")

        case .numbered:
            Text("\(index + 1). ")

        case .lettered:
            Text("\(String(Character(int: index))). ")
        }
    }

    func isHidden(for index: Int) -> Bool {
        elementModifier(for: index)?.isHidden ?? false
    }

    func elementModifier(for index: Int) -> ElementModifier? {
        switch actionState {
        case .static:
            actionState?.nearestElementModifier

        case .activated(let value):
            if index < step - 1 {
                value.current.elementTransition.after ?? value.current.elementTransition.current
            }
            else if index == step - 1 {
                value.current.elementTransition.current
            }
            else {
                value.current.elementTransition.before
            }

        case .deactivated(let value):
            if index < step - 1 {
                value.current.elementTransition.after ?? value.current.elementTransition.current
            }
            else {
                value.current.elementTransition.current
            }

        default:
            nil
        }
    }
}
