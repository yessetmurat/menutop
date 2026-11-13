//
//  ClusterLoadTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func loadIsBusyShareOfTicksPerKind() {
    let kinds: [CoreKind] = [.efficiency, .performance, .performance]
    let previous = [
        CoreTicks(busy: 0, idle: 0),
        CoreTicks(busy: 0, idle: 0),
        CoreTicks(busy: 0, idle: 0),
    ]
    let current = [
        CoreTicks(busy: 25, idle: 75),
        CoreTicks(busy: 50, idle: 50),
        CoreTicks(busy: 100, idle: 0),
    ]

    let load = ClusterLoad(previous: previous, current: current, kinds: kinds)

    #expect(load == ClusterLoad(performance: 0.75, efficiency: 0.25))
}

@Test func firstSampleHasNoLoad() {
    let load = ClusterLoad(previous: nil, current: [CoreTicks(busy: 1, idle: 1)], kinds: [.performance])

    #expect(load == ClusterLoad(performance: nil, efficiency: nil))
}

@Test func otherKindIsIgnored() {
    let load = ClusterLoad(
        previous: [CoreTicks(busy: 0, idle: 0), CoreTicks(busy: 0, idle: 0)],
        current: [CoreTicks(busy: 10, idle: 0), CoreTicks(busy: 0, idle: 10)],
        kinds: [.other, .performance]
    )

    #expect(load == ClusterLoad(performance: 0, efficiency: nil))
}

@Test func mismatchedCountsGiveNoLoad() {
    let load = ClusterLoad(previous: [], current: [CoreTicks(busy: 1, idle: 1)], kinds: [.performance])

    #expect(load == ClusterLoad(performance: nil, efficiency: nil))
}

@Test func countersGoingBackwardsGiveNoLoad() {
    let load = ClusterLoad(
        previous: [CoreTicks(busy: 10, idle: 10)],
        current: [CoreTicks(busy: 5, idle: 20)],
        kinds: [.performance]
    )

    #expect(load == ClusterLoad(performance: nil, efficiency: nil))
}
