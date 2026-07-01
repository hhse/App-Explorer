//
//  InfoPlistNode.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import Foundation

struct InfoPlistNode: Identifiable, Hashable {
    enum Kind: Hashable {
        case dictionary([InfoPlistNode])
        case array([InfoPlistNode])
        case value(String)
    }

    let id: String
    let key: String
    let kind: Kind

    var displayValue: String {
        switch kind {
        case .dictionary(let children):
            return "\(children.count)"
        case .array(let children):
            return "\(children.count)"
        case .value(let value):
            return value
        }
    }

    var searchText: String {
        switch kind {
        case .dictionary(let children), .array(let children):
            return ([key] + children.map(\.searchText)).joined(separator: " ")
        case .value(let value):
            return "\(key) \(value)"
        }
    }
}

struct URLSchemeGroup: Hashable {
    let title: String
    let schemes: [String]
}

struct URLTypeItem: Identifiable, Hashable {
    let id: String
    let name: String?
    let role: String?
    let schemes: [String]
}

struct URLSchemeResult: Hashable {
    let declaredURLTypes: [URLTypeItem]
    let declaredSchemes: [String]
    let queriedSchemes: [String]

    var allSchemes: [String] {
        Array(Set(declaredSchemes + queriedSchemes)).sorted()
    }
}
