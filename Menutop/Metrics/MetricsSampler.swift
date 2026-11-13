//
//  MetricsSampler.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Observation

/// Publishes a fresh snapshot every second while the window runs it.
@MainActor
@Observable
final class MetricsSampler {

    private static let interval = Duration.seconds(1)

    private(set) var snapshot = MetricsSnapshot.empty

    /// One reader for the app's life, so loads on reopening are measured from the last read
    /// instead of starting over with nothing to compare against.
    @ObservationIgnored private var reader: MetricsReader?

    /// Reads and publishes once per second until the calling task is cancelled. The last
    /// snapshot stays on screen until the first new read replaces it.
    func run() async {
        let reader = reader ?? MetricsReader()
        self.reader = reader

        while !Task.isCancelled {
            snapshot = await reader.read()
            try? await Task.sleep(for: Self.interval)
        }
    }
}
