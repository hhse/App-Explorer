//
//  AppListViewModel.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import Combine
import UIKit

@MainActor
final class AppListViewModel: ObservableObject {
    @Published var apps: [InstalledApp] = [] {
        didSet { updateFilteredApps() }
    }
    @Published var searchText = "" {
        didSet { updateFilteredApps() }
    }
    @Published private(set) var filteredApps: [InstalledApp] = []
    @Published var isLoading = false
    @Published var showSystemApps = false
    @Published var lastUpdatedAt: Date?
    @Published var errorMessage: String?
    @Published var scanSummary: AppScanSummary?

    private let iconService = IconService.shared
    private var icons: [String: Data] = [:]

    init() {
        updateFilteredApps()
    }

    private func updateFilteredApps() {
        filteredApps = Self.filterApps(apps, searchText)
    }

    private static func filterApps(_ apps: [InstalledApp], _ searchText: String) -> [InstalledApp] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return apps }

        return apps.filter { app in
            app.name.localizedCaseInsensitiveContains(query)
                || app.bundleID.localizedCaseInsensitiveContains(query)
                || app.displayVersion.localizedCaseInsensitiveContains(query)
        }
    }

    func loadApps() async {
        isLoading = true
        errorMessage = nil

        do {
            let includeSystemApps = showSystemApps
            let service = ApplicationService()
            let result = try await Task.detached(priority: .userInitiated) {
                try service.fetchInstalledApps(includeSystemApps: includeSystemApps)
            }.value

            iconService.preload(result.icons)

            apps = result.apps
            icons = result.icons
            scanSummary = result.summary
            lastUpdatedAt = Date()
        } catch {
            apps = []
            icons = [:]
            scanSummary = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleSystemApps() async {
        showSystemApps.toggle()
        await loadApps()
    }

    func icon(for app: InstalledApp) -> UIImage? {
        iconService.image(for: app, iconData: icons[app.bundleID])
    }
}
