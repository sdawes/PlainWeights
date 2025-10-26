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
    // Grey-blue color palette for professional, subtle aesthetic
    private let baseColors: [Color] = [
        // Top row - lighter grey-blues
        Color(red: 0.82, green: 0.86, blue: 0.90),
        Color(red: 0.75, green: 0.80, blue: 0.86),
        Color(red: 0.78, green: 0.83, blue: 0.88),

        // Middle row - medium blue-greys
        Color(red: 0.68, green: 0.74, blue: 0.82),
        Color(red: 0.60, green: 0.68, blue: 0.78),
        Color(red: 0.65, green: 0.72, blue: 0.80),

        // Bottom row - darker grey-blues
        Color(red: 0.72, green: 0.78, blue: 0.84),
        Color(red: 0.58, green: 0.66, blue: 0.76),
        Color(red: 0.70, green: 0.76, blue: 0.82)
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
