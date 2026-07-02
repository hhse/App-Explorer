//
//  FrameworkDependencyService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/2.
//

import Foundation
import MachO

struct FrameworkDependency: Identifiable, Hashable, Sendable {
    let name: String
    let path: String

    var id: String { path }
}

struct FrameworkDependencyResult: Sendable {
    let frameworks: [FrameworkDependency]

    var count: Int { frameworks.count }
}

enum FrameworkDependencyService {
    static func loadFrameworks(for app: InstalledApp) throws -> FrameworkDependencyResult {
        guard let executableURL = app.executableURL else {
            throw FrameworkDependencyError.missingExecutable
        }

        let data = try Data(contentsOf: executableURL)
        let sliceOffset = try machOSliceOffset(in: data)
        let dylibPaths = try loadDylibPaths(from: data, sliceOffset: sliceOffset)

        let frameworks = Array(
            Set(
                dylibPaths.compactMap { path -> FrameworkDependency? in
                    guard let framework = frameworkDependency(from: path) else {
                        return nil
                    }

                    return framework
                }
            )
        )
        .sorted { lhs, rhs in
            if lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedSame {
                return lhs.path.localizedCaseInsensitiveCompare(rhs.path) == .orderedAscending
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return FrameworkDependencyResult(frameworks: frameworks)
    }

    private static func frameworkDependency(from path: String) -> FrameworkDependency? {
        let components = path.split(separator: "/")

        guard let frameworkComponent = components.last(where: { $0.hasSuffix(".framework") }) else {
            return nil
        }

        return FrameworkDependency(
            name: String(frameworkComponent),
            path: path
        )
    }

    private static func machOSliceOffset(in data: Data) throws -> Int {
        let magic: UInt32 = try readValue(from: data, offset: 0)

        switch magic {
        case FAT_MAGIC, FAT_CIGAM:
            let header: fat_header = try readValue(from: data, offset: 0)
            let count = Int(UInt32(bigEndian: header.nfat_arch))
            var offset = MemoryLayout<fat_header>.size

            for _ in 0..<count {
                let architecture: fat_arch = try readValue(from: data, offset: offset)
                let sliceOffset = Int(UInt32(bigEndian: architecture.offset))
                let cpuType = Int32(bigEndian: architecture.cputype)

                if cpuType == CPU_TYPE_ARM64 || cpuType == CPU_TYPE_ARM {
                    return sliceOffset
                }

                offset += MemoryLayout<fat_arch>.size
            }

            throw FrameworkDependencyError.unsupportedBinary
        case MH_MAGIC, MH_MAGIC_64, MH_CIGAM, MH_CIGAM_64:
            return 0
        default:
            throw FrameworkDependencyError.invalidMachO
        }
    }

    private static func loadDylibPaths(from data: Data, sliceOffset: Int) throws -> [String] {
        let magic: UInt32 = try readValue(from: data, offset: sliceOffset)

        switch magic {
        case MH_MAGIC_64, MH_CIGAM_64:
            return try loadDylibPaths64(from: data, sliceOffset: sliceOffset)
        case MH_MAGIC, MH_CIGAM:
            return try loadDylibPaths32(from: data, sliceOffset: sliceOffset)
        default:
            throw FrameworkDependencyError.invalidMachO
        }
    }

    private static func loadDylibPaths64(from data: Data, sliceOffset: Int) throws -> [String] {
        let header: mach_header_64 = try readValue(from: data, offset: sliceOffset)
        let commandOffset = sliceOffset + MemoryLayout<mach_header_64>.size
        return try loadDylibPaths(
            from: data,
            commandOffset: commandOffset,
            commandCount: Int(header.ncmds)
        )
    }

    private static func loadDylibPaths32(from data: Data, sliceOffset: Int) throws -> [String] {
        let header: mach_header = try readValue(from: data, offset: sliceOffset)
        let commandOffset = sliceOffset + MemoryLayout<mach_header>.size
        return try loadDylibPaths(
            from: data,
            commandOffset: commandOffset,
            commandCount: Int(header.ncmds)
        )
    }

    private static func loadDylibPaths(from data: Data, commandOffset: Int, commandCount: Int) throws -> [String] {
        var dylibPaths: [String] = []
        var offset = commandOffset

        for _ in 0..<commandCount {
            let command: load_command = try readValue(from: data, offset: offset)
            let commandSize = Int(command.cmdsize)

            guard commandSize >= MemoryLayout<load_command>.size else {
                throw FrameworkDependencyError.invalidMachO
            }

            if isDylibLoadCommand(command.cmd) {
                let dylibCommand: dylib_command = try readValue(from: data, offset: offset)
                let pathOffset = offset + Int(dylibCommand.dylib.name.offset)

                if let path = readCString(from: data, offset: pathOffset, limit: offset + commandSize) {
                    dylibPaths.append(path)
                }
            }

            offset += commandSize
        }

        return dylibPaths
    }

    private static func isDylibLoadCommand(_ command: UInt32) -> Bool {
        command == UInt32(LC_LOAD_DYLIB)
            || command == UInt32(LC_LOAD_WEAK_DYLIB)
            || command == UInt32(LC_REEXPORT_DYLIB)
            || command == UInt32(LC_LOAD_UPWARD_DYLIB)
            || command == UInt32(LC_LAZY_LOAD_DYLIB)
    }

    private static func readCString(from data: Data, offset: Int, limit: Int) -> String? {
        guard offset >= 0, limit <= data.count, offset < limit else {
            return nil
        }

        let bytes = data[offset..<limit]
        guard let zeroIndex = bytes.firstIndex(of: 0) else {
            return nil
        }

        let stringData = Data(bytes[..<zeroIndex])
        return String(data: stringData, encoding: .utf8)
    }

    private static func readValue<T>(from data: Data, offset: Int) throws -> T {
        let size = MemoryLayout<T>.size

        guard offset >= 0, offset + size <= data.count else {
            throw FrameworkDependencyError.invalidMachO
        }

        return data.withUnsafeBytes { rawBuffer in
            rawBuffer.loadUnaligned(fromByteOffset: offset, as: T.self)
        }
    }
}

enum FrameworkDependencyError: LocalizedError {
    case missingExecutable
    case invalidMachO
    case unsupportedBinary

    var errorDescription: String? {
        switch self {
        case .missingExecutable:
            return "Executable path is unavailable."
        case .invalidMachO:
            return "The executable could not be parsed."
        case .unsupportedBinary:
            return "This executable architecture is not supported."
        }
    }
}
