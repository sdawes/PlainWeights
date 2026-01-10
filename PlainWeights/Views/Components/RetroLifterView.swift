//
//  RetroLifterView.swift
//  PlainWeights
//
//  Animated 16x16 pixel art of a weightlifter in ZX Spectrum style
//

import SwiftUI

struct RetroLifterView: View {
    @Environment(ThemeManager.self) private var themeManager
    var pixelSize: CGFloat = 10

    // Frame 1: Squatting (Barbell on shoulders) - original leg spread
    private let frame1 = [
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0, // Weights ABOVE bar
        0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0, // Bar
        0,0,2,2,0,1,0,0,0,0,1,0,2,2,0,0, // Weights + arms reaching up
        0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0, // Arms + head (head BELOW bar)
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Head/face
        0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0, // Shoulders
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Torso
        0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0, // Hips/legs together
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0, // Thighs spreading
        0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0, // Knees spreading more
        0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0, // Feet (widest)
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ]

    // Frame 2: Standing (Barbell overhead) - arms wide, original straight legs
    private let frame2 = [
        0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0, // Weights ABOVE bar
        0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0, // Bar with weights
        0,0,2,2,1,0,0,0,0,0,0,1,2,2,0,0, // Weights + Arms wide at top
        0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0, // Arms wide
        0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0, // Arms angling in + Head
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Head
        0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0, // Shoulders
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Torso
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Torso
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0, // Hips/legs together
        0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0, // Upper legs
        0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0, // Legs
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0, // Lower legs
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0, // Feet
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ]

    private let columns = Array(repeating: GridItem(.fixed(1), spacing: 0), count: 16)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.6)) { context in
            let frameIndex = Int(context.date.timeIntervalSince1970 / 0.6) % 2
            let currentFrame = frameIndex == 0 ? frame1 : frame2

            LazyVGrid(columns: columns.map { _ in GridItem(.fixed(pixelSize), spacing: 0) }, spacing: 0) {
                ForEach(0..<256, id: \.self) { index in
                    Rectangle()
                        .fill(colorForPixel(currentFrame[index]))
                        .frame(width: pixelSize, height: pixelSize)
                }
            }
            .frame(width: pixelSize * 16, height: pixelSize * 16)
        }
    }

    private func colorForPixel(_ value: Int) -> Color {
        switch value {
        case 1: return themeManager.currentTheme.textColor  // Man
        case 2: return themeManager.currentTheme.textColor  // Barbell
        default: return .clear // Background
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RetroLifterView(pixelSize: 10)
        RetroLifterView(pixelSize: 6)
    }
    .padding()
    .background(.white)
    .environment(ThemeManager())
}
