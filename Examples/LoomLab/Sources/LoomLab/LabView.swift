import Loom
import SwiftUI

/// The lab's one window: a scenario's figure, ways to play it, and what the
/// frame meter saw.
struct LabView: View {
    /// Whether to play every way of appearing in turn, print what the meter
    /// saw, and quit.
    let autoplay: Bool

    @State private var scenarioName = Scenario.all[0].name
    @State private var step = 0
    @State private var appear = AppearMode.phasedEarly
    @State private var motion = Motion.bouncy
    @State private var meter = FrameMeter()
    @State private var playing = false

    private var scenario: Scenario {
        Scenario.all.first { $0.name == scenarioName } ?? Scenario.all[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            scenario.figure(step)
                .modifier(Appearing(mode: appear))
                .figureScale(2)
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)

            Divider()

            controls
                .padding()
        }
        .frame(minWidth: 640, minHeight: 760)
        .task {
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

    /// What to play on one row, and playing it on the next, so that neither
    /// is squeezed when the window is narrow.
    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Picker("Scenario", selection: $scenarioName) {
                    ForEach(Scenario.all) { Text($0.name).tag($0.id) }
                }
                .fixedSize()

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
                .disabled(playing)

                Spacer(minLength: 16)

                Text(meter.reading.map(String.init(describing:)) ?? "Play to measure")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
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
        for next in 1...scenario.steps {
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
