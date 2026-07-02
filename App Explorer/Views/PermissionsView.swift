//
//  PermissionsView.swift
//  App Explorer
//
//  Created by Codex on 2026/7/2.
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp

    @State private var permissions: [AppPermission] = []
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                if let errorMessage {
                    BrowserErrorCard(message: errorMessage)
                } else if permissions.isEmpty {
                    BrowserEmptyStateView(
                        title: text(.noPermissionsFound),
                        message: text(.permissionsEmptyHint)
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(permissions) { permission in
                            NavigationLink {
                                PermissionDetailView(permission: permission)
                            } label: {
                                PermissionRow(permission: permission, language: settings.language)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(AppSurfaceBackground())
        .navigationTitle(text(.permissions))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard permissions.isEmpty, errorMessage == nil else {
                return
            }

            loadPermissions()
        }
    }

    private func loadPermissions() {
        do {
            permissions = try PermissionsService.loadPermissions(for: app)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct PermissionRow: View {
    let permission: AppPermission
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: permission.kind.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.64))
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.28))
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var title: String {
        AppText.permissionTitle(permission.kind, language: language)
    }

    private var subtitle: String {
        if let reason = permission.primaryReason {
            return reason
        }

        if let detail = permission.detectionDetails.first {
            return detail
        }

        return AppText.text(.noPermissionReason, language: language)
    }
}

private struct PermissionDetailView: View {
    @EnvironmentObject private var settings: AppSettings

    let permission: AppPermission

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                PermissionHero(permission: permission, language: settings.language)

                if permission.reasons.isEmpty {
                    PermissionInfoCard(
                        title: text(.reason),
                        value: text(.noPermissionReason)
                    )
                } else {
                    ForEach(permission.reasons) { reason in
                        PermissionInfoCard(
                            title: text(.reason),
                            value: reason.value
                        )

                        PermissionInfoCard(
                            title: text(.sourceKey),
                            value: reason.key
                        )
                    }
                }

                if !permission.detectionDetails.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(text(.detectedBy).uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(0.9)
                            .foregroundStyle(Color.white.opacity(0.42))

                        VStack(spacing: 10) {
                            ForEach(permission.detectionDetails, id: \.self) { detail in
                                PermissionInfoCard(
                                    title: text(.detectedBy),
                                    value: detail
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(AppSurfaceBackground())
        .navigationTitle(AppText.permissionTitle(permission.kind, language: settings.language))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct PermissionHero: View {
    let permission: AppPermission
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: permission.kind.iconName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))

            Text(AppText.permissionTitle(permission.kind, language: language))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct PermissionInfoCard: View {
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
