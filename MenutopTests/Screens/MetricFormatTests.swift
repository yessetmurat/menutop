//
//  MetricFormatTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func percentRoundsToWholeNumber() {
    #expect(MetricFormat.percent(0.314) == "31 %")
}

@Test func missingValueIsDash() {
    #expect(MetricFormat.percent(nil) == "—")
    #expect(MetricFormat.watts(nil) == "—")
    #expect(MetricFormat.celsius(nil) == "—")
    #expect(MetricFormat.gigabytes(nil) == "—")
    #expect(MetricFormat.gigabytes(used: nil, total: 1) == "—")
}

@Test func wattsHaveOneDecimal() {
    #expect(MetricFormat.watts(6.43) == "6.4 W")
}

@Test func celsiusRoundsToWholeDegree() {
    #expect(MetricFormat.celsius(47.6) == "48 °C")
}

@Test func gigabytesUseBinaryUnits() {
    #expect(MetricFormat.gigabytes(used: 15_246_819_328, total: 34_359_738_368) == "14.2 / 32 GB")
    #expect(MetricFormat.gigabytes(0) == "0.0 GB")
}
