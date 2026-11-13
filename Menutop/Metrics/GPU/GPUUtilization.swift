//
//  GPUUtilization.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Foundation
import IOKit

/// The GPU's busy share, as the GPU driver reports it.
enum GPUUtilization {

    /// `Device Utilization %` of the first `IOAccelerator` as a fraction from 0 to 1, or nil
    /// when there is no such service or property.
    static func read() -> Double? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOAccelerator"))
        guard service != IO_OBJECT_NULL else {
            return nil
        }
        defer { IOObjectRelease(service) }

        let property = IORegistryEntryCreateCFProperty(
            service,
            "PerformanceStatistics" as CFString,
            kCFAllocatorDefault,
            0
        )
        guard let statistics = property?.takeRetainedValue() as? [String: Any],
              let percent = statistics["Device Utilization %"] as? Int else {
            return nil
        }

        return Double(percent) / 100
    }
}
