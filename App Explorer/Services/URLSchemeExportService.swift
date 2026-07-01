//
//  URLSchemeExportService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

struct URLSchemeExportResult {
    let url: URL
    let data: Data
    let fileName: String
}

enum URLSchemeExportService {
    static func export(app: InstalledApp, result: URLSchemeResult) throws -> URLSchemeExportResult {
        let content = makeText(app: app, result: result)
        guard let data = content.data(using: .utf8) else {
            throw URLSchemeExportError.encodingFailed
        }

        let fileName = "\(safeFileName(app.name))-url-schemes.txt"
        let directoryURL = exportDirectoryURL()
        let exportURL = directoryURL.appendingPathComponent(fileName)

        try data.write(to: exportURL, options: .atomic)

        return URLSchemeExportResult(
            url: exportURL,
            data: data,
            fileName: fileName
        )
    }

    static func makeText(app: InstalledApp, result: URLSchemeResult) -> String {
        var lines: [String] = []
        lines.append(app.name)
        lines.append(app.bundleID)
        lines.append("")
        lines.append("[Declared URL Types]")

        if result.declaredURLTypes.isEmpty {
            lines.append("(none)")
        } else {
            for item in result.declaredURLTypes {
                if let name = item.name, !name.isEmpty {
                    lines.append("Name: \(name)")
                }

                if let role = item.role, !role.isEmpty {
                    lines.append("Role: \(role)")
                }

                lines.append("Schemes:")
                lines.append(contentsOf: item.schemes.map { "- \($0)://" })
                lines.append("")
            }
        }

        lines.append("[Declared URL Schemes]")

        if result.declaredSchemes.isEmpty {
            lines.append("(none)")
        } else {
            lines.append(contentsOf: result.declaredSchemes.map { "\($0)://" })
        }

        lines.append("")
        lines.append("[Queried URL Schemes]")

        if result.queriedSchemes.isEmpty {
            lines.append("(none)")
        } else {
            lines.append(contentsOf: result.queriedSchemes.map { "\($0)://" })
        }

        return lines.joined(separator: "\n")
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

enum URLSchemeExportError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "URL schemes could not be exported as text."
        }
    }
}
