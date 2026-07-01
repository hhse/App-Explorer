//
//  MainTabView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var settings: AppSettings
    @ObservedObject var viewModel: AppListViewModel

    init(viewModel: AppListViewModel) {
        self.viewModel = viewModel
        configureTabBarAppearance()
    }

    var body: some View {
        TabView {
            AppListView(viewModel: viewModel)
                .tabItem {
                    Label(text(.appsTab), systemImage: "square.grid.2x2.fill")
                }

            AboutView()
                .tabItem {
                    Label(text(.aboutTab), systemImage: "info.circle.fill")
                }
        }
        .accentColor(Color(red: 0.20, green: 0.78, blue: 0.72))
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.08, green: 0.11, blue: 0.15, alpha: 0.78)
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.06)

        let normalColor = UIColor.white.withAlphaComponent(0.52)
        let selectedColor = UIColor(red: 0.20, green: 0.78, blue: 0.72, alpha: 1.0)

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        appearance.inlineLayoutAppearance.normal.iconColor = normalColor
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor
        ]
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        appearance.compactInlineLayoutAppearance.normal.iconColor = normalColor
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor
        ]
        appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
