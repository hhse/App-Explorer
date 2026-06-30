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
    @Published var apps: [InstalledApp] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showSystemApps = false
    @Published var lastUpdatedAt: Date?
    @Published var errorMessage: String?
    @Published var scanSummary: AppScanSummary?

    private let iconService = IconService.shared
    private var icons: [String: Data] = [:]

    var filteredApps: [InstalledApp] {
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
            let result = try await Task.detached(priority: .userInitiated) {
                try ApplicationService().fetchInstalledApps(includeSystemApps: includeSystemApps)
            }.value

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
