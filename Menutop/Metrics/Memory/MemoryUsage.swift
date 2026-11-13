//
//  MemoryUsage.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Darwin

/// How much memory and swap is in use, in bytes.
struct MemoryUsage: Equatable {

    var usedBytes: UInt64
    var totalBytes: UInt64
    var swapUsedBytes: UInt64

    /// Used memory as Activity Monitor counts it: app memory (anonymous pages that are not
    /// purgeable) plus wired plus compressed.
    init(
        statistics: vm_statistics64,
        pageSize: UInt64,
        totalBytes: UInt64,
        swapUsedBytes: UInt64
    ) {
        let internalPages = UInt64(statistics.internal_page_count)
        let purgeablePages = UInt64(statistics.purgeable_count)
        let appPages = internalPages - min(purgeablePages, internalPages)
        let usedPages = appPages + UInt64(statistics.wire_count) + UInt64(statistics.compressor_page_count)

        self.usedBytes = usedPages * pageSize
        self.totalBytes = totalBytes
        self.swapUsedBytes = swapUsedBytes
    }

    /// The machine's memory and swap now, or nil when the kernel does not answer.
    static func read() -> MemoryUsage? {
        var statistics = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        var pageSize: vm_size_t = 0

        let result = withUnsafeMutablePointer(to: &statistics) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count
                )
            }
        }
        guard result == KERN_SUCCESS,
              host_page_size(mach_host_self(), &pageSize) == KERN_SUCCESS,
              let totalBytes: UInt64 = sysctlValue("hw.memsize"),
              let swap: xsw_usage = sysctlValue("vm.swapusage") else {
            return nil
        }

        return MemoryUsage(
            statistics: statistics,
            pageSize: UInt64(pageSize),
            totalBytes: totalBytes,
            swapUsedBytes: swap.xsu_used
        )
    }

    private static func sysctlValue<Value>(_ name: String) -> Value? {
        var value = [UInt8](repeating: 0, count: MemoryLayout<Value>.size)
        var size = value.count
        let result = sysctlbyname(
            name,
            &value,
            &size,
            nil,
            0
        )
        guard result == 0, size == value.count else {
            return nil
        }

        return value.withUnsafeBytes { $0.loadUnaligned(as: Value.self) }
    }
}
