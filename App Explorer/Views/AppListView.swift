//
//  AppListView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct AppListView: View {
    @EnvironmentObject private var settings: AppSettings
    @ObservedObject var viewModel: AppListViewModel

    var body: some View {
        NavigationView {
            ZStack {
                AppSurfaceBackground()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        AppHeaderView(
                            appCount: viewModel.filteredApps.count,
                            totalCount: viewModel.apps.count,
                            isLoading: viewModel.isLoading,
                            lastUpdatedAt: viewModel.lastUpdatedAt,
                            scanSummary: viewModel.scanSummary,
                            language: settings.language
                        )

                        SearchBar(
                            text: $viewModel.searchText,
                            placeholder: text(.searchPlaceholder)
                        )

                        FilterToolbar(
                            showSystemApps: viewModel.showSystemApps,
                            language: settings.language,
                            refreshAction: {
                                Task { await viewModel.loadApps() }
                            },
                            toggleSystemAction: {
                                Task { await viewModel.toggleSystemApps() }
                            }
                        )

                        if let errorMessage = viewModel.errorMessage {
                            ErrorCard(message: errorMessage)
                        }

                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.filteredApps) { app in
                                AppListRowLink(
                                    app: app,
                                    icon: viewModel.icon(for: app)
                                )
                            }
                        }

                        if !viewModel.isLoading && viewModel.filteredApps.isEmpty {
                            EmptyStateView(
                                searchText: viewModel.searchText,
                                language: settings.language
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                }
                .refreshable {
                    await viewModel.loadApps()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct AppListRowLink: View {
    let app: InstalledApp
    let icon: UIImage?

    var body: some View {
        NavigationLink {
            LazyDestinationView {
                AppDetailView(app: app, icon: icon)
            }
        } label: {
            AppRow(app: app, icon: icon)
                .equatable()
        }
        .buttonStyle(.plain)
    }
}

private struct LazyDestinationView<Content: View>: View {
    let build: () -> Content

    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        build()
    }
}

private struct AppHeaderView: View {
    let appCount: Int
    let totalCount: Int
    let isLoading: Bool
    let lastUpdatedAt: Date?
    let scanSummary: AppScanSummary?
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Explorer")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(text(.subtitle))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.74))
                }

                Spacer(minLength: 12)

                StatusCapsule(isLoading: isLoading)
            }

            HStack(spacing: 12) {
                StatChip(title: text(.visible), value: "\(appCount)")
                StatChip(title: text(.total), value: "\(totalCount)")

                if let lastUpdatedAt {
                    StatChip(
                        title: text(.updated),
                        value: lastUpdatedAt.formatted(date: .omitted, time: .shortened)
                    )
                }
            }

            if let scanSummary {
                Text(scanSummaryText(scanSummary))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.54))
            }
        }
    }

    private func scanSummaryText(_ summary: AppScanSummary) -> String {
        if summary.usedLastResort {
            return "Diagnostic: \(summary.rawCount) raw / \(summary.visibleCount) visible"
        }

        if summary.usedFallback {
            return "Fallback: \(summary.rawCount) raw / \(summary.visibleCount) visible"
        }

        return "\(summary.rawCount) raw / \(summary.strictCount) matched"
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}

private struct StatusCapsule: View {
    let isLoading: Bool
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isLoading ? Color.orange : Color.green)
                .frame(width: 8, height: 8)

            Text(isLoading ? text(.scanning) : text(.ready))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.10), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct StatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(Color.white.opacity(0.42))

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct FilterToolbar: View {
    let showSystemApps: Bool
    let language: AppLanguage
    let refreshAction: () -> Void
    let toggleSystemAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ToolbarButton(
                title: showSystemApps ? text(.allApps) : text(.userApps),
                systemImage: showSystemApps ? "square.stack.3d.up.fill" : "iphone.gen3"
            ) {
                toggleSystemAction()
            }

            ToolbarButton(title: text(.refresh), systemImage: "arrow.clockwise") {
                refreshAction()
            }
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}

private struct ToolbarButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white.opacity(0.08), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct ErrorCard: View {
    @EnvironmentObject private var settings: AppSettings

    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text(.scanFailed))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.72))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.20), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
        )
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct EmptyStateView: View {
    let searchText: String
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.82))

            Text(searchText.isEmpty ? text(.noApps) : "\(text(.noMatch)): \"\(searchText)\"")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            Text(text(.tryAnotherKeyword))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.66))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}
