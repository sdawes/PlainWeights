//
//  AnimatedGradientBackground.swift
//  PlainWeights
//
//  Animated multi-gradient background with subtle grey-blue and grey-green tones
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            // Base with slight blue tint
            Color(red: 0.93, green: 0.95, blue: 0.97)

            // Soft blue glow (more saturated)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.60, green: 0.78, blue: 0.98).opacity(0.85),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? -60 : -20, y: animate ? -120 : -60)

            // Soft blue glow (bottom right - secondary)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.65, green: 0.80, blue: 0.96).opacity(0.75),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? 120 : 60, y: animate ? 160 : 120)

            // Blue-tinted middle lift
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.88, green: 0.91, blue: 0.96).opacity(0.55),
                    Color.clear
                ]),
                center: .center,
                startRadius: 120,
                endRadius: 380
            )
            .blur(radius: 60)
            .offset(x: animate ? 10 : -10, y: animate ? 20 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 28).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
