//
//  URLSchemeService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

enum URLSchemeService {
    static func loadSchemes(for app: InstalledApp) throws -> URLSchemeResult {
        guard let bundleURL = app.bundleURL else {
            throw URLSchemeError.missingBundleURL
        }

        let plistURL = bundleURL.appendingPathComponent("Info.plist")
        let data = try Data(contentsOf: plistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let dictionary = plist as? [String: Any] else {
            throw URLSchemeError.invalidInfoPlist
        }

        let declaredSchemes = extractDeclaredSchemes(from: dictionary)
        let queriedSchemes = extractQueriedSchemes(from: dictionary)

        return URLSchemeResult(
            declaredSchemes: declaredSchemes,
            queriedSchemes: queriedSchemes
        )
    }

    static func filterSchemes(_ schemes: [String], query: String) -> [String] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return schemes
        }

        return schemes.filter { $0.localizedCaseInsensitiveContains(trimmedQuery) }
    }

    private static func extractDeclaredSchemes(from dictionary: [String: Any]) -> [String] {
        guard let urlTypes = dictionary["CFBundleURLTypes"] as? [[String: Any]] else {
            return []
        }

        let schemes = urlTypes.flatMap { item -> [String] in
            guard let values = item["CFBundleURLSchemes"] as? [String] else {
                return []
            }

            return values
        }

        return normalizedSchemes(schemes)
    }

    private static func extractQueriedSchemes(from dictionary: [String: Any]) -> [String] {
        guard let values = dictionary["LSApplicationQueriesSchemes"] as? [String] else {
            return []
        }

        return normalizedSchemes(values)
    }

    private static func normalizedSchemes(_ schemes: [String]) -> [String] {
        let cleaned = schemes
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return Array(Set(cleaned)).sorted()
    }
}

enum URLSchemeError: LocalizedError {
    case missingBundleURL
    case invalidInfoPlist

    var errorDescription: String? {
        switch self {
        case .missingBundleURL:
            return "Bundle path is unavailable."
        case .invalidInfoPlist:
            return "Info.plist could not be parsed."
        }
    }
}
