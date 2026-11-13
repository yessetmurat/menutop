//
//  CoreTicks.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Darwin

/// The time one logical CPU has spent busy and idle since boot, in scheduler ticks.
struct CoreTicks: Equatable {

    var busy: UInt64
    var idle: UInt64

    /// The ticks of every logical CPU, indexed by CPU number, or nil when the kernel does
    /// not answer.
    static func readAll() -> [CoreTicks]? {
        var cpuCount: natural_t = 0
        var info: processor_info_array_t?
        var infoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &cpuCount,
            &info,
            &infoCount
        )
        guard result == KERN_SUCCESS, let info else {
            return nil
        }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: info),
                vm_size_t(infoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            )
        }

        return (0..<Int(cpuCount)).map { cpu in
            let base = cpu * Int(CPU_STATE_MAX)
            let tick = { (state: Int32) in UInt64(UInt32(bitPattern: info[base + Int(state)])) }

            return CoreTicks(
                busy: tick(CPU_STATE_USER) + tick(CPU_STATE_SYSTEM) + tick(CPU_STATE_NICE),
                idle: tick(CPU_STATE_IDLE)
            )
        }
    }
}
