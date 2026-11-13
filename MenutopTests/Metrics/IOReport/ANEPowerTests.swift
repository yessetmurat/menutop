//
//  ANEPowerTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func millijoulesOverOneSecondAreWatts() {
    #expect(ANEPower.watts(energy: 1_500, unit: "mJ", interval: 1) == 1.5)
}

@Test func nanojoulesScale() {
    #expect(ANEPower.watts(energy: 2_000_000_000, unit: "nJ", interval: 2) == 1)
}

@Test func unknownUnitOrZeroInterval() {
    #expect(ANEPower.watts(energy: 1, unit: "events", interval: 1) == nil)
    #expect(ANEPower.watts(energy: 1, unit: "mJ", interval: 0) == nil)
}

@Test func channelsInUnknownUnitsGiveNoPower() {
    #expect(ANEPower.total([nil]) == nil)
    #expect(ANEPower.total([]) == nil)
    #expect(ANEPower.total([1.5, nil]) == 1.5)
}
