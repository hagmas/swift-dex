#if DEBUG
    import SwiftUI

    private extension NodeID {
        static let viewModel = NodeID("viewModel")
        static let repository = NodeID("repository")
        static let apiClient = NodeID("apiClient")
        static let cache = NodeID("cache")
        static let sideChannel = NodeID("sideChannel")
    }

    private struct SampleFigure: Figure {
        var arrangement: some FigureElement {
            Column(spacing: 48) {
                Row(spacing: 32) {
                    Box(.viewModel, title: "ViewModel")
                    Tie(.sideChannel)
                }
                Row { Box(.repository, title: "Repository") }
                Row(spacing: 32) {
                    Box(.apiClient, title: "APIClient")
                    Box(.cache, title: "Cache (on disk)")
                }
            }
        }

        var lines: [Line] {
            Line(from: .viewModel, to: .repository)
            Line(from: .repository, to: .apiClient)
            Line(from: .repository, to: .cache)
            Line(from: .apiClient, to: .cache)
            Line(from: .viewModel, to: .cache, through: .sideChannel)
        }
    }

    #Preview("Figure") {
        FigureView(SampleFigure())
            .padding(64)
    }
#endif
