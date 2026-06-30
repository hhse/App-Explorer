//
//  ContentView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppListViewModel()
    @StateObject private var settings = AppSettings()

    var body: some View {
        MainTabView(viewModel: viewModel)
            .environmentObject(settings)
            .task {
                if viewModel.apps.isEmpty && !viewModel.isLoading {
                    await viewModel.loadApps()
                }
            }
    }
}

#Preview {
    ContentView()
}
