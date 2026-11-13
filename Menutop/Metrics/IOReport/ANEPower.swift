//
//  ANEPower.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Foundation

/// The Neural Engine's power, from the `Energy Model` channels of IOReport.
///
/// macOS reports no Neural Engine utilization, only the energy it used, so the app shows
/// watts.
final class ANEPower {

    private static let group = "Energy Model"
    private static let channelPrefix = "ANE"
    private static let joulesPerUnit: [String: Double] = ["mJ": 1e-3, "uJ": 1e-6, "nJ": 1e-9]

    private let subscription: CFTypeRef
    private let subscribed: CFMutableDictionary
    private var previous: (sample: CFDictionary, time: ContinuousClock.Instant)?

    /// Subscribes to the energy channels, or nil when IOReport has none or refuses.
    init?() {
        let channels = IOReportCopyChannelsInGroup(
            Self.group as CFString,
            nil,
            0,
            0,
            0
        )
        guard let channels else {
            return nil
        }

        var subscribed: Unmanaged<CFMutableDictionary>?
        let subscription = IOReportCreateSubscription(
            nil,
            channels,
            &subscribed,
            0,
            nil
        )
        guard let subscription,
              let subscribed = subscribed?.takeRetainedValue() else {
            return nil
        }

        self.subscription = subscription
        self.subscribed = subscribed
    }

    /// The mean power since the previous call, in watts; nil on the first call or when the
    /// Neural Engine has no energy channel this app can read.
    func read() -> Double? {
        guard let sample = IOReportCreateSamples(subscription, subscribed, nil) else {
            return nil
        }

        let now = ContinuousClock.now
        defer { previous = (sample, now) }

        guard let previous,
              let delta = IOReportCreateSamplesDelta(previous.sample, sample, nil),
              let channels = (delta as NSDictionary)["IOReportChannels"] as? [NSDictionary] else {
            return nil
        }

        let interval = (now - previous.time) / .seconds(1)
        let watts = channels
            .map { $0 as CFDictionary }
            .filter { (IOReportChannelGetChannelName($0) as String?)?.hasPrefix(Self.channelPrefix) == true }
            .map { channel in
                Self.watts(
                    energy: IOReportSimpleGetIntegerValue(channel, 0),
                    unit: (IOReportChannelGetUnitLabel(channel) as String?) ?? "",
                    interval: interval
                )
            }

        return Self.total(watts)
    }

    /// The sum of the channels that could be read; nil when none could, so an unknown unit
    /// never shows as a confident 0 W.
    static func total(_ watts: [Double?]) -> Double? {
        let readable = watts.compactMap { $0 }
        guard !readable.isEmpty else {
            return nil
        }

        return readable.reduce(0, +)
    }

    /// `energy` in `unit` (`mJ`, `uJ` or `nJ`) spent over `interval` seconds, in watts; nil
    /// for any other unit or an interval that is not positive.
    static func watts(energy: Int64, unit: String, interval: TimeInterval) -> Double? {
        guard let joulesPerUnit = joulesPerUnit[unit], interval > 0 else {
            return nil
        }

        return Double(energy) * joulesPerUnit / interval
    }
}
