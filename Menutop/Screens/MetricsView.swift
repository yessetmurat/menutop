//
//  MetricsView.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import SwiftUI

/// The window under the menu bar icon: the metrics as plain label and value rows, a line
/// between the groups, and a quit button.
struct MetricsView: View {

    let sampler: MetricsSampler

    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        let snapshot = sampler.snapshot

        VStack(alignment: .leading, spacing: 10) {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
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

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
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

    private func row(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
                .foregroundStyle(.secondary)

            Text(value)
                .monospacedDigit()
                .gridColumnAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
