import SwiftUI

/// `Bullets` is a custom view for displaying text or views in a bulleted list format.
///
/// It allows for animations on each item using the `ApplyByItem` action, enabling dynamic visual effects for list presentations.
public struct Bullets: View {
    let style: BulletStyle
    @EnvironmentObject var eventDispatcher: EventDispatcher
    @StateObject var viewModel: BulletsViewModel
    @ActionContext(ApplyByItem.self) var actionContext

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
        let viewModel = BulletsViewModel(items: items())
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// The content and behavior of the view.
    public var body: some View {
        BulletsChildView(
            style: style,
            items: viewModel.items
        )
        .onReceive(eventDispatcher.forward) { _ in
            if isDynamic {
                withAnimation(animation) {
                    viewModel.forward()
                }
            }
        }
        .onChange(of: viewModel.step) { _, step in
            if isDynamic, viewModel.isReachedEnd, let actionID = actionContext.state?.actionID {
                actionContext.deactivate(actionID: actionID)
            }
        }
        .onChange(of: actionContext.state, initial: true) { _, state in
            switch state {
            case .static:
                viewModel.resetStep()

            case .activated(let value):
                viewModel.resetStep()
                if viewModel.numberOfItems == 1 {
                    actionContext.deactivate(actionID: value.actionID)
                }

            case .deactivated:
                viewModel.setLastStep()

            default:
                break
            }
        }
        .environmentObject(viewModel)
        .animation(animation, value: actionContext.state)
        .animation(animation, value: viewModel.step)
    }
}

private extension Bullets {
    var isDynamic: Bool {
        actionContext.state?.isDynamic ?? false
    }

    var animation: Animation? {
        guard actionContext.canBeAnimated else {
            return nil
        }

        switch actionContext.state {
        case .static(let value):
            return value.previous?.elementTransition.animation

        case .activated(let value):
            return value.current.elementTransition.animation

        case .deactivated(let value):
            return value.current.elementTransition.animation

        default:
            return nil
        }
    }
}

private struct BulletsChildView: View {
    let style: BulletStyle
    let items: [BulletItem]
    @EnvironmentObject var viewModel: BulletsViewModel
    @ActionContext(ApplyByItem.self) var actionContext

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
                            Text(text)
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
                            items: indent.items
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
        switch actionContext.state {
        case .static(let value):
            value.nearestElementModifier

        case .activated(let value):
            if index < viewModel.step {
                value.current.elementTransition.next ?? value.current.elementTransition.current
            }
            else if index == viewModel.step {
                value.current.elementTransition.current
            }
            else {
                value.current.elementTransition.previous
            }

        case .deactivated(let value):
            if index < viewModel.step {
                value.current.elementTransition.next ?? value.current.elementTransition.current
            }
            else {
                value.current.elementTransition.current
            }

        default:
            nil
        }
    }
}

private extension ActionState.Static where A == ApplyByItem {
    var nearestElementModifier: ElementModifier? {
        if let value = next?.elementTransition.previous {
            return value
        }

        if let value = previous?.elementTransition.next {
            return value
        }

        if let value = previous?.elementTransition.current {
            return value
        }

        return nil
    }
}
