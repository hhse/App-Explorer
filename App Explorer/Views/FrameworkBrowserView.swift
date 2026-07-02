//
//  FrameworkBrowserView.swift
//  App Explorer
//
//  Created by Codex on 2026/7/2.
//

import SwiftUI

struct FrameworkBrowserView: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp

    @State private var result: FrameworkDependencyResult?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                if let result {
                    FrameworkSummaryCard(
                        countText: String(format: text(.frameworkCount), result.count)
                    )

                    if result.frameworks.isEmpty {
                        BrowserEmptyStateView(
                            title: text(.noFrameworksFound),
                            message: text(.frameworksEmptyHint)
                        )
                    } else {
                        VStack(spacing: 12) {
                            ForEach(result.frameworks) { framework in
                                FrameworkRow(framework: framework)
                            }
                        }
                    }
                } else if let errorMessage {
                    BrowserErrorCard(message: errorMessage)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(AppSurfaceBackground())
        .navigationTitle(text(.frameworkBrowser))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard result == nil, errorMessage == nil else {
                return
            }

            loadFrameworks()
        }
    }

    private func loadFrameworks() {
        do {
            result = try FrameworkDependencyService.loadFrameworks(for: app)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct FrameworkSummaryCard: View {
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(countText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct FrameworkRow: View {
    let framework: FrameworkDependency

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(framework.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer(minLength: 8)

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.48))
            }

            Text(framework.path)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.64))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
