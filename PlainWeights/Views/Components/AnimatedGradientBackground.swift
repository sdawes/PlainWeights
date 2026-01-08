//
//  AnimatedGradientBackground.swift
//  PlainWeights
//
//  Animated multi-gradient background with cool blue-tinted grey tones
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            // Base - light cool grey
            Color(red: 0.957, green: 0.953, blue: 0.965)  // #F4F3F6

            // Subtle cool grey glow (top left)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.937, green: 0.937, blue: 0.953).opacity(0.8),  // #EFEFF3
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? -60 : -20, y: animate ? -120 : -60)

            // Subtle cool grey glow (bottom right)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.937, green: 0.937, blue: 0.953).opacity(0.7),  // #EFEFF3
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 80,
                endRadius: 420
            )
            .blur(radius: 70)
            .offset(x: animate ? 120 : 60, y: animate ? 160 : 120)

            // Center lift
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.947, green: 0.945, blue: 0.959).opacity(0.5),  // midpoint
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
