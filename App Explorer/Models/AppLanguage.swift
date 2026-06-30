//
//  AppLanguage.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese
    case english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chinese:
            return "中文"
        case .english:
            return "English"
        }
    }
}
