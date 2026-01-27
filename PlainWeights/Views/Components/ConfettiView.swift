//
//  ConfettiView.swift
//  PlainWeights
//
//  Celebratory confetti animation for Personal Best achievements.
//

import SwiftUI

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var animate = false

    let colors: [Color] = [
        Color(red: 1.0, green: 0.75, blue: 0.0),   // Gold
        Color(red: 1.0, green: 0.82, blue: 0.2),   // Light gold
        Color(red: 1.0, green: 0.84, blue: 0.0),   // Yellow gold
        Color(red: 0.95, green: 0.70, blue: 0.1),  // Dark gold
        Color(red: 1.0, green: 0.90, blue: 0.50),  // Pale gold
    ]

    let particles: [ConfettiParticle]

    init() {
        var items: [ConfettiParticle] = []
        for _ in 0..<60 {
            items.append(ConfettiParticle(
                x: CGFloat.random(in: 0...1),
                color: [
                    Color(red: 1.0, green: 0.75, blue: 0.0),
                    Color(red: 1.0, green: 0.82, blue: 0.2),
                    Color(red: 1.0, green: 0.84, blue: 0.0),
                    Color(red: 0.95, green: 0.70, blue: 0.1),
                    Color(red: 1.0, green: 0.90, blue: 0.50),
                ].randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.6...1.0)
            ))
        }
        self.particles = items
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 14)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation + (animate ? 360 : 0)))
                        .position(
                            x: particle.x * geometry.size.width,
                            y: animate ? geometry.size.height + 50 : -50
                        )
                        .animation(
                            .easeIn(duration: Double.random(in: 1.5...2.5))
                            .delay(Double.random(in: 0...0.3)),
                            value: animate
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - PB Celebration Overlay

struct PBCelebrationOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            ConfettiView()
                .ignoresSafeArea()
                .onAppear {
                    // Auto-dismiss after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isShowing = false
                    }
                }
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let pbAchieved = Notification.Name("pbAchieved")
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        ConfettiView()
    }
}
