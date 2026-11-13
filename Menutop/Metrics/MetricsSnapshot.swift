//
//  MetricsSnapshot.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

/// Every metric the window shows, read at one moment. Nil where a value could not be read.
struct MetricsSnapshot: Equatable, Sendable {

    /// Nothing read yet.
    static let empty = MetricsSnapshot()

    /// Busy share of the performance cores, 0 to 1.
    var performanceLoad: Double?
    /// Busy share of the efficiency cores, 0 to 1.
    var efficiencyLoad: Double?
    /// Busy share of the GPU, 0 to 1.
    var gpuLoad: Double?
    var memory: MemoryUsage?
    /// The whole system's power, in watts.
    var systemPower: Double?
    /// Mean of the CPU core sensors, in °C.
    var cpuTemperature: Double?
    /// Mean of the GPU sensors, in °C.
    var gpuTemperature: Double?
}
