//
//  MemoryUsageTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Darwin
import Testing

@testable import Menutop

@Test func usedIsAppMemoryPlusWiredPlusCompressed() {
    var statistics = vm_statistics64()
    statistics.internal_page_count = 1_000
    statistics.purgeable_count = 200
    statistics.wire_count = 300
    statistics.compressor_page_count = 100

    let usage = MemoryUsage(
        statistics: statistics,
        pageSize: 16_384,
        totalBytes: 1 << 35,
        swapUsedBytes: 0
    )

    #expect(usage.usedBytes == 1_200 * 16_384)
}

@Test func purgeableAboveInternalDoesNotUnderflow() {
    var statistics = vm_statistics64()
    statistics.internal_page_count = 100
    statistics.purgeable_count = 200
    statistics.wire_count = 10

    let usage = MemoryUsage(
        statistics: statistics,
        pageSize: 1,
        totalBytes: 1_000,
        swapUsedBytes: 0
    )

    #expect(usage.usedBytes == 10)
}
