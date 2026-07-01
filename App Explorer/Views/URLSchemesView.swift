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
    @State private var isSearchFocused = false
    @State private var result: URLSchemeResult?
    @State private var errorMessage: String?
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    @State private var copiedAll = false

    private var declaredURLTypes: [URLTypeItem] {
        filterURLTypes(result?.declaredURLTypes ?? [], query: searchText)
    }

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
                    isFocused: $isSearchFocused,
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

                    if declaredURLTypes.isEmpty && declaredSchemes.isEmpty && queriedSchemes.isEmpty {
                        BrowserEmptyStateView(
                            title: text(.noMatch),
                            message: text(.tryAnotherKeyword)
                        )
                    } else {
                        VStack(spacing: 12) {
                            URLTypeSection(
                                title: text(.declaredURLTypes),
                                items: declaredURLTypes,
                                language: settings.language
                            )

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

    private func filterURLTypes(_ items: [URLTypeItem], query: String) -> [URLTypeItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return items
        }

        return items.filter { item in
            let haystack = [
                item.name ?? "",
                item.role ?? "",
                item.schemes.joined(separator: " ")
            ]
            .joined(separator: " ")

            return haystack.localizedCaseInsensitiveContains(trimmedQuery)
        }
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

private struct URLTypeSection: View {
    let title: String
    let items: [URLTypeItem]
    let language: AppLanguage

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.42))

                VStack(spacing: 10) {
                    ForEach(items) { item in
                        URLTypeRow(item: item, language: language)
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

private struct URLTypeRow: View {
    let item: URLTypeItem
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let name = item.name, !name.isEmpty {
                URLTypeMetaLine(title: text(.urlTypeName), value: name)
            }

            if let role = item.role, !role.isEmpty {
                URLTypeMetaLine(title: text(.urlTypeRole), value: role)
            }

            VStack(spacing: 8) {
                ForEach(item.schemes, id: \.self) { scheme in
                    URLSchemeRow(scheme: scheme)
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}

private struct URLTypeMetaLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(title):")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.46))

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
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
