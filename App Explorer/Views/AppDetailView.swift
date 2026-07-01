//
//  AppDetailView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import UIKit

struct AppDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp
    let icon: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroDetailHeader(app: app, icon: icon)

                VStack(spacing: 14) {
                    DetailInfoCard(title: text(.bundleID), value: app.bundleID)
                    DetailInfoCard(title: text(.version), value: app.displayVersion)
                    DetailInfoCard(title: text(.buildNumber), value: app.build.isEmpty ? text(.unavailable) : app.build)

                    if let displayName = app.displayName, !displayName.isEmpty {
                        DetailInfoCard(title: text(.displayName), value: displayName)
                    }

                    if let bundleName = app.bundleName, !bundleName.isEmpty {
                        DetailInfoCard(title: text(.bundleName), value: bundleName)
                    }

                    if let executable = app.executable, !executable.isEmpty {
                        DetailInfoCard(title: text(.executable), value: executable)
                    }

                    DetailInfoCard(title: text(.bundlePath), value: app.bundlePath)

                    if let dataURL = app.dataURL {
                        DetailInfoCard(title: text(.dataPath), value: dataURL.path)
                    }

                    if let minimumOSVersion = app.minimumOSVersion, !minimumOSVersion.isEmpty {
                        DetailInfoCard(title: text(.minimumIOS), value: minimumOSVersion)
                    }

                    DetailInfoCard(title: text(.applicationType), value: app.applicationType)
                    DetailInfoCard(title: text(.iconSource), value: app.iconStatus)
                }

                ActionSection(title: text(.quickActions)) {
                    CopyButton(title: text(.copyBundleID), value: app.bundleID)
                    CopyButton(title: text(.copyBundlePath), value: app.bundlePath)

                    if app.dataURL != nil {
                        CopyButton(title: text(.copyDataPath), value: app.dataPath)
                    }
                }

                ActionSection(title: text(.developerTools)) {
                    NavigationToolButton(title: text(.infoPlistBrowser), systemImage: "doc.text.magnifyingglass") {
                        InfoPlistBrowserView(app: app)
                    }

                    NavigationToolButton(title: text(.entitlementsBrowser), systemImage: "checkmark.shield") {
                        EntitlementsBrowserView(app: app)
                    }

                    NavigationToolButton(title: text(.urlSchemes), systemImage: "link") {
                        URLSchemesView(app: app)
                    }
                }

                ActionSection(title: text(.exportCenter)) {
                    ExportIconButton(
                        icon: icon,
                        appName: app.name,
                        bundleID: app.bundleID,
                        language: settings.language
                    )

                    ExportEntitlementsButton(app: app, language: settings.language)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(InteractivePopGestureEnabler())
        .background(AppSurfaceBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))

                        Text(text(.backToApps))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(ScaleButtonStyle())
            }

            ToolbarItem(placement: .principal) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> InteractivePopGestureViewController {
        InteractivePopGestureViewController()
    }

    func updateUIViewController(_ uiViewController: InteractivePopGestureViewController, context: Context) {
        uiViewController.enableInteractivePopGestureIfNeeded()
    }
}

private final class InteractivePopGestureViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableInteractivePopGestureIfNeeded()
    }

    func enableInteractivePopGestureIfNeeded() {
        guard let navigationController else {
            return
        }

        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}

private struct NavigationToolButton<Destination: View>: View {
    let title: String
    let systemImage: String
    let destination: Destination

    init(
        title: String,
        systemImage: String,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.systemImage = systemImage
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
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
        .buttonStyle(.plain)
    }
}

private struct ActionSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.42))

            VStack(spacing: 12) {
                content
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

private struct ExportIconButton: View {
    let icon: UIImage?
    let appName: String
    let bundleID: String
    let language: AppLanguage

    @State private var exported = false
    @State private var exportSize: IconExportSize = .size1024
    @State private var shareItem: FileShareItem?
    @State private var errorMessage: String?
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(text(.iconSize))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.42))

                Spacer()
            }

            Picker("", selection: $exportSize) {
                ForEach(IconExportSize.allCases) { size in
                    Text(size.title(language: language)).tag(size)
                }
            }
            .pickerStyle(.segmented)

            Button {
                exportIcon()
            } label: {
                HStack {
                    Text(exported ? text(.iconReady) : exportTitle)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))

                    Spacer()

                    Image(systemName: exported ? "checkmark" : "square.and.arrow.up")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(icon == nil ? Color.white.opacity(0.42) : .white)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    exported ? Color(red: 0.16, green: 0.52, blue: 0.42) : Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(exported ? 0.04 : 0.10), lineWidth: 1)
                )
            }
            .disabled(icon == nil)
            .buttonStyle(ScaleButtonStyle())
            .sheet(isPresented: $showShareSheet) {
                if let shareItem {
                    ShareSheet(activityItems: [shareItem.url])
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.red.opacity(0.86))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: exported)
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: exportSize)
    }

    private var exportTitle: String {
        String(format: text(.exportIconSize), exportSize.title(language: language))
    }

    private func exportIcon() {
        guard let icon else {
            errorMessage = text(.noIconAvailable)
            return
        }

        do {
            let result = try IconExportService.export(
                icon: icon,
                appName: appName,
                bundleID: bundleID,
                size: exportSize
            )
            shareItem = FileShareItem(
                url: result.url,
                fileName: result.fileName,
                title: appName,
                typeIdentifier: "public.png"
            )
            errorMessage = nil

            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                exported = true
            }

            showShareSheet = true
        } catch {
            exported = false
            shareItem = nil
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}

private struct ExportEntitlementsButton: View {
    let app: InstalledApp
    let language: AppLanguage

    @State private var exported = false
    @State private var shareItem: FileShareItem?
    @State private var errorMessage: String?
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 8) {
            Button {
                exportEntitlements()
            } label: {
                HStack {
                    Text(exported ? text(.entitlementsReady) : text(.exportEntitlements))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))

                    Spacer()

                    Image(systemName: exported ? "checkmark" : "checkmark.shield")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    exported ? Color(red: 0.18, green: 0.43, blue: 0.63) : Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(exported ? 0.04 : 0.10), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .sheet(isPresented: $showShareSheet) {
                if let shareItem {
                    ShareSheet(activityItems: [shareItem.url])
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.red.opacity(0.86))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: exported)
    }

    private func exportEntitlements() {
        do {
            let result = try EntitlementsExportService.export(app: app)
            shareItem = FileShareItem(
                url: result.url,
                fileName: result.fileName,
                title: app.name,
                typeIdentifier: "com.apple.property-list"
            )
            errorMessage = nil

            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                exported = true
            }

            showShareSheet = true
        } catch {
            exported = false
            shareItem = nil
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: language)
    }
}

private final class FileShareItem: NSObject, UIActivityItemSource {
    let url: URL
    let fileName: String
    let title: String
    let typeIdentifier: String

    init(url: URL, fileName: String, title: String, typeIdentifier: String) {
        self.url = url
        self.fileName = fileName
        self.title = title
        self.typeIdentifier = typeIdentifier
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        fileName
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        typeIdentifier
    }
}

private struct HeroDetailHeader: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp
    let icon: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            AppIconView(icon: icon, size: 88, cornerRadius: 22)

            VStack(spacing: 8) {
                Text(app.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(app.bundleID)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 10) {
                DetailTag(text: app.isSystem ? text(.systemApp) : text(.userApp))
                DetailTag(text: app.displayVersion)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct DetailInfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.9)
                .foregroundStyle(Color.white.opacity(0.42))

            Text(value)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(.white)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct DetailTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.08), in: Capsule())
    }
}
