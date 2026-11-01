import Loom
import SwiftUI

/// The lab's one window: a scenario's figure, ways to play it, and what the
/// frame meter saw.
struct LabView: View {
    /// Whether to play every way of appearing in turn, print what the meter
    /// saw, and quit.
    let autoplay: Bool

    /// Where to write the frames of the scenario played through once, before
    /// quitting — or `nil` to wait for someone to play it.
    let frames: URL?

    @State private var selection: String?
    @State private var step = 0
    @State private var appear = AppearMode.phasedEarly
    @State private var motion = Motion.bouncy
    @State private var meter = FrameMeter()
    @State private var playing = false

    /// Where the figure is in the window, for an image of the window to be
    /// cut down to it.
    @State private var canvasFrame = CGRect.zero
    @State private var saved: String?

    /// How much larger than the lab's usual size the figure is drawn.
    @State private var zoom: CGFloat = 1

    /// How far a pinch going on has magnified the figure, and about where.
    ///
    /// The figure is only magnified while the pinch lasts, and drawn at the
    /// zoom it comes to when it ends: drawn afresh at every step of the pinch,
    /// a large figure could not keep up with the fingers.
    @State private var pinch: (magnification: CGFloat, anchor: UnitPoint)?

    /// Where the pointer is over the canvas, for a pinch to magnify about
    /// and for scrolling to move the figure only while it is over it.
    ///
    /// Read from the pointer rather than from the pinch, which says where it
    /// is in its own terms.
    @State private var pointer: CGPoint?

    /// How far the figure has been moved from the middle of the canvas, in the
    /// window's points.
    @State private var pan = CGSize.zero

    /// What turns scrolling over the canvas into moving the figure.
    @State private var scrollMonitor: Any?

    init(scenario: String?, autoplay: Bool, frames: URL?) {
        self.autoplay = autoplay
        self.frames = frames
        _selection = State(initialValue: Scenario.all.first { $0.name == scenario }?.name ?? Scenario.all[0].name)
    }

    private var scenario: Scenario {
        Scenario.all.first { $0.name == selection } ?? Scenario.all[0]
    }

    var body: some View {
        NavigationSplitView {
            List(Scenario.all, selection: $selection) { scenario in
                Text(scenario.name)
                    .tag(scenario.name)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 200)
        } detail: {
            VStack(spacing: 0) {
                canvas

                Divider()

                controls
                    .padding()
            }
        }
        .frame(minWidth: 800, minHeight: 760)
        .onChange(of: selection) {
            step = 0
            // Each figure is looked at from its usual size first.
            actualSize()
        }
        .task {
            if let frames {
                await writeFrames(to: frames)
                NSApp.terminate(nil)
                return
            }
            guard autoplay else {
                return
            }
            for mode in AppearMode.allCases {
                appear = mode
                let reading = await play()
                print("\(scenario.name) — \(mode.rawValue), \(motion.rawValue): \(reading)")
            }
            NSApp.terminate(nil)
        }
    }

    /// The figure, in a space it can be moved and pinched in.
    ///
    /// However large the figure grows, it never asks the window for more room:
    /// it is drawn in the middle of the canvas, past its edges if need be, and
    /// moved by scrolling. The canvas is not a scroll view, which could not be
    /// scrolled past its content: a figure zoomed about a point beside it would
    /// jump back when the zoom ended.
    ///
    /// Zooming draws the figure at another scale rather than magnifying it,
    /// so that its words stay sharp at any size.
    private var canvas: some View {
        scenario.figure(step)
            .modifier(Appearing(mode: appear))
            .figureScale(Self.scale * zoom)
            .offset(pan)
            .scaleEffect(pinch?.magnification ?? 1, anchor: pinch?.anchor ?? .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location): pointer = location
                case .ended: pointer = nil
                }
            }
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        // Magnified about the point the pointer was over when
                        // the pinch started, held to the zooms there are.
                        let size = canvasFrame.size
                        let point = pointer ?? CGPoint(x: size.width / 2, y: size.height / 2)
                        let anchor = pinch?.anchor ?? UnitPoint(x: point.x / size.width, y: point.y / size.height)
                        let next = min(max(zoom * value.magnification, Self.zooms.lowerBound), Self.zooms.upperBound)
                        pinch = (next / zoom, anchor)
                    }
                    .onEnded { _ in
                        guard let pinch else {
                            return
                        }
                        self.pinch = nil
                        let size = canvasFrame.size
                        zoom(
                            to: zoom * pinch.magnification,
                            around: CGPoint(x: pinch.anchor.x * size.width, y: pinch.anchor.y * size.height)
                        )
                    }
            )
            .onAppear {
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    guard pointer != nil else {
                        return event
                    }
                    // A mouse's wheel scrolls by lines, a trackpad by points.
                    let points: CGFloat = event.hasPreciseScrollingDeltas ? 1 : 10
                    pan.width += event.scrollingDeltaX * points
                    pan.height += event.scrollingDeltaY * points
                    return nil
                }
            }
            .onDisappear {
                scrollMonitor.map(NSEvent.removeMonitor)
            }
            .background(.white)
            .background(FrameMeter.Ticks(meter: meter))
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: {
                canvasFrame = $0
            }
    }

    /// What to play on one row, and playing it on the next, so that neither
    /// is squeezed when the window is narrow.
    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Picker("Appear", selection: $appear) {
                    ForEach(AppearMode.allCases) { Text($0.rawValue).tag($0) }
                }
                .fixedSize()

                Picker("Animation", selection: $motion) {
                    ForEach(Motion.allCases) { Text($0.rawValue).tag($0) }
                }
                .fixedSize()
            }

            HStack(spacing: 12) {
                Button("Back") { change(to: step - 1) }
                    .disabled(playing || step == 0)
                Text("\(step) / \(scenario.steps)")
                    .monospacedDigit()
                Button("Next") { change(to: step + 1) }
                    .disabled(playing || step == scenario.steps)
                Button("Play") {
                    Task { await play() }
                }
                .disabled(playing || scenario.steps == 0)

                Button("Save Image") { saveImage() }
                    .help("Save the figure as it is this instant, mid-animation or not")

                zoomControls

                Spacer(minLength: 16)

                Text(saved ?? meter.reading.map(String.init(describing:)) ?? "Play to measure")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    /// Zooming out and in, and back to the usual size.
    ///
    /// There is no zooming to fit: a figure is a different size at every
    /// step, so a zoom that fits one would not fit the next.
    private var zoomControls: some View {
        HStack(spacing: 4) {
            Button {
                zoom(to: zoom / Self.zoomStep)
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .keyboardShortcut("-")
            .help("Zoom out (⌘−)")

            Text("\(Int((zoom * (pinch?.magnification ?? 1) * 100).rounded()))%")
                .monospacedDigit()
                .frame(minWidth: 44)

            Button {
                zoom(to: zoom * Self.zoomStep)
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .keyboardShortcut("+")
            .help("Zoom in (⌘+)")

            Button("Actual Size") { actualSize() }
                .keyboardShortcut("0")
                .disabled(zoom == 1 && pan == .zero)
                .help("Back to the usual size, in the middle (⌘0)")
        }
        // ⌘= as well as ⌘+, as other apps take it, since + needs Shift on
        // most keyboards.
        .background {
            Button("") { zoom(to: zoom * Self.zoomStep) }
                .keyboardShortcut("=")
                .hidden()
        }
    }

    /// The figure's scale at the usual size, larger than its own so that it
    /// can be looked at closely.
    private static let scale: CGFloat = 2

    private static let zoomStep: CGFloat = 1.25
    private static let zooms: ClosedRange<CGFloat> = 0.5...3

    /// Draws the figure at another zoom, keeping the part of it at `anchor`
    /// on the canvas — the middle, unless a pinch says where — where it is.
    private func zoom(to next: CGFloat, around anchor: CGPoint? = nil) {
        let next = min(max(next, Self.zooms.lowerBound), Self.zooms.upperBound)
        let size = canvasFrame.size
        let anchor = anchor ?? CGPoint(x: size.width / 2, y: size.height / 2)
        // The figure is drawn about the middle of the canvas, moved by the
        // pan: what is at the anchor is that far from the figure's middle,
        // and will be farther by the change in zoom.
        let ratio = next / zoom
        let fromMiddle = CGSize(width: anchor.x - size.width / 2, height: anchor.y - size.height / 2)
        pan = CGSize(
            width: fromMiddle.width - (fromMiddle.width - pan.width) * ratio,
            height: fromMiddle.height - (fromMiddle.height - pan.height) * ratio
        )
        zoom = next
    }

    /// The figure at the usual size, in the middle of the canvas.
    private func actualSize() {
        zoom = 1
        pan = .zero
    }

    /// The figure as it is on screen this instant, as a PNG.
    private func image() -> Data? {
        guard let window = NSApp.windows.first(where: { $0.isVisible && $0.contentView != nil }) else {
            return nil
        }
        return WindowCapture.png(of: window, in: canvasFrame)
    }

    /// Saves the figure as it is this instant to the Desktop — in the middle
    /// of an animation, if one is playing.
    private func saveImage() {
        let stamp = Date.now.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().second().secondFraction(.fractional(3)))
        let name = "Loom Lab \(scenario.name) \(step) \(stamp).png".replacingOccurrences(of: ":", with: ".")
        let file = URL.desktopDirectory.appending(path: name)
        guard let png = image(), (try? png.write(to: file)) != nil else {
            saved = "Could not save an image"
            return
        }
        saved = "Saved \(name) to the Desktop"
        print(file.path)
    }

    /// Plays the scenario through once, writing the figure to images as often
    /// as the window can be captured — a dozen or so times a second — named
    /// by the step and how far into it they were taken: a way to look at an
    /// animation frame by frame without anyone watching it.
    private func writeFrames(to folder: URL) async {
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        catch {
            print(error)
            return
        }
        // Long enough for the window to be up and drawn.
        try? await Task.sleep(for: .seconds(1))

        for next in stride(from: 1, through: scenario.steps, by: 1) {
            change(to: next)
            let start = ContinuousClock.now
            // As long as playing waits between steps.
            while ContinuousClock.now - start < .seconds(1.6) {
                let elapsed = (ContinuousClock.now - start).components
                let milliseconds = Int(elapsed.seconds) * 1000 + Int(elapsed.attoseconds / 1_000_000_000_000_000)
                let file = folder.appending(path: String(format: "step %d, %04d ms.png", next, milliseconds))
                guard let png = image() else {
                    print("Could not capture the window")
                    return
                }
                try? png.write(to: file)
                // Captured on the main actor, so it has to give way for the
                // animation to get a frame further along before the next.
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
        print(folder.path)
    }

    private func change(to next: Int) {
        withAnimation(motion.animation) {
            step = next
        }
    }

    /// Plays the scenario from the start, measuring every frame on the way.
    @discardableResult
    private func play() async -> FrameMeter.Reading {
        playing = true
        defer { playing = false }

        step = 0
        try? await Task.sleep(for: .seconds(0.5))

        meter.start()
        for next in stride(from: 1, through: scenario.steps, by: 1) {
            change(to: next)
            // Long enough for lines appearing in phases to finish too.
            try? await Task.sleep(for: .seconds(1.6))
        }
        return meter.stop()
    }
}

/// The ways a figure can be asked to appear.
enum AppearMode: String, CaseIterable, Identifiable {
    case allAtOnce = "All at once"
    case phased = "Phased"
    case phasedEarly = "Phased, lines from 0.8"

    var id: Self {
        self
    }
}

/// A figure asked to appear one of the lab's ways.
private struct Appearing: ViewModifier {
    let mode: AppearMode

    func body(content: Content) -> some View {
        switch mode {
        case .allAtOnce:
            content
        case .phased:
            content.figureAnimation(.phased)
        case .phasedEarly:
            content.figureAnimation(.phased(linesFrom: 0.8))
        }
    }
}

/// The animations the lab changes a figure in.
enum Motion: String, CaseIterable, Identifiable {
    case bouncy = "Bouncy 0.8s"
    case easeInOut = "Ease in-out 0.6s"
    case none = "None"

    var id: Self {
        self
    }

    var animation: Animation? {
        switch self {
        case .bouncy: .bouncy(duration: 0.8)
        case .easeInOut: .easeInOut(duration: 0.6)
        case .none: nil
        }
    }
}
