import SwiftUI

/// Keeps track of which finish of the nodes' phase each line is waiting for,
/// when a figure appears in phases.
///
/// Every change that brings in new lines starts a nodes' phase, and the lines
/// it brought in wait for that phase to finish. Phases are numbered as they
/// start; ``FigureView`` counts how many have finished, and a line is shown
/// once the count reaches its number.
///
/// A reference, so that keeping track does not count as a change to the
/// figure: it happens while a change is being made, when the figure's own
/// state must not be touched.
@MainActor
final class LinePhaseTracker {
    private var waits: [DrawnLineID: Int] = [:]
    private var latest = 0
    private var unannounced = false
    private var early: (phase: Int, animation: Animation?)?

    /// Notes the lines the figure has now, and has any that are new wait for
    /// the next phase to finish.
    func note(_ lines: [DrawnLineID]) {
        let new = lines.filter { waits[$0] == nil }
        waits = waits.filter { lines.contains($0.key) }
        guard !new.isEmpty else {
            return
        }
        latest += 1
        unannounced = true
        for line in new {
            waits[line] = latest
        }
    }

    /// The phase `line` waits for.
    func phase(for line: DrawnLineID) -> Int {
        waits[line] ?? 0
    }

    /// The phase the change being made has to announce the finish of, if it
    /// has brought in new lines and nobody has taken it on yet.
    func takeUnannounced() -> Int? {
        guard unannounced else {
            return nil
        }
        unannounced = false
        return latest
    }

    /// Has the lines waiting for `phase` shown early, in `animation`, should
    /// the nodes come far enough before they settle.
    func showEarly(_ phase: Int, in animation: Animation?) {
        early = (phase, animation)
    }

    /// The phase to show early now, if there is one not yet shown.
    func takeEarly() -> (phase: Int, animation: Animation?)? {
        defer { early = nil }
        return early
    }
}
