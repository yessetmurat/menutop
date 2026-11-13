//
//  SMCValueTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func floatDecodesLittleEndian() {
    let value = SMCValue(type: "flt ", bytes: [0x00, 0x00, 0x40, 0x42])

    #expect(value.number == 48)
}

@Test func otherTypesHaveNoNumber() {
    #expect(SMCValue(type: "ui32", bytes: [1, 0, 0, 0]).number == nil)
}

@Test func shortFloatHasNoNumber() {
    #expect(SMCValue(type: "flt ", bytes: [0x00, 0x40]).number == nil)
}
