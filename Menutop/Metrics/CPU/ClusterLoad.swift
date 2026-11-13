//
//  ClusterLoad.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

/// The busy share of the performance and of the efficiency cores between two samples, each a
/// fraction from 0 to 1, or nil when it cannot be told.
struct ClusterLoad: Equatable {

    var performance: Double?
    var efficiency: Double?

    init(performance: Double?, efficiency: Double?) {
        self.performance = performance
        self.efficiency = efficiency
    }

    /// The load between `previous` and `current`, whose entries match `kinds` by CPU number.
    /// No previous sample, samples of different lengths or counters that went backwards give
    /// nil.
    init(previous: [CoreTicks]?, current: [CoreTicks]?, kinds: [CoreKind]) {
        guard let previous,
              let current,
              previous.count == current.count,
              current.count == kinds.count else {
            self.init(performance: nil, efficiency: nil)
            return
        }

        let cores = zip(kinds, zip(previous, current))

        func load(of kind: CoreKind) -> Double? {
            var busy: UInt64 = 0
            var total: UInt64 = 0

            for (coreKind, (before, after)) in cores where coreKind == kind {
                guard after.busy >= before.busy, after.idle >= before.idle else {
                    return nil
                }

                busy += after.busy - before.busy
                total += (after.busy - before.busy) + (after.idle - before.idle)
            }

            return total == 0 ? nil : Double(busy) / Double(total)
        }

        self.init(performance: load(of: .performance), efficiency: load(of: .efficiency))
    }
}
