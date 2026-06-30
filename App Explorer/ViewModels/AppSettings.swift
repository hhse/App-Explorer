//
//  AppSettings.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Combine
import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
        }
    }

    private static let languageKey = "app_language"

    init() {
        let rawValue = UserDefaults.standard.string(forKey: Self.languageKey)
        language = AppLanguage(rawValue: rawValue ?? "") ?? .chinese
    }
}
