import SwiftUI

/// Identifies each slide's grid cell for the overview's matched-geometry transition.
///
/// `inactive` ids pair with nothing: they neutralize the effect while the
/// overview is fully closed, so normal slide navigation never touches
/// matched-geometry bookkeeping.
enum OverviewMatchID: Hashable {
    case slide(Int)
    case inactive(Int)
}

/// The grid overview presented on a deck surface.
struct DeckOverviewView<T: Deck>: View {
    let controller: DeckController
    let namespace: Namespace.ID
    let onSelect: (Int) -> Void

    private let columnCount = 4

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(
                    columns: [GridItem](
                        repeating: GridItem(.flexible(), spacing: 64),
                        count: columnCount
                    ),
                    spacing: 64
                ) {
                    ForEach(0..<controller.slideCount, id: \.self) { index in
                        CellView(
                            index: index,
                            isCurrent: index == controller.slideNumber,
                            image: controller.thumbnails[index],
                            namespace: namespace,
                            isSource: controller.isOverviewPresented,
                            onSelect: onSelect
                        )
                        .id(index)
                    }
                }
                .padding(64)
            }
            .onAppear {
                proxy.scrollTo(controller.slideNumber, anchor: .center)
            }
            .onChange(of: controller.isOverviewPresented) { _, isPresented in
                // Jump to the current slide the moment the overview engages.
                if isPresented {
                    proxy.scrollTo(controller.slideNumber, anchor: .center)
                }
            }
            .onChange(of: controller.slideNumber) { _, newValue in
                // The grid stays mounted while presenting; never do scroll
                // work unless the overview is actually on screen.
                guard controller.isOverviewPresented else {
                    return
                }
                withAnimation(.spring(duration: 0.35)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .background(
            Color(T.deckStyle.colorStyle.backgroundColor).opacity(0.92)
        )
    }

}

/// A single grid cell.
///
/// Extracted as a struct so it only re-evaluates when its own inputs change,
/// not when another cell's `isCurrent` flips.
private struct CellView: View {
    let index: Int
    let isCurrent: Bool
    let image: NSImage?
    let namespace: Namespace.ID
    let isSource: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        Button {
            onSelect(index)
        } label: {
            Group {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                }
                else {
                    Color.gray
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            }
            .overlay(alignment: .bottomLeading) {
                Text("\(index + 1)")
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(10)
            }
            .shadow(radius: 8, y: 4)
            .overlay(alignment: .bottom) {
                if isCurrent {
                    Text("・")
                        .font(.system(size: 48))
                        .foregroundStyle(.black)
                        .offset(y: 48)
                }
            }
            .matchedGeometryEffect(
                id: isSource ? OverviewMatchID.slide(index) : OverviewMatchID.inactive(index),
                in: namespace,
                isSource: isSource
            )
        }
        .buttonStyle(.plain)
    }
}
