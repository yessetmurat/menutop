//
//  CoreKind.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Foundation
import IOKit

/// The kind of a CPU core on Apple Silicon.
enum CoreKind: Equatable {

    case performance
    case efficiency
    /// A kind this app does not show, such as a cluster type a newer chip adds.
    case other

    /// The kind named by a core's `cluster-type` property in the device tree.
    init(clusterType: String) {
        switch clusterType {
        case "P": self = .performance
        case "E": self = .efficiency
        default: self = .other
        }
    }

    /// The kind of every logical CPU, indexed by CPU number, from the `cpuN` nodes of the
    /// device tree. Empty when the device tree cannot be read.
    static func readAll() -> [CoreKind] {
        let cpus = IORegistryEntryFromPath(kIOMainPortDefault, "IODeviceTree:/cpus")
        guard cpus != IO_OBJECT_NULL else {
            return []
        }
        defer { IOObjectRelease(cpus) }

        var iterator: io_iterator_t = 0
        guard IORegistryEntryGetChildIterator(cpus, kIODeviceTreePlane, &iterator) == KERN_SUCCESS else {
            return []
        }
        defer { IOObjectRelease(iterator) }

        var kinds: [Int: CoreKind] = [:]
        while case let entry = IOIteratorNext(iterator), entry != IO_OBJECT_NULL {
            if let index = cpuNumber(of: entry) {
                kinds[index] = CoreKind(clusterType: clusterType(of: entry) ?? "")
            }
            IOObjectRelease(entry)
        }

        return kinds.keys.sorted().map { kinds[$0] ?? .other }
    }

    /// N of a node named `cpuN`.
    private static func cpuNumber(of entry: io_registry_entry_t) -> Int? {
        var name = [CChar](repeating: 0, count: MemoryLayout<io_name_t>.size)
        guard IORegistryEntryGetName(entry, &name) == KERN_SUCCESS else {
            return nil
        }

        let text = String(cString: name)
        guard text.hasPrefix("cpu") else {
            return nil
        }

        return Int(text.dropFirst(3))
    }

    /// The `cluster-type` property, stored as a C string such as `"E\0"`.
    private static func clusterType(of entry: io_registry_entry_t) -> String? {
        let property = IORegistryEntryCreateCFProperty(
            entry,
            "cluster-type" as CFString,
            kCFAllocatorDefault,
            0
        )
        guard let data = property?.takeRetainedValue() as? Data else {
            return nil
        }

        return String(decoding: data.prefix { $0 != 0 }, as: UTF8.self)
    }
}
