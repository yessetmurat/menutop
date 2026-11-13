//
//  MenutopApp.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import SwiftUI

/// The menu bar app: an icon in the menu bar whose window shows the machine's metrics.
@main
struct MenutopApp: App {

    @State private var sampler = MetricsSampler()

    var body: some Scene {
        MenuBarExtra {
            MetricsView(sampler: sampler)
        } label: {
            Image(nsImage: MenuBarIcon.image)
        }
        .menuBarExtraStyle(.window)
    }
}
