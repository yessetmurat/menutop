//
//  SMCSensors.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

/// The SMC keys this app reads: CPU and GPU temperature sensors and the system's power.
struct SMCSensors {

    /// What the sensors read at one moment; nil where no key gave a valid value.
    struct Reading: Equatable {

        var cpuTemperature: Double?
        var gpuTemperature: Double?
        var systemPower: Double?
    }

    private static let cpuPrefixes = ["Tp", "Te", "Tf"]
    private static let gpuPrefixes = ["Tg"]
    private static let systemPowerKey = "PSTR"
    private static let maximumTemperature = 150.0

    /// CPU core temperature keys (`Tp`, `Te`, `Tf`), in the SMC's order.
    let cpuKeys: [String]
    /// GPU temperature keys (`Tg`), in the SMC's order.
    let gpuKeys: [String]

    /// Picks the sensors out of every key the SMC has.
    init(keys: [String]) {
        cpuKeys = keys.filter { key in Self.cpuPrefixes.contains { key.hasPrefix($0) } }
        gpuKeys = keys.filter { key in Self.gpuPrefixes.contains { key.hasPrefix($0) } }
    }

    /// The mean of the readings that are real temperatures: above 0 and below 150 °C. A
    /// sensor that is off reads 0, and some keys hold junk.
    static func average(_ readings: [Double?]) -> Double? {
        let valid = readings.compactMap { $0 }.filter { $0 > 0 && $0 < maximumTemperature }
        guard !valid.isEmpty else {
            return nil
        }

        return valid.reduce(0, +) / Double(valid.count)
    }

    /// Reads every sensor once.
    func read(from connection: SMCConnection) -> Reading {
        Reading(
            cpuTemperature: Self.average(cpuKeys.map { connection.read($0)?.number }),
            gpuTemperature: Self.average(gpuKeys.map { connection.read($0)?.number }),
            systemPower: Self.power(connection.read(Self.systemPowerKey)?.number)
        )
    }

    /// A power reading in watts when it is a real one: finite and not negative.
    static func power(_ value: Double?) -> Double? {
        guard let value, value.isFinite, value >= 0 else {
            return nil
        }

        return value
    }
}
