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
            // Base light grey
            Color(red: 0.95, green: 0.95, blue: 0.95)

            // Soft blue glow (more saturated)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.70, green: 0.82, blue: 0.98).opacity(0.75),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? -60 : -20, y: animate ? -120 : -60)

            // Soft green glow (more saturated)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.75, green: 0.94, blue: 0.80).opacity(0.75),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? 120 : 60, y: animate ? 160 : 120)

            // Neutral middle lift
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.92, green: 0.92, blue: 0.94).opacity(0.50),
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
