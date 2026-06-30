//
//  MainTabView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var settings: AppSettings
    @ObservedObject var viewModel: AppListViewModel

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
}
