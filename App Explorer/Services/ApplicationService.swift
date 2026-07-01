//
//  ApplicationService.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import UIKit

struct AppScanResult: Sendable {
    let apps: [InstalledApp]
    let icons: [String: Data]
    let summary: AppScanSummary
}

struct AppScanSummary: Sendable {
    let rawCount: Int
    let strictCount: Int
    let fallbackCount: Int
    let visibleCount: Int
    let usedFallback: Bool
    let usedLastResort: Bool
}

struct ApplicationService: Sendable {
    nonisolated func fetchInstalledApps(includeSystemApps: Bool) throws -> AppScanResult {
        let snapshots = try PrivateBridge.fetchInstalledApplications()

        var iconMap: [String: Data] = [:]
        let strictSnapshots = snapshots.filter { shouldIncludeStrict($0, includeSystemApps: includeSystemApps) }
        let fallbackSnapshots = snapshots.filter { shouldIncludeFallback($0, includeSystemApps: includeSystemApps) }
        let lastResortSnapshots = snapshots.filter(shouldIncludeLastResort)
        let selectedSnapshots = mergeSnapshots(
            primary: strictSnapshots,
            secondary: fallbackSnapshots,
            fallback: lastResortSnapshots
        )

        let selectedBundleIDs = Set(selectedSnapshots.map(\.bundleIdentifier))
        let strictBundleIDs = Set(strictSnapshots.map(\.bundleIdentifier))
        let fallbackBundleIDs = Set(fallbackSnapshots.map(\.bundleIdentifier))

        let apps = selectedSnapshots
            .map { snapshot in
                if let iconData = snapshot.iconData {
                    iconMap[snapshot.bundleIdentifier] = iconData
                }

                return InstalledApp(
                    bundleID: snapshot.bundleIdentifier,
                    name: snapshot.localizedName,
                    version: snapshot.bundleVersion,
                    shortVersion: snapshot.shortVersionString,
                    build: infoValue("CFBundleVersion", bundleURL: snapshot.bundleURL) ?? snapshot.bundleVersion,
                    executable: infoValue("CFBundleExecutable", bundleURL: snapshot.bundleURL),
                    displayName: infoValue("CFBundleDisplayName", bundleURL: snapshot.bundleURL),
                    bundleName: infoValue("CFBundleName", bundleURL: snapshot.bundleURL),
                    bundleURL: snapshot.bundleURL,
                    dataURL: snapshot.dataContainerURL,
                    minimumOSVersion: snapshot.minimumSystemVersion,
                    isSystem: snapshot.isSystemApp,
                    applicationType: snapshot.applicationType,
                    iconStatus: snapshot.iconStatus,
                    entitlementsData: snapshot.entitlementsData
                )
            }
            .sorted {
                let lhsName = $0.name.localizedLowercase
                let rhsName = $1.name.localizedLowercase

                if lhsName == rhsName {
                    return $0.bundleID.localizedLowercase < $1.bundleID.localizedLowercase
                }

                return lhsName < rhsName
            }

        let summary = AppScanSummary(
            rawCount: snapshots.count,
            strictCount: strictSnapshots.count,
            fallbackCount: fallbackSnapshots.count,
            visibleCount: selectedSnapshots.count,
            usedFallback: !selectedBundleIDs.isSubset(of: strictBundleIDs) && !fallbackBundleIDs.isEmpty,
            usedLastResort: strictSnapshots.isEmpty && fallbackSnapshots.isEmpty
        )

        return AppScanResult(apps: apps, icons: iconMap, summary: summary)
    }

    nonisolated private func mergeSnapshots(
        primary: [AppProxySnapshot],
        secondary: [AppProxySnapshot],
        fallback: [AppProxySnapshot]
    ) -> [AppProxySnapshot] {
        if primary.isEmpty && secondary.isEmpty {
            return fallback
        }

        var merged: [AppProxySnapshot] = []
        var seenBundleIDs: Set<String> = []

        for snapshot in primary + secondary {
            guard seenBundleIDs.insert(snapshot.bundleIdentifier).inserted else {
                continue
            }

            merged.append(snapshot)
        }

        return merged
    }

    nonisolated private func infoValue(_ key: String, bundleURL: URL?) -> String? {
        guard let infoPlistURL = infoPlistURL(bundleURL: bundleURL),
              let info = NSDictionary(contentsOf: infoPlistURL),
              let value = info[key] as? String,
              !value.isEmpty else {
            return nil
        }

        return value
    }

    nonisolated private func infoPlistURL(bundleURL: URL?) -> URL? {
        bundleURL?.appendingPathComponent("Info.plist")
    }

    nonisolated private func shouldIncludeStrict(_ snapshot: AppProxySnapshot, includeSystemApps: Bool) -> Bool {
        guard !snapshot.isLaunchProhibited, !snapshot.isRestricted else {
            return false
        }

        let type = snapshot.applicationType.localizedLowercase
        if type == "user" {
            return isUserAppPath(snapshot.bundleURL)
        }

        if includeSystemApps, type == "system" {
            return isSystemAppPath(snapshot.bundleURL)
        }

        return false
    }

    nonisolated private func shouldIncludeFallback(_ snapshot: AppProxySnapshot, includeSystemApps: Bool) -> Bool {
        guard !snapshot.bundleIdentifier.isEmpty, !snapshot.localizedName.isEmpty else {
            return false
        }

        if isUserAppPath(snapshot.bundleURL) {
            return true
        }

        if includeSystemApps, isSystemAppPath(snapshot.bundleURL) {
            return true
        }

        let type = snapshot.applicationType.localizedLowercase
        if type == "user" {
            return true
        }

        return includeSystemApps && type == "system"
    }

    nonisolated private func shouldIncludeLastResort(_ snapshot: AppProxySnapshot) -> Bool {
        guard !snapshot.bundleIdentifier.isEmpty else {
            return false
        }

        let lowercasedBundleID = snapshot.bundleIdentifier.localizedLowercase
        return !lowercasedBundleID.contains(".plugin")
            && !lowercasedBundleID.contains(".extension")
            && !lowercasedBundleID.contains(".widget")
    }

    nonisolated private func isUserAppPath(_ url: URL?) -> Bool {
        guard let path = url?.path else {
            return true
        }

        return path.hasPrefix("/private/var/containers/Bundle/Application/")
            || path.hasPrefix("/var/containers/Bundle/Application/")
    }

    nonisolated private func isSystemAppPath(_ url: URL?) -> Bool {
        guard let path = url?.path else {
            return true
        }

        return path.hasPrefix("/Applications/")
            || path.hasPrefix("/System/Applications/")
    }
}
