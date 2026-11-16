//
//  BatteryHealth.swift
//  Menutop
//
//  Created by Yesset Murat on 16.11.2026.
//

import Foundation
import IOKit

/// How worn the battery is, as the battery's gauge reports it. Nil where a value could not be
/// read.
struct BatteryHealth: Equatable, Sendable {

    /// Full charge cycles so far.
    var cycleCount: Int?
    /// Nominal charge capacity as a share of the design capacity, 0 to 1, the number System
    /// Settings shows as Maximum Capacity.
    var maximumCapacity: Double?
}

extension BatteryHealth {

    private static let readKeys = ["CycleCount", "BatteryData"]

    /// Takes the values from the `AppleSmartBattery` properties: `CycleCount` at the top level,
    /// the capacities inside `BatteryData`. Each value that is missing or not a real one stays
    /// nil. The share is rounded up to a whole percent; a new battery can hold more than its
    /// design, so it stops at 1.
    init(properties: [String: Any]) {
        let batteryData = properties["BatteryData"] as? [String: Any]

        if let cycleCount = properties["CycleCount"] as? Int, cycleCount >= 0 {
            self.cycleCount = cycleCount
        }

        if let nominalCapacity = batteryData?["NominalChargeCapacity"] as? Int,
           let designCapacity = batteryData?["DesignCapacity"] as? Int,
           nominalCapacity >= 0,
           designCapacity > 0 {
            // Workaround: no API gives the Maximum Capacity percent System Settings shows. On
            // macOS 27 it matches the share rounded up to a whole percent (8105 of 8579 shows
            // 95 %), so the same rounding is done here, in integers so a whole percent stays
            // whole. A macOS that rounds otherwise can differ by 1 %.
            let percent = (nominalCapacity * 100 + designCapacity - 1) / designCapacity
            maximumCapacity = Double(min(percent, 100)) / 100
        }
    }

    /// The battery now, or nil on a Mac without one.
    static func read() -> BatteryHealth? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != IO_OBJECT_NULL else {
            return nil
        }
        defer { IOObjectRelease(service) }

        var properties: [String: Any] = [:]
        for key in readKeys {
            properties[key] = IORegistryEntryCreateCFProperty(
                service,
                key as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue()
        }

        return BatteryHealth(properties: properties)
    }
}
