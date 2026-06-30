//
//  AppIconView.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI
import UIKit

struct AppIconView: View {
    let icon: UIImage?
    var size: CGFloat = 58
    var cornerRadius: CGFloat = 16

    var body: some View {
        Group {
            if let icon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.48, blue: 0.84),
                            Color(red: 0.16, green: 0.76, blue: 0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "app.fill")
                        .font(.system(size: size * 0.34, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.24), radius: 12, x: 0, y: 8)
    }
}
