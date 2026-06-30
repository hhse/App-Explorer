//
//  ScaleButtonStyle.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .opacity(configuration.isPressed ? 0.90 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
