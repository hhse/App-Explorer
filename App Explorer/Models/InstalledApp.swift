//
//  InstalledApp.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Foundation

struct InstalledApp: Identifiable, Hashable, Sendable {
    let bundleID: String
    let name: String
    let version: String
    let shortVersion: String
    let bundleURL: URL?
    let dataURL: URL?
    let minimumOSVersion: String?
    let isSystem: Bool
    let applicationType: String
    let iconStatus: String

    var id: String { bundleID }

    var displayVersion: String {
        if shortVersion.isEmpty {
            return version.isEmpty ? "Unknown" : version
        }

        if version.isEmpty || version == shortVersion {
            return shortVersion
        }

        return "\(shortVersion) (\(version))"
    }

    var bundlePath: String {
        bundleURL?.path ?? "Unavailable"
    }

    var dataPath: String {
        dataURL?.path ?? "Unavailable"
    }
}
