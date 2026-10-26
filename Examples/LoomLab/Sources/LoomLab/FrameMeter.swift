import AppKit
import Observation

/// Counts the frames the screen shows while something plays, and how many of
/// them came late.
///
/// A frame is late when the main thread was too busy to be ready for it, so
/// this measures the work a figure does on the main thread — layout, routing,
/// building views. It cannot see the render server falling behind.
///
/// Nothing is published while it counts: updating the screen on every frame
/// would add the very work it is trying to measure.
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

    @ObservationIgnored private var link: CADisplayLink?
    @ObservationIgnored private var counting = Reading()
    @ObservationIgnored private var last: CFTimeInterval = 0

    /// The longest a frame may take and still count as on time, in
    /// milliseconds — a little over one frame at 60 Hz.
    private let lateAfter: Double = 20

    func start() {
        stop()
        counting = Reading()
        last = 0
        guard let screen = NSScreen.main else {
            return
        }
        let link = screen.displayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    @discardableResult
    func stop() -> Reading {
        link?.invalidate()
        link = nil
        reading = counting
        return counting
    }

    @objc private func tick(_ link: CADisplayLink) {
        defer { last = link.timestamp }
        guard last > 0 else {
            return
        }
        let gap = (link.timestamp - last) * 1000
        counting.frames += 1
        if gap > lateAfter {
            counting.late += 1
        }
        counting.worst = max(counting.worst, gap)
    }
}
