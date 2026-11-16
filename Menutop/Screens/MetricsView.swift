//
//  MetricsView.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import SwiftUI

/// The window under the menu bar icon: the metrics as plain label and value rows, a line
/// between the groups, and a quit button. The battery group shows only on a Mac with one.
struct MetricsView: View {

    let sampler: MetricsSampler

    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        let snapshot = sampler.snapshot

        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                row("CPU P-cores", MetricFormat.percent(snapshot.performanceLoad))
                row("CPU E-cores", MetricFormat.percent(snapshot.efficiencyLoad))
                row("GPU", MetricFormat.percent(snapshot.gpuLoad))

                separator

                row(
                    "RAM",
                    MetricFormat.gigabytes(
                        used: snapshot.memory.map { Double($0.usedBytes) },
                        total: snapshot.memory.map { Double($0.totalBytes) }
                    )
                )
                row("Swap", MetricFormat.gigabytes(snapshot.memory.map { Double($0.swapUsedBytes) }))

                separator

                row("Power", MetricFormat.watts(snapshot.systemPower))
                row("CPU", MetricFormat.celsius(snapshot.cpuTemperature))
                row("GPU", MetricFormat.celsius(snapshot.gpuTemperature))

                if let battery = snapshot.battery {
                    separator

                    row("Battery health", MetricFormat.percent(battery.maximumCapacity))
                    row("Battery cycles", MetricFormat.count(battery.cycleCount))
                    row("Battery temperature", MetricFormat.celsius(snapshot.batteryTemperature))
                }
            }

            Divider()

            HStack {
                Text("Launch at login")

                Spacer()

                Toggle("Launch at login", isOn: $launchAtLogin)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .onChange(of: launchAtLogin) { _, enabled in
                        launchAtLogin = LaunchAtLogin.set(enabled)
                    }
            }

            Button("Quit Menutop") {
                NSApp.terminate(nil)
            }
            .buttonStyle(MenuItemButtonStyle(shortcut: "⌘Q"))
            .keyboardShortcut("q")
            .padding(.horizontal, -6)
        }
        .padding(14)
        .frame(width: 240)
        .onAppear {
            launchAtLogin = LaunchAtLogin.isEnabled
        }
        .task {
            await sampler.run()
        }
    }

    /// The line between two groups, with room above and below it.
    private var separator: some View {
        Divider()
            .padding(.vertical, 4)
    }

    /// A label and its value at the right edge. Each row lays out on its own, so a long label
    /// in one row does not take room from a long value in another.
    private func row(_ title: String, _ value: String) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .foregroundStyle(.secondary)
                .fixedSize()

            Spacer(minLength: 16)

            Text(value)
                .monospacedDigit()
        }
    }
}
