//
//  EntitlementsExportService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

struct EntitlementsExportResult {
    let url: URL
    let data: Data
    let fileName: String
}

enum EntitlementsExportService {
    static func export(app: InstalledApp) throws -> EntitlementsExportResult {
        guard let data = app.entitlementsData, !data.isEmpty else {
            throw EntitlementsExportError.missingEntitlements
        }

        let fileName = "\(safeFileName(app.name))-entitlements.plist"
        let directoryURL = exportDirectoryURL()
        let exportURL = directoryURL.appendingPathComponent(fileName)

        try data.write(to: exportURL, options: .atomic)

        return EntitlementsExportResult(
            url: exportURL,
            data: data,
            fileName: fileName
        )
    }

    private static func exportDirectoryURL() -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppExplorerExports", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        return directoryURL
    }

    private static func safeFileName(_ text: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let fileName = text.components(separatedBy: invalidCharacters)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fileName.isEmpty ? "App" : fileName
    }
}

enum EntitlementsExportError: LocalizedError {
    case missingEntitlements

    var errorDescription: String? {
        switch self {
        case .missingEntitlements:
            return "Entitlements could not be found for this app."
        }
    }
}
