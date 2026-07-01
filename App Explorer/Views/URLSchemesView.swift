//
//  URLSchemesView.swift
//  App Explorer
//
//  Created by Codex on 2026/7/1.
//

import SwiftUI
import UIKit

struct URLSchemesView: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp

    @State private var searchText = ""
    @State private var result: URLSchemeResult?
    @State private var errorMessage: String?
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var copiedAll = false

    private var declaredSchemes: [String] {
        URLSchemeService.filterSchemes(result?.declaredSchemes ?? [], query: searchText)
    }

    private var queriedSchemes: [String] {
        URLSchemeService.filterSchemes(result?.queriedSchemes ?? [], query: searchText)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                SearchBar(
                    text: $searchText,
                    placeholder: text(.searchURLSchemesPlaceholder)
                )

                if let result {
                    URLSchemeActionBar(
                        copyAllTitle: copiedAll ? text(.copied) : text(.copyAllSchemes),
                        shareTitle: text(.shareSchemes),
                        exportTitle: text(.exportSchemesTXT),
                        copyAllAction: copyAllSchemes,
                        shareAction: { shareSchemes(result: result) },
                        exportAction: { exportSchemes(result: result) }
                    )

                    if declaredSchemes.isEmpty && queriedSchemes.isEmpty {
                        BrowserEmptyStateView(
                            title: text(.noMatch),
                            message: text(.tryAnotherKeyword)
                        )
                    } else {
                        VStack(spacing: 12) {
                            URLSchemeSection(
                                title: text(.declaredURLSchemes),
                                schemes: declaredSchemes
                            )

                            URLSchemeSection(
                                title: text(.queriedURLSchemes),
                                schemes: queriedSchemes
                            )
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
        .navigationTitle(text(.urlSchemes))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
        .task {
            guard result == nil, errorMessage == nil else {
                return
            }

            loadSchemes()
        }
    }

    private func loadSchemes() {
        do {
            result = try URLSchemeService.loadSchemes(for: app)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func copyAllSchemes() {
        guard let result else {
            return
        }

        UIPasteboard.general.string = URLSchemeExportService.makeText(app: app, result: result)
        copiedAll = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            copiedAll = false
        }
    }

    private func shareSchemes(result: URLSchemeResult) {
        do {
            let export = try URLSchemeExportService.export(app: app, result: result)
            shareURL = export.url
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func exportSchemes(result: URLSchemeResult) {
        shareSchemes(result: result)
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct URLSchemeActionBar: View {
    let copyAllTitle: String
    let shareTitle: String
    let exportTitle: String
    let copyAllAction: () -> Void
    let shareAction: () -> Void
    let exportAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ActionPillButton(title: copyAllTitle, systemImage: "doc.on.doc", action: copyAllAction)
            ActionPillButton(title: shareTitle, systemImage: "square.and.arrow.up", action: shareAction)
            ActionPillButton(title: exportTitle, systemImage: "doc.text", action: exportAction)
        }
    }
}

private struct URLSchemeSection: View {
    let title: String
    let schemes: [String]

    var body: some View {
        if !schemes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.42))

                VStack(spacing: 10) {
                    ForEach(schemes, id: \.self) { scheme in
                        URLSchemeRow(scheme: scheme)
                    }
                }
            }
            .padding(16)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

private struct URLSchemeRow: View {
    let scheme: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(scheme)://")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            CopyValueButton(value: "\(scheme)://")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ActionPillButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
