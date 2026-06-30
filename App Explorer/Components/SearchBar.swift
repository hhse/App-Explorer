//
//  SearchBar.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder = "Search apps or Bundle ID"
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.58))

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.42))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(.white.opacity(isFocused ? 0.14 : 0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(isFocused ? 0.18 : 0.08), lineWidth: 1)
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.86), value: isFocused)
        .animation(.spring(response: 0.25, dampingFraction: 0.86), value: text.isEmpty)
    }
}
