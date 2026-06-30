//
//  AboutView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        ZStack {
            AppSurfaceBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Explorer")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(text(.aboutSubtitle))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.72))
                    }

                    AboutCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SettingsRow(title: text(.language), systemImage: "globe") {
                                Picker("", selection: $settings.language) {
                                    ForEach(AppLanguage.allCases) { language in
                                        Text(language.title).tag(language)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 180)
                            }
                        }
                    }

                    AboutCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Link(destination: URL(string: "https://github.com/hhse/App-Explorer.git")!) {
                                SettingsRow(title: text(.openSource), systemImage: "chevron.left.forwardslash.chevron.right") {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.12))

                            Text("https://github.com/hhse/App-Explorer.git")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color.white.opacity(0.58))
                                .textSelection(.enabled)
                        }
                    }

                    AboutCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(text(.currentVersion))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.42))

                            Text("0.1.0")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
        }
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct AboutCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct SettingsRow<Trailing: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            trailing
        }
    }
}
