//
//  TodaySessionCard.swift
//  PlainWeights
//
//  Header and progress bar for today's workout session.
//  Used as the top row of the TODAY card in ExerciseDetailView.
//

import SwiftUI

struct TodaySessionCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let volume: Double
    let durationMinutes: Int?
    let comparisonVolume: Double
    let comparisonLabel: String
    let isWeightedExercise: Bool
    let totalReps: Int
    let setCount: Int
    let hasSetsBelow: Bool  // If true, only top corners rounded; if false, all corners

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                Text("TODAY")
                    .font(themeManager.currentTheme.interFont(size: 13, weight: .bold))
                    .foregroundStyle(themeManager.currentTheme.accent)
                    .tracking(1.2)

                Spacer()

                HStack(spacing: 4) {
                    if isWeightedExercise {
                        Text("Volume: \(Formatters.formatVolume(volume)) kg")
                    } else {
                        Text("\(totalReps) reps")
                    }
                    if let mins = durationMinutes {
                        Text(".")
                        Text("\(mins) min")
                    }
                }
                .font(themeManager.currentTheme.interFont(size: 13, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.currentTheme.muted.opacity(0.3))

            // Divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Progress bar (if applicable)
            if isWeightedExercise && comparisonVolume > 0 {
                VolumeProgressBar(
                    currentVolume: volume,
                    targetVolume: comparisonVolume,
                    targetLabel: comparisonLabel
                )
                .padding(16)
            } else {
                // Show set count when no progress bar
                HStack {
                    Text("\(setCount) sets")
                        .font(themeManager.currentTheme.interFont(size: 14))
                        .foregroundStyle(themeManager.currentTheme.secondaryText)
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedCorner(radius: 12, corners: hasSetsBelow ? [.topLeft, .topRight] : .allCorners))
        .overlay(
            RoundedCorner(radius: 12, corners: hasSetsBelow ? [.topLeft, .topRight] : .allCorners)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }
}
