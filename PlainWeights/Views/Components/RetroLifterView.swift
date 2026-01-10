//
//  RetroLifterView.swift
//  PlainWeights
//
//  Animated 16x16 pixel art of a weightlifter in ZX Spectrum style
//

import SwiftUI

struct RetroLifterView: View {
    var pixelSize: CGFloat = 10

    // Frame 1: Squatting (Barbell at chest level)
    private let frame1 = [
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,2,2,2,2,2,2,2,2,2,2,0,0,0,
        0,0,2,2,0,0,1,1,1,1,0,0,2,2,0,0,
        0,0,2,2,0,1,1,1,1,1,1,0,2,2,0,0,
        0,0,0,0,1,0,1,1,1,1,0,1,0,0,0,0,
        0,0,0,0,1,0,1,1,1,1,0,1,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,
        0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,
        0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ]

    // Frame 2: Standing (Barbell overhead)
    private let frame2 = [
        0,0,0,2,2,2,2,2,2,2,2,2,2,0,0,0,
        0,0,2,2,0,0,0,0,0,0,0,0,2,2,0,0,
        0,0,2,2,0,1,0,0,0,0,1,0,2,2,0,0,
        0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,
        0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,
        0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,
        0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,
        0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,
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
        case 1: return .black  // Man
        case 2: return .black  // Barbell
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
}
