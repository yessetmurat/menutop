//
//  SMCConnection.swift
//  Menutop
//
//  Created by Yesset Murat on 13.11.2026.
//

import IOKit

/// An open connection to the System Management Controller, which holds the Mac's
/// temperature and power sensors.
///
/// The SMC has no public API. Every call passes the 80-byte `SMCKeyData` struct of Apple's
/// `AppleSMC` user client to its method 2. The struct is
/// built as raw bytes at fixed offsets, so its layout does not depend on Swift's.
final class SMCConnection {

    private enum Command: UInt8 {

        case readBytes = 5
        case keyByIndex = 8
        case keyInfo = 9
    }

    private enum Offset {

        static let key = 0
        static let dataSize = 28
        static let dataType = 32
        static let result = 40
        static let command = 42
        static let index = 44
        static let bytes = 48
    }

    private struct KeyInfo {

        var size: UInt32
        var type: UInt32
    }

    private static let structSize = 80
    private static let callSelector: UInt32 = 2

    private let connection: io_connect_t
    private var keyInfos: [UInt32: KeyInfo] = [:]

    /// Opens the `AppleSMC` service, or nil when there is none or it refuses.
    init?() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != IO_OBJECT_NULL else {
            return nil
        }
        defer { IOObjectRelease(service) }

        var connection: io_connect_t = 0
        let result = IOServiceOpen(
            service,
            mach_task_self_,
            0,
            &connection
        )
        guard result == KERN_SUCCESS else {
            return nil
        }

        self.connection = connection
    }

    deinit {
        IOServiceClose(connection)
    }

    /// Every key the SMC has, such as `Tp01` or `PSTR`.
    func keys() -> [String] {
        guard let count = read("#KEY").map({ $0.bytes.reduce(UInt32(0)) { $0 << 8 | UInt32($1) } }) else {
            return []
        }

        return (0..<count).compactMap { index in
            call(.keyByIndex) { input in
                Self.store(index, in: &input, at: Offset.index)
            }
            .map { Self.fourCharacterCode(Self.load(from: $0, at: Offset.key)) }
        }
    }

    /// The value of `key`, or nil when the SMC has no such key or does not answer.
    func read(_ key: String) -> SMCValue? {
        let code = Self.code(of: key)
        guard let info = keyInfo(code), info.size <= 32 else {
            return nil
        }

        let output = call(.readBytes) { input in
            Self.store(code, in: &input, at: Offset.key)
            Self.store(info.size, in: &input, at: Offset.dataSize)
        }
        guard let output else {
            return nil
        }

        let bytes = Array(output[Offset.bytes..<Offset.bytes + Int(info.size)])
        return SMCValue(type: Self.fourCharacterCode(info.type), bytes: bytes)
    }

    private func keyInfo(_ code: UInt32) -> KeyInfo? {
        if let info = keyInfos[code] {
            return info
        }

        let output = call(.keyInfo) { input in
            Self.store(code, in: &input, at: Offset.key)
        }
        guard let output else {
            return nil
        }

        let info = KeyInfo(size: Self.load(from: output, at: Offset.dataSize), type: Self.load(from: output, at: Offset.dataType))
        keyInfos[code] = info
        return info
    }

    /// Calls the user client with `command` and the fields `fill` sets; the output struct,
    /// or nil when the call fails or the SMC reports an error.
    private func call(_ command: Command, fill: (inout [UInt8]) -> Void) -> [UInt8]? {
        var input = [UInt8](repeating: 0, count: Self.structSize)
        var output = [UInt8](repeating: 0, count: Self.structSize)
        var outputSize = Self.structSize

        fill(&input)
        input[Offset.command] = command.rawValue

        let result = IOConnectCallStructMethod(
            connection,
            Self.callSelector,
            input,
            Self.structSize,
            &output,
            &outputSize
        )
        guard result == KERN_SUCCESS, output[Offset.result] == 0 else {
            return nil
        }

        return output
    }

    private static func store(_ value: UInt32, in bytes: inout [UInt8], at offset: Int) {
        withUnsafeBytes(of: value) { bytes.replaceSubrange(offset..<offset + 4, with: $0) }
    }

    private static func load(from bytes: [UInt8], at offset: Int) -> UInt32 {
        bytes[offset..<offset + 4].withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
    }

    private static func code(of key: String) -> UInt32 {
        key.utf8.prefix(4).reduce(UInt32(0)) { $0 << 8 | UInt32($1) }
    }

    private static func fourCharacterCode(_ code: UInt32) -> String {
        let bytes = [24, 16, 8, 0].map { UInt8(truncatingIfNeeded: code >> $0) }
        return String(decoding: bytes, as: UTF8.self)
    }
}
