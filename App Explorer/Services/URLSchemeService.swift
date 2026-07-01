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

        let declaredURLTypes = extractDeclaredURLTypes(from: dictionary)
        let declaredSchemes = normalizedSchemes(
            declaredURLTypes.flatMap(\.schemes)
        )
        let queriedSchemes = extractQueriedSchemes(from: dictionary)

        return URLSchemeResult(
            declaredURLTypes: declaredURLTypes,
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

    private static func extractDeclaredURLTypes(from dictionary: [String: Any]) -> [URLTypeItem] {
        guard let urlTypes = dictionary["CFBundleURLTypes"] as? [[String: Any]] else {
            return []
        }

        return urlTypes.enumerated().compactMap { index, item in
            guard let values = item["CFBundleURLSchemes"] as? [String] else {
                return nil
            }

            let schemes = normalizedSchemes(values)
            guard !schemes.isEmpty else {
                return nil
            }

            return URLTypeItem(
                id: "url-type-\(index)",
                name: item["CFBundleURLName"] as? String,
                role: item["CFBundleTypeRole"] as? String,
                schemes: schemes
            )
        }
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
