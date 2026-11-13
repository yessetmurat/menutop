//
//  SMCSensorsTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func averageDropsInvalidReadings() {
    #expect(SMCSensors.average([50, 0, -3, 200, nil, 70]) == 60)
    #expect(SMCSensors.average([0, nil]) == nil)
    #expect(SMCSensors.average([]) == nil)
}

@Test func keysSplitIntoCpuAndGpu() {
    let sensors = SMCSensors(keys: ["Tp01", "Te05", "Tf0A", "Tg0K", "TB0T", "PSTR"])

    #expect(sensors.cpuKeys == ["Tp01", "Te05", "Tf0A"])
    #expect(sensors.gpuKeys == ["Tg0K"])
}

@Test func systemPowerDropsJunk() {
    #expect(SMCSensors.power(.nan) == nil)
    #expect(SMCSensors.power(-3.2) == nil)
    #expect(SMCSensors.power(.infinity) == nil)
    #expect(SMCSensors.power(nil) == nil)
    #expect(SMCSensors.power(58.4) == 58.4)
    #expect(SMCSensors.power(0) == 0)
}
