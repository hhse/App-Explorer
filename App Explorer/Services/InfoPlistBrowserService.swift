//
//  InfoPlistBrowserService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

enum InfoPlistBrowserService {
    static func loadNodes(for app: InstalledApp) throws -> [InfoPlistNode] {
        try makeNodes(from: loadDictionary(for: app))
    }

    static func loadDictionary(for app: InstalledApp) throws -> [String: Any] {
        guard let bundleURL = app.bundleURL else {
            throw InfoPlistBrowserError.missingBundleURL
        }

        let plistURL = bundleURL.appendingPathComponent("Info.plist")
        let data = try Data(contentsOf: plistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let dictionary = plist as? [String: Any] else {
            throw InfoPlistBrowserError.invalidInfoPlist
        }

        return dictionary
    }

    static func filter(nodes: [InfoPlistNode], query: String) -> [InfoPlistNode] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return nodes
        }

        let loweredQuery = trimmedQuery.localizedLowercase
        return nodes.compactMap { filter(node: $0, query: loweredQuery) }
    }

    private static func filter(node: InfoPlistNode, query: String) -> InfoPlistNode? {
        switch node.kind {
        case .value:
            return node.searchText.localizedLowercase.contains(query) ? node : nil
        case .dictionary(let children):
            let filteredChildren = children.compactMap { filter(node: $0, query: query) }
            if !filteredChildren.isEmpty || node.key.localizedLowercase.contains(query) {
                return InfoPlistNode(id: node.id, key: node.key, kind: .dictionary(filteredChildren))
            }
            return nil
        case .array(let children):
            let filteredChildren = children.compactMap { filter(node: $0, query: query) }
            if !filteredChildren.isEmpty || node.key.localizedLowercase.contains(query) {
                return InfoPlistNode(id: node.id, key: node.key, kind: .array(filteredChildren))
            }
            return nil
        }
    }

    static func makeNodes(from dictionary: [String: Any]) -> [InfoPlistNode] {
        makeDictionaryNodes(dictionary, parentID: "root")
    }

    private static func makeDictionaryNodes(_ dictionary: [String: Any], parentID: String) -> [InfoPlistNode] {
        dictionary.keys.sorted().map { key in
            makeNode(key: key, value: dictionary[key] as Any, parentID: parentID)
        }
    }

    private static func makeArrayNodes(_ array: [Any], parentID: String) -> [InfoPlistNode] {
        array.enumerated().map { index, value in
            makeNode(key: "[\(index)]", value: value, parentID: parentID)
        }
    }

    private static func makeNode(key: String, value: Any, parentID: String) -> InfoPlistNode {
        let id = "\(parentID).\(key)"

        if let dictionary = value as? [String: Any] {
            return InfoPlistNode(
                id: id,
                key: key,
                kind: .dictionary(makeDictionaryNodes(dictionary, parentID: id))
            )
        }

        if let array = value as? [Any] {
            return InfoPlistNode(
                id: id,
                key: key,
                kind: .array(makeArrayNodes(array, parentID: id))
            )
        }

        return InfoPlistNode(
            id: id,
            key: key,
            kind: .value(stringValue(for: value))
        )
    }

    private static func stringValue(for value: Any) -> String {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return number.stringValue
        case let date as Date:
            return ISO8601DateFormatter().string(from: date)
        case let data as Data:
            return data.base64EncodedString()
        default:
            return String(describing: value)
        }
    }
}

enum InfoPlistBrowserError: LocalizedError {
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
