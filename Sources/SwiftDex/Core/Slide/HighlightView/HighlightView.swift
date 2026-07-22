import SwiftUI

struct HighlightView: View {
    @EnvironmentObject private var elementAnchors: ElementAnchors

    var body: some View {
        GeometryReader { proxy in
            ActionStepper(Highlight.self, count: 1) { progress in
                overlayView(for: progress, proxy: proxy)
            } animation: { _ in
                .linear
            }
        }
    }
}

private extension HighlightView {
    // The overlay is always in the hierarchy and driven by opacity, so both its
    // appearance and disappearance animate reliably.
    func overlayView(for progress: ActionProgress<Highlight>, proxy: GeometryProxy) -> some View {
        let color = progress.current?.mode.color
        let targetRect = targetRect(for: progress, proxy: proxy)

        return ZStack {
            Color(color ?? .black)
            RoundedRectangle(cornerRadius: 20)
                .frame(
                    width: (targetRect?.width ?? 0) + 40,
                    height: (targetRect?.height ?? 0) + 40
                )
                .position(
                    x: targetRect?.midX ?? 0,
                    y: targetRect?.midY ?? 0
                )
                // The cutout must snap to its target; only the fade (the opacity
                // below) is meant to animate.
                .transaction { $0.animation = nil }
                .blur(radius: 10)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
        .opacity(color != nil && targetRect != nil ? 1 : 0)
        .allowsHitTesting(false)
    }

    func targetRect(for progress: ActionProgress<Highlight>, proxy: GeometryProxy) -> CGRect? {
        // Resolved via `nearestAction` so the cutout keeps its position during
        // the fade-out after the action has passed.
        guard let target = progress.nearestAction?.target,
            let anchor = elementAnchors.value[target]
        else {
            return nil
        }
        return proxy[anchor]
    }
}

private extension Highlight.Mode {
    var color: NSColor {
        switch self {
        case .light:
            .white.withAlphaComponent(0.7)
        case .dark:
            .black.withAlphaComponent(0.7)
        }
    }
}
