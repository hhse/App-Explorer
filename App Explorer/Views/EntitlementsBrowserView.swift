//
//  EntitlementsBrowserView.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import SwiftUI

struct EntitlementsBrowserView: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp

    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var nodes: [InfoPlistNode] = []
    @State private var errorMessage: String?
    @State private var expandedNodeIDs: Set<String> = []

    private var filteredNodes: [InfoPlistNode] {
        InfoPlistBrowserService.filter(nodes: nodes, query: searchText)
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                SearchBar(
                    text: $searchText,
                    isFocused: $isSearchFocused,
                    placeholder: text(.searchEntitlementsPlaceholder)
                )

                if let errorMessage {
                    BrowserErrorCard(message: errorMessage)
                } else if filteredNodes.isEmpty {
                    BrowserEmptyStateView(
                        title: text(.noMatch),
                        message: text(.tryAnotherKeyword)
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredNodes) { node in
                            InfoPlistNodeCard(
                                node: node,
                                level: 0,
                                expandedNodeIDs: $expandedNodeIDs,
                                forceExpanded: isSearching,
                                canToggleExpansion: !isSearching
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(AppSurfaceBackground())
        .navigationTitle(text(.entitlementsBrowser))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard nodes.isEmpty, errorMessage == nil else {
                return
            }

            loadNodes()
        }
    }

    private func loadNodes() {
        do {
            nodes = try EntitlementsBrowserService.loadNodes(for: app)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}
