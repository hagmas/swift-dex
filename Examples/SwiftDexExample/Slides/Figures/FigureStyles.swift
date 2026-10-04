import Loom
import SwiftDex
import SwiftUI

/// Boxes styled by what they stand for.
///
/// A box's style is not part of its identity, so a box can change what it
/// stands for and stay the same box: its lines stay attached and its colours
/// animate across.
struct FigureStyles: StandardLayoutSlide {
    @ViewBuilder
    var head: some View {
        "Styles"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            "**`BoxStyle`** and **`LineStyle`** belong to the figure, not to the node's identity."
            Converting(elementID: .element(0))
        }
    }

    @ActionContainerBuilder
    var actionContainer: ActionContainer {
        Convert(.element(0))
    }
}

/// An action that does nothing but count the click it has been given.
private struct Convert: Action {
    let elementID: ElementID

    init(_ elementID: ElementID) {
        self.elementID = elementID
    }
}

private struct Converting: View {
    let elementID: ElementID

    var body: some View {
        ActionReader(Convert.self, elementID: elementID, clicks: 1) { progress in
            FigureView(Types(converted: converted(progress)), routing: .orthogonal)
                .figureAtBodyTextSize()
        } animation: { _ in
            .smooth(duration: 0.8)
        }
    }

    private func converted(_ progress: ActionProgress<Convert>) -> Bool {
        switch progress {
        case .idle(let previous, _):
            previous != nil

        case .active, .completed:
            true
        }
    }
}

private extension BoxStyle {
    static let classType = BoxStyle(
        fill: Color(red: 0.88, green: 0.93, blue: 1.0),
        stroke: Color(red: 0.2, green: 0.4, blue: 0.85),
        strokeWidth: 1.5
    )

    static let structType = BoxStyle(
        fill: Color(red: 1.0, green: 0.93, blue: 0.85),
        stroke: Color(red: 0.85, green: 0.45, blue: 0.1),
        strokeWidth: 1.5,
        fontWeight: .semibold,
        cornerRadius: 2
    )
}

private extension LineStyle {
    /// Conformance to a protocol, the way UML draws realization.
    static let conformance = LineStyle(dash: [5, 3], arrowHead: .hollow)

    /// A use that is not ownership.
    static let dependency = LineStyle(dash: [5, 3], arrowHead: .open)
}

private extension NodeID {
    static let view = NodeID("view")
    static let model = NodeID("model")
    static let user = NodeID("user")
    static let settings = NodeID("settings")
    static let point = NodeID("point")
    static let identifiable = NodeID("identifiable")
}

private struct Types: Figure {
    /// Whether `User` has been turned into a struct.
    var converted: Bool

    var arrangement: some FigureElement {
        Column(spacing: 40) {
            Row(spacing: 32) {
                Box(.view, title: "ProfileView")
                Box(.model, title: "ProfileModel")
            }
            .boxStyle(.classType)
            Row(spacing: 32) {
                Box(.settings, title: "Settings")
                    .boxStyle(.structType)
                Box(.user, title: "User")
                    .boxStyle(converted ? .structType : .classType)
                Box(.point, title: "Point")
                    .boxStyle(.structType)
            }
            Row(spacing: 32) {
                Empty()
                Box(.identifiable, title: "Identifiable")
                Empty()
            }
        }
    }

    var lines: [Line] {
        Line(from: .view, to: .model, style: .dependency)
        Line(from: .model, to: .settings, .user)
        Line(from: .user, to: .point)
        Line(from: .settings, .user, to: .identifiable, style: .conformance)
    }
}

#Preview {
    SlidePreview(slide: FigureStyles())
}
