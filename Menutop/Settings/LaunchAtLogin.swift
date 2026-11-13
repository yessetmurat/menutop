//
//  LaunchAtLogin.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import ServiceManagement

/// Whether the app opens when the user logs in, as the system's login items record it.
enum LaunchAtLogin {

    /// Whether the app is a login item now.
    static var isEnabled: Bool {
        isOn(SMAppService.mainApp.status)
    }

    /// Whether `status` means the app is a login item. One waiting for the user's approval in
    /// System Settings counts as on: the user asked for it, and the system tells them the rest.
    static func isOn(_ status: SMAppService.Status) -> Bool {
        switch status {
        case .enabled, .requiresApproval: true
        case .notRegistered, .notFound: false
        @unknown default: false
        }
    }

    /// Adds or removes the app as a login item and returns whether it is one afterwards. When
    /// the system refuses, the result is the unchanged state, which the switch then shows.
    @discardableResult
    static func set(_ enabled: Bool) -> Bool {
        let service = SMAppService.mainApp

        if enabled {
            try? service.register()
        } else {
            try? service.unregister()
        }

        return isEnabled
    }
}
