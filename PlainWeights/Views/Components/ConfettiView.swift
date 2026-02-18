//
//  ConfettiView.swift
//  PlainWeights
//
//  PB celebration visual effects and notification definitions.
//

import SwiftUI

// MARK: - PB Glow Overlay

/// Siri-style animated golden glow border for Personal Best achievements
struct PBGlowOverlay: View {
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0

    private let goldColors: [Color] = [
        Color(red: 1.0, green: 0.75, blue: 0.0),   // Gold
        Color(red: 1.0, green: 0.82, blue: 0.2),   // Light gold
        Color(red: 0.95, green: 0.70, blue: 0.1),   // Dark gold
        Color(red: 1.0, green: 0.84, blue: 0.0),   // Yellow gold
        Color(red: 1.0, green: 0.75, blue: 0.0),   // Gold (repeat for seamless loop)
    ]

    var body: some View {
        RoundedRectangle(cornerRadius: 40)
            .strokeBorder(
                AngularGradient(
                    colors: goldColors,
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: 6
            )
            .blur(radius: 20)
            .opacity(glowOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                // Rotating glow
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                // Fade in
                withAnimation(.easeIn(duration: 0.3)) {
                    glowOpacity = 0.8
                }
                // Fade out after delay
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2.5))
                    withAnimation(.easeOut(duration: 0.5)) {
                        glowOpacity = 0
                    }
                }
            }
    }
}

// MARK: - PB Celebration Overlay

struct PBCelebrationOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            PBGlowOverlay()
                .onAppear {
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(3))
                        isShowing = false
                    }
                }
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let pbAchieved = Notification.Name("pbAchieved")
    static let setDataChanged = Notification.Name("setDataChanged")
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        PBGlowOverlay()
    }
}
