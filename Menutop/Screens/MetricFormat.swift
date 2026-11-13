//
//  MetricFormat.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import Foundation

/// The text of each metric in the window. A value that could not be read shows a dash.
enum MetricFormat {

    private static let missing = "—"
    private static let bytesPerGigabyte = Double(1 << 30)

    /// A fraction from 0 to 1 as a whole percentage, such as `31 %`.
    static func percent(_ value: Double?) -> String {
        guard let value else {
            return missing
        }

        return "\(number(value * 100, decimals: 0)) %"
    }

    /// Watts with one decimal, such as `6.4 W`.
    static func watts(_ value: Double?) -> String {
        guard let value else {
            return missing
        }

        return "\(number(value, decimals: 1)) W"
    }

    /// Degrees Celsius as a whole number, such as `48 °C`.
    static func celsius(_ value: Double?) -> String {
        guard let value else {
            return missing
        }

        return "\(number(value, decimals: 0)) °C"
    }

    /// Bytes as binary gigabytes with one decimal, such as `0.0 GB`.
    static func gigabytes(_ bytes: Double?) -> String {
        guard let bytes else {
            return missing
        }

        return "\(number(bytes / bytesPerGigabyte, decimals: 1)) GB"
    }

    /// Used of total bytes in binary gigabytes, such as `14.2 / 32 GB`. The total drops its
    /// decimal when it is whole, as memory sizes usually are.
    static func gigabytes(used: Double?, total: Double?) -> String {
        guard let used, let total else {
            return missing
        }

        let totalGigabytes = total / bytesPerGigabyte
        let totalDecimals = totalGigabytes.rounded() == totalGigabytes ? 0 : 1

        return "\(number(used / bytesPerGigabyte, decimals: 1)) / \(number(totalGigabytes, decimals: totalDecimals)) GB"
    }

    /// A number with a fixed `.` separator, whatever the system's locale.
    private static func number(_ value: Double, decimals: Int) -> String {
        value.formatted(
            .number
                .precision(.fractionLength(decimals))
                .grouping(.never)
                .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}
