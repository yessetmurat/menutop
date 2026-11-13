//
//  MetricsReader.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

/// Reads every source into a snapshot, off the main thread. Loads are measured between two
/// reads, so the first read leaves them empty.
actor MetricsReader {

    private let coreKinds = CoreKind.readAll()
    private let smc = SMCConnection()
    private let sensors: SMCSensors?
    private var previousTicks: [CoreTicks]?

    init() {
        sensors = smc.map { SMCSensors(keys: $0.keys()) }
    }

    /// Every metric now.
    func read() -> MetricsSnapshot {
        let ticks = CoreTicks.readAll()
        let load = ClusterLoad(previous: previousTicks, current: ticks, kinds: coreKinds)
        previousTicks = ticks

        let reading = smc.flatMap { connection in sensors?.read(from: connection) }

        return MetricsSnapshot(
            performanceLoad: load.performance,
            efficiencyLoad: load.efficiency,
            gpuLoad: GPUUtilization.read(),
            memory: MemoryUsage.read(),
            systemPower: reading?.systemPower,
            cpuTemperature: reading?.cpuTemperature,
            gpuTemperature: reading?.gpuTemperature
        )
    }
}
