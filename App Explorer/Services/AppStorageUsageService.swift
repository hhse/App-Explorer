//
//  AppStorageUsageService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/2.
//

import Foundation

struct AppStorageUsage: Sendable {
    let documentsSize: Int64
    let dataSize: Int64
}

struct AppStorageUsageService: Sendable {
    func usage(for app: InstalledApp) throws -> AppStorageUsage? {
        guard let dataURL = app.dataURL else {
            return nil
        }

        let documentsSize = try directorySize(at: app.documentsURL)
        let containerSize = try directorySize(at: dataURL)
        let dataSize = max(containerSize - documentsSize, 0)

        return AppStorageUsage(
            documentsSize: documentsSize,
            dataSize: dataSize
        )
    }

    private func directorySize(at url: URL?) throws -> Int64 {
        guard let url else {
            return 0
        }

        var isDirectory: ObjCBool = false
        let path = url.path

        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return 0
        }

        guard isDirectory.boolValue else {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            return Int64(resourceValues.fileSize ?? 0)
        }

        let keys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .totalFileAllocatedSizeKey,
            .fileAllocatedSizeKey,
            .fileSizeKey
        ]

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsPackageDescendants],
            errorHandler: nil
        ) else {
            return 0
        }

        var totalSize: Int64 = 0

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: keys)
            guard values.isRegularFile == true else {
                continue
            }

            totalSize += Int64(
                values.totalFileAllocatedSize
                    ?? values.fileAllocatedSize
                    ?? values.fileSize
                    ?? 0
            )
        }

        return totalSize
    }
}
