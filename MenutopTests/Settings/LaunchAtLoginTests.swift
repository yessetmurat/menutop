//
//  LaunchAtLoginTests.swift
//  MenutopTests
//
//  Created by Yesset Murat on 13.11.2026.
//

import ServiceManagement
import Testing

@testable import Menutop

@Test func registeredAppIsOn() {
    #expect(LaunchAtLogin.isOn(.enabled))
    #expect(LaunchAtLogin.isOn(.requiresApproval))
}

@Test func unregisteredAppIsOff() {
    #expect(!LaunchAtLogin.isOn(.notRegistered))
    #expect(!LaunchAtLogin.isOn(.notFound))
}
