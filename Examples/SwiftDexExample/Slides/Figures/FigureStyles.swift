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
            "**`NodeStyle`** and **`LineStyle`** belong to the figure, not to the node's identity."
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
            FigureView(Types(converted: converted(progress)), spacing: 14 * slideFigureRatio, routing: .orthogonal)
                .nodeStyle(.standard.onSlide())
                .lineStyle(.rounded)
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

private extension NodeStyle {
    static let classType = NodeStyle(
        fill: Color(red: 0.88, green: 0.93, blue: 1.0),
        stroke: Color(red: 0.2, green: 0.4, blue: 0.85),
        strokeWidth: 2
    )
    .onSlide()

    static let structType = NodeStyle(
        shape: .roundedRectangle(cornerRadius: 3),
        fill: Color(red: 1.0, green: 0.93, blue: 0.85),
        stroke: Color(red: 0.85, green: 0.45, blue: 0.1),
        strokeWidth: 2,
        fontWeight: .semibold
    )
    .onSlide()
}

private extension LineStyle {
    /// Every line in the figure turns its corners the same way.
    static let rounded = LineStyle(cornerRadius: 11).onSlide()

    /// Conformance to a protocol, the way UML draws realization.
    static let conformance = LineStyle(cornerRadius: 11, dash: [7, 4], arrowHead: .hollow).onSlide()

    /// A use that is not ownership.
    static let dependency = LineStyle(cornerRadius: 11, dash: [7, 4], arrowHead: .open).onSlide()
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
        Column(spacing: 56 * slideFigureRatio) {
            Row(spacing: 44 * slideFigureRatio) {
                TextNode(.view, title: "ProfileView")
                TextNode(.model, title: "ProfileModel")
            }
            .nodeStyle(.classType)
            Row(spacing: 44 * slideFigureRatio) {
                TextNode(.settings, title: "Settings")
                    .nodeStyle(.structType)
                TextNode(.user, title: "User")
                    .nodeStyle(converted ? .structType : .classType)
                TextNode(.point, title: "Point")
                    .nodeStyle(.structType)
            }
            Row(spacing: 44 * slideFigureRatio) {
                Empty()
                TextNode(.identifiable, title: "Identifiable")
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
