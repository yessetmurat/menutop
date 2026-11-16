//
//  BatteryHealthTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 16.11.2026.
//

import Testing

@testable import Menutop

@Test func healthIsNominalOfDesignCapacityRoundedUpToWholePercent() {
    let properties: [String: Any] = [
        "CycleCount": 119,
        "BatteryData": ["NominalChargeCapacity": 8105, "DesignCapacity": 8579],
    ]

    let health = BatteryHealth(properties: properties)

    #expect(health == BatteryHealth(cycleCount: 119, maximumCapacity: 0.95))
}

@Test func wholePercentHealthIsNotRoundedUp() {
    let properties: [String: Any] = [
        "CycleCount": 1,
        "BatteryData": ["NominalChargeCapacity": 950, "DesignCapacity": 1000],
    ]

    let health = BatteryHealth(properties: properties)

    #expect(health.maximumCapacity == 0.95)
}

@Test func healthOfNewBatteryIsCappedAtFull() {
    let properties: [String: Any] = [
        "CycleCount": 0,
        "BatteryData": ["NominalChargeCapacity": 9000, "DesignCapacity": 8579],
    ]

    let health = BatteryHealth(properties: properties)

    #expect(health.maximumCapacity == 1)
}

@Test func invalidCapacityKeepsCycles() {
    let zeroDesign = BatteryHealth(properties: [
        "CycleCount": 7,
        "BatteryData": ["NominalChargeCapacity": 8105, "DesignCapacity": 0],
    ])
    let topLevelCapacities = BatteryHealth(properties: [
        "CycleCount": 7,
        "NominalChargeCapacity": 8105,
        "DesignCapacity": 8579,
    ])

    #expect(zeroDesign == BatteryHealth(cycleCount: 7, maximumCapacity: nil))
    #expect(topLevelCapacities == BatteryHealth(cycleCount: 7, maximumCapacity: nil))
}

@Test func invalidCyclesKeepCapacity() {
    let batteryData = ["NominalChargeCapacity": 8579, "DesignCapacity": 8579]

    let negative = BatteryHealth(properties: ["CycleCount": -1, "BatteryData": batteryData])
    let text = BatteryHealth(properties: ["CycleCount": "1", "BatteryData": batteryData])

    #expect(negative == BatteryHealth(cycleCount: nil, maximumCapacity: 1))
    #expect(text == BatteryHealth(cycleCount: nil, maximumCapacity: 1))
}

@Test func emptyPropertiesGiveNoValues() {
    #expect(BatteryHealth(properties: [:]) == BatteryHealth(cycleCount: nil, maximumCapacity: nil))
}
