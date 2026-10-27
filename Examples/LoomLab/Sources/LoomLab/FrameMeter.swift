import Observation
import SwiftUI

/// Counts the frames the screen shows while something plays, and how many of
/// them came late.
///
/// A frame is late when the main thread was too busy to be ready for it, so
/// this measures the work a figure does on the main thread — layout, routing,
/// building views. It cannot see the render server falling behind.
///
/// It is told of each frame by ``FrameMeter/Ticks``, a timeline that runs only
/// while the meter counts. A display link would do the same, but one made under
/// the SwiftUI app lifecycle never fires. Nothing is published while it counts:
/// updating the screen on every frame would add the very work it measures.
@MainActor
@Observable
final class FrameMeter {
    /// What one run of the meter saw.
    struct Reading: CustomStringConvertible {
        var frames = 0
        var late = 0
        var worst: Double = 0

        var description: String {
            "\(frames) frames, \(late) late, worst \(String(format: "%.1f", worst)) ms"
        }
    }

    /// The reading from the last run, once it has stopped.
    private(set) var reading: Reading?

    /// Whether the meter is counting, which is what keeps its timeline running.
    private(set) var counting = false

    @ObservationIgnored private var current = Reading()
    @ObservationIgnored private var last: Date?

    /// The longest a frame may take and still count as on time, in
    /// milliseconds — a little over one frame at 60 Hz.
    private let lateAfter: Double = 20

    func start() {
        current = Reading()
        last = nil
        counting = true
    }

    @discardableResult
    func stop() -> Reading {
        counting = false
        reading = current
        return current
    }

    /// Notes that the screen showed a frame at `date`.
    func frame(at date: Date) {
        guard counting else {
            return
        }
        defer { last = date }
        guard let last else {
            return
        }
        let gap = date.timeIntervalSince(last) * 1000
        current.frames += 1
        if gap > lateAfter {
            current.late += 1
        }
        current.worst = max(current.worst, gap)
    }

    /// An invisible view that tells the meter of every frame while it counts.
    struct Ticks: View {
        let meter: FrameMeter

        var body: some View {
            TimelineView(.animation(paused: !meter.counting)) { context in
                let _ = meter.frame(at: context.date)
                Color.clear
                    .frame(width: 0, height: 0)
            }
        }
    }
}
