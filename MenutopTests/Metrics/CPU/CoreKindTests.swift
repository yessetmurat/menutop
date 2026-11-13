//
//  CoreKindTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import Testing

@testable import Menutop

@Test func clusterTypeMapsToKind() {
    #expect(CoreKind(clusterType: "P") == .performance)
    #expect(CoreKind(clusterType: "E") == .efficiency)
    #expect(CoreKind(clusterType: "S") == .other)
}
