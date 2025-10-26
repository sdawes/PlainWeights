//
//  AnimatedMeshGradientBackground.swift
//  PlainWeights
//
//  Animated mesh gradient background with grey-blue color scheme
//  Uses iOS 18+ MeshGradient with TimelineView for continuous animation
//

import SwiftUI

@available(iOS 18.0, *)
struct AnimatedMeshGradientBackground: View {
    // Very subtle grey-blue palette - barely visible depth effect
    private let baseColors: [Color] = [
        // Top row - almost white with hint of blue
        Color(red: 0.96, green: 0.97, blue: 0.98),
        Color(red: 0.95, green: 0.96, blue: 0.98),
        Color(red: 0.96, green: 0.96, blue: 0.98),

        // Middle row - very light grey-blue
        Color(red: 0.94, green: 0.95, blue: 0.97),
        Color(red: 0.93, green: 0.94, blue: 0.96),
        Color(red: 0.94, green: 0.94, blue: 0.97),

        // Bottom row - light grey-blue
        Color(red: 0.92, green: 0.93, blue: 0.95),
        Color(red: 0.91, green: 0.92, blue: 0.95),
        Color(red: 0.92, green: 0.92, blue: 0.95)
    ]

    // Fixed point positions for 3x3 grid
    private let points: [SIMD2<Float>] = [
        .init(x: 0, y: 0), .init(x: 0.5, y: 0), .init(x: 1, y: 0),
        .init(x: 0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1, y: 0.5),
        .init(x: 0, y: 1), .init(x: 0.5, y: 1), .init(x: 1, y: 1)
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: points,
                colors: animatedColors(for: timeline.date),
                smoothsColors: true
            )
            .ignoresSafeArea()
        }
    }

    /// Animate colors by subtly shifting hue values over time
    private func animatedColors(for date: Date) -> [Color] {
        let phase = date.timeIntervalSince1970 * 0.15 // Slow animation speed

        return baseColors.enumerated().map { index, color in
            // Different phase offset for each color creates organic movement
            let offset = Double(index) * 0.4
            let hueShift = cos(phase + offset) * 0.08 // Subtle hue shift (±8%)

            return shiftHue(of: color, by: hueShift)
        }
    }

    /// Shift the hue of a color while preserving saturation and brightness
    private func shiftHue(of color: Color, by amount: Double) -> Color {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // Shift hue and wrap around [0, 1]
        let newHue = (hue + amount).truncatingRemainder(dividingBy: 1.0)

        return Color(hue: newHue, saturation: saturation, brightness: brightness, opacity: alpha)
        #else
        return color
        #endif
    }
}
