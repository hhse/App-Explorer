//
//  AppSurfaceBackground.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct AppSurfaceBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.10)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.18, blue: 0.24),
                    Color(red: 0.07, green: 0.08, blue: 0.12),
                    Color(red: 0.03, green: 0.04, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.16, green: 0.64, blue: 0.74).opacity(0.20))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: 120, y: -260)

            Circle()
                .fill(Color(red: 0.28, green: 0.36, blue: 0.92).opacity(0.16))
                .frame(width: 240, height: 240)
                .blur(radius: 44)
                .offset(x: -140, y: -120)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.06),
                            .clear,
                            .white.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blendMode(.softLight)
                .ignoresSafeArea()
        }
    }
}
