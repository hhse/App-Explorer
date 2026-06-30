//
//  CopyButton.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import UIKit

struct CopyButton: View {
    @EnvironmentObject private var settings: AppSettings

    let title: String
    let value: String

    @State private var copied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = value

            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                copied = true
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    copied = false
                }
            }
        } label: {
            HStack {
                Text(copied ? text(.copied) : title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))

                Spacer()

                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                copied ? Color(red: 0.16, green: 0.52, blue: 0.42) : Color.white.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(copied ? 0.04 : 0.10), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: copied)
    }

    private func text(_ key: LocalizedTextKey) -> String {
        AppText.text(key, language: settings.language)
    }
}
