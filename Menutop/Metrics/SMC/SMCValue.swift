//
//  SMCValue.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

/// The raw value of one SMC key: its four-letter type, such as `flt `, and its bytes.
struct SMCValue: Equatable {

    var type: String
    var bytes: [UInt8]

    /// The value as a number, for the `flt ` type (a little-endian 32-bit float); nil for
    /// every other type.
    var number: Double? {
        guard type == "flt ", bytes.count == 4 else {
            return nil
        }

        let bits = bytes.reversed().reduce(UInt32(0)) { $0 << 8 | UInt32($1) }
        return Double(Float(bitPattern: bits))
    }
}
