//
//  EntitlementsBrowserService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

enum EntitlementsBrowserService {
    static func loadNodes(for app: InstalledApp) throws -> [InfoPlistNode] {
        try InfoPlistBrowserService.makeNodes(from: loadDictionary(for: app))
    }

    static func loadDictionary(for app: InstalledApp) throws -> [String: Any] {
        guard let data = app.entitlementsData, !data.isEmpty else {
            throw EntitlementsBrowserError.missingEntitlements
        }

        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let dictionary = plist as? [String: Any] else {
            throw EntitlementsBrowserError.invalidEntitlements
        }

        return dictionary
    }
}

enum EntitlementsBrowserError: LocalizedError {
    case missingEntitlements
    case invalidEntitlements

    var errorDescription: String? {
        switch self {
        case .missingEntitlements:
            return "Entitlements could not be found for this app."
        case .invalidEntitlements:
            return "Entitlements could not be parsed."
        }
    }
}
