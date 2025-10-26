//
//  AnimatedMeshGradientBackground.swift
//  PlainWeights
//
//  Animated mesh gradient background with grey-blue color scheme
//  Uses iOS 18+ MeshGradient with TimelineView for continuous animation
//
//  CURRENTLY COMMENTED OUT - Testing white background instead
//

import SwiftUI

// @available(iOS 18.0, *)
// struct AnimatedMeshGradientBackground: View {
//     // Subtle light blue-grey palette with visible blue tint
//     private let baseColors: [Color] = [
//         // Top row - very light blue-grey
//         Color(red: 0.94, green: 0.96, blue: 0.99),
//         Color(red: 0.93, green: 0.95, blue: 0.99),
//         Color(red: 0.94, green: 0.95, blue: 0.99),
//
//         // Middle row - light blue-grey
//         Color(red: 0.90, green: 0.93, blue: 0.98),
//         Color(red: 0.89, green: 0.92, blue: 0.97),
//         Color(red: 0.90, green: 0.92, blue: 0.98),
//
//         // Bottom row - medium-light blue-grey
//         Color(red: 0.87, green: 0.90, blue: 0.96),
//         Color(red: 0.86, green: 0.89, blue: 0.95),
//         Color(red: 0.87, green: 0.89, blue: 0.96)
//     ]
//
//     // Fixed point positions for 3x3 grid
//     private let points: [SIMD2<Float>] = [
//         .init(x: 0, y: 0), .init(x: 0.5, y: 0), .init(x: 1, y: 0),
//         .init(x: 0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1, y: 0.5),
//         .init(x: 0, y: 1), .init(x: 0.5, y: 1), .init(x: 1, y: 1)
//     ]
//
//     var body: some View {
//         TimelineView(.animation) { timeline in
//             MeshGradient(
//                 width: 3,
//                 height: 3,
//                 points: points,
//                 colors: animatedColors(for: timeline.date),
//                 smoothsColors: true
//             )
//             .ignoresSafeArea()
//         }
//     }
//
//     /// Animate colors by subtly shifting hue values over time
//     private func animatedColors(for date: Date) -> [Color] {
//         let phase = date.timeIntervalSince1970 * 0.15 // Slow animation speed
//
//         return baseColors.enumerated().map { index, color in
//             // Different phase offset for each color creates organic movement
//             let offset = Double(index) * 0.4
//             let hueShift = cos(phase + offset) * 0.08 // Subtle hue shift (±8%)
//
//             return shiftHue(of: color, by: hueShift)
//         }
//     }
//
//     /// Shift the hue of a color while preserving saturation and brightness
//     private func shiftHue(of color: Color, by amount: Double) -> Color {
//         #if canImport(UIKit)
//         let uiColor = UIColor(color)
//         var hue: CGFloat = 0
//         var saturation: CGFloat = 0
//         var brightness: CGFloat = 0
//         var alpha: CGFloat = 0
//
//         uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
//
//         // Shift hue and wrap around [0, 1]
//         let newHue = (hue + amount).truncatingRemainder(dividingBy: 1.0)
//
//         return Color(hue: newHue, saturation: saturation, brightness: brightness, opacity: alpha)
//         #else
//         return color
//         #endif
//     }
// }
