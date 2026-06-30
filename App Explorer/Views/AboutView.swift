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
                        VStack(alignment: .leading, spacing: 10) {
                            Text(text(.currentVersion))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.42))

                            Text("0.1.0")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text(text(.build))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.56))
                        }
                    }

                    FooterLinks()
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

private struct FooterLinks: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(spacing: 10) {
            Text(text(.contactAndLinks))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(Color.white.opacity(0.36))

            HStack(spacing: 14) {
                FooterLink(title: text(.telegramChannel), url: "https://t.me/TheBallnow")
                FooterDot()
                FooterLink(title: text(.githubProfile), url: "https://github.com/hhse")
                FooterDot()
                FooterLink(title: text(.wechatOfficial), url: "https://joia.cn/")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}

private struct FooterLink: View {
    let title: String
    let url: String

    var body: some View {
        Link(title, destination: URL(string: url)!)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.58))
    }
}

private struct FooterDot: View {
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.22))
            .frame(width: 3, height: 3)
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
