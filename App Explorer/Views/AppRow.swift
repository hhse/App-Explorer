//
//  AppRow.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import UIKit

struct AppRow: View {
    @EnvironmentObject private var settings: AppSettings

    let app: InstalledApp
    let icon: UIImage?

    var body: some View {
        HStack(spacing: 14) {
            AppIconView(icon: icon)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(app.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if app.isSystem {
                        Text(text(.systemBadge))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(Color.white.opacity(0.54))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.08), in: Capsule())
                    }
                }

                Text(app.bundleID)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.64))
                    .lineLimit(1)

                HStack(spacing: 10) {
                    MiniInfoPill(title: text(.version), value: app.displayVersion)

                    if let minimumOSVersion = app.minimumOSVersion, !minimumOSVersion.isEmpty {
                        MiniInfoPill(title: text(.minimumIOS), value: minimumOSVersion)
                    }
                }
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.28))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.11),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.20), radius: 20, x: 0, y: 12)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct MiniInfoPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .foregroundStyle(Color.white.opacity(0.42))

            Text(value)
                .foregroundStyle(.white.opacity(0.82))
        }
        .font(.system(size: 11, weight: .semibold, design: .rounded))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.06), in: Capsule())
    }
}
