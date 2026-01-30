//
//  FloatingRestTimer.swift
//  PlainWeights
//
//  Floating circular progress timer that appears when resting between sets.
//  Shows elapsed time with a progress ring that fills over 3 minutes.
//

import SwiftUI

struct FloatingRestTimer: View {
    let setTimestamp: Date
    @Environment(ThemeManager.self) private var themeManager

    private let maxTime: Double = 180  // 3 minutes

    // Color changes based on elapsed time
    private func timerColor(for elapsed: Double) -> Color {
        if elapsed >= 90 {
            return .red
        } else if elapsed >= 60 {
            return .orange
        } else {
            return themeManager.currentTheme.primary
        }
    }

    var body: some View {
        TimelineView(.periodic(from: setTimestamp, by: 1.0)) { context in
            let elapsed = context.date.timeIntervalSince(setTimestamp)

            if elapsed < maxTime {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(themeManager.currentTheme.muted, lineWidth: 5)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsed / maxTime))
                        .stroke(
                            timerColor(for: elapsed),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: elapsed)

                    // Time text
                    Text(Formatters.formatDuration(elapsed))
                        .font(themeManager.currentTheme.dataFont(size: 24, weight: .bold))
                        .foregroundStyle(timerColor(for: elapsed))
                }
                .frame(width: 72, height: 72)
                .padding(14)
                .background(themeManager.currentTheme.cardBackgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            }
        }
    }
}

#Preview {
    FloatingRestTimer(setTimestamp: Date().addingTimeInterval(-45))
        .environment(ThemeManager())
}
