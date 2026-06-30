//
//  InfoPlistExportService.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Foundation

struct InfoPlistExportResult {
    let url: URL
    let data: Data
    let fileName: String
}

enum InfoPlistExportService {
    static func export(app: InstalledApp) throws -> InfoPlistExportResult {
        guard let sourceURL = app.bundleURL?.appendingPathComponent("Info.plist") else {
            throw InfoPlistExportError.missingBundleURL
        }

        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw InfoPlistExportError.missingInfoPlist
        }

        let data = try Data(contentsOf: sourceURL)
        let fileName = "\(safeFileName(app.name))-Info.plist"
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppExplorerExports", isDirectory: true)

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let exportURL = directoryURL.appendingPathComponent(fileName)
        try data.write(to: exportURL, options: .atomic)

        return InfoPlistExportResult(url: exportURL, data: data, fileName: fileName)
    }

    private static func safeFileName(_ text: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let fileName = text.components(separatedBy: invalidCharacters)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fileName.isEmpty ? "App" : fileName
    }
}

enum InfoPlistExportError: LocalizedError {
    case missingBundleURL
    case missingInfoPlist

    var errorDescription: String? {
        switch self {
        case .missingBundleURL:
            return "Bundle path is unavailable."
        case .missingInfoPlist:
            return "Info.plist could not be found."
        }
    }
}
