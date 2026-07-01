//
//  InfoPlistBrowserView.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import SwiftUI
import UIKit

struct InfoPlistBrowserView: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp

    @State private var searchText = ""
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
                    placeholder: text(.searchPlistPlaceholder)
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
        .navigationTitle("Info.plist")
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
            nodes = try InfoPlistBrowserService.loadNodes(for: app)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct InfoPlistNodeCard: View {
    @EnvironmentObject private var settings: AppSettings

    let node: InfoPlistNode
    let level: Int
    @Binding var expandedNodeIDs: Set<String>
    let forceExpanded: Bool
    let canToggleExpansion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                if isExpandable {
                    Button(action: toggleExpansion) {
                        Image(systemName: (isExpanded || forceExpanded) ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.72))
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canToggleExpansion)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                        .frame(width: 18, height: 18, alignment: .top)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(node.key)
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white)

                        Spacer(minLength: 8)

                        CopyValueButton(value: node.key)
                    }

                    nodeValueView
                }
            }

            if shouldShowChildren {
                VStack(spacing: 10) {
                    ForEach(children) { child in
                        InfoPlistNodeCard(
                            node: child,
                            level: level + 1,
                            expandedNodeIDs: $expandedNodeIDs,
                            forceExpanded: forceExpanded,
                            canToggleExpansion: canToggleExpansion
                        )
                        .padding(.leading, 18)
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(level == 0 ? 0.07 : 0.05), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var nodeValueView: some View {
        switch node.kind {
        case .dictionary(let children):
            NodeMetaLine(
                title: text(.dictionaryCount),
                value: "\(children.count)"
            )
        case .array(let children):
            NodeMetaLine(
                title: text(.arrayCount),
                value: "\(children.count)"
            )
        case .value(let value):
            HStack(alignment: .top, spacing: 10) {
                Text(value)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .frame(maxWidth: .infinity, alignment: .leading)

                CopyValueButton(value: value)
            }
        }
    }

    private var isExpandable: Bool {
        switch node.kind {
        case .dictionary, .array:
            return true
        case .value:
            return false
        }
    }

    private var shouldShowChildren: Bool {
        isExpandable && (isExpanded || forceExpanded)
    }

    private var isExpanded: Bool {
        expandedNodeIDs.contains(node.id)
    }

    private var children: [InfoPlistNode] {
        switch node.kind {
        case .dictionary(let children), .array(let children):
            return children
        case .value:
            return []
        }
    }

    private func toggleExpansion() {
        guard canToggleExpansion else {
            return
        }

        if expandedNodeIDs.contains(node.id) {
            expandedNodeIDs.remove(node.id)
        } else {
            expandedNodeIDs.insert(node.id)
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct NodeMetaLine: View {
    let title: String
    let value: String

    var body: some View {
        Text("\(title): \(value)")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.58))
    }
}
