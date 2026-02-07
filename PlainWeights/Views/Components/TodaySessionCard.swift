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
    let comparisonReps: Int  // For reps-only exercises
    let comparisonLabel: String
    let isWeightedExercise: Bool
    let totalReps: Int
    let setCount: Int
    let hasSetsBelow: Bool  // If true, only top corners rounded; if false, all corners

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 14))
                        .frame(width: 20)
                    Text("Today's Sets")
                        .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                }
                .foregroundStyle(themeManager.currentTheme.primaryText)

                Spacer()

                // Stats: running total + duration
                if setCount > 0 {
                    HStack(spacing: 12) {
                        // Running total (bold styling)
                        if isWeightedExercise {
                            (
                                Text(Formatters.formatVolume(volume))
                                    .font(themeManager.currentTheme.dataFont(size: 15, weight: .bold))
                                + Text(" kg")
                                    .font(themeManager.currentTheme.dataFont(size: 15, weight: .medium))
                            )
                            .foregroundStyle(themeManager.currentTheme.primaryText)
                        } else {
                            (
                                Text("\(totalReps)")
                                    .font(themeManager.currentTheme.dataFont(size: 15, weight: .bold))
                                + Text(" reps")
                                    .font(themeManager.currentTheme.dataFont(size: 15, weight: .medium))
                            )
                            .foregroundStyle(themeManager.currentTheme.primaryText)
                        }

                        // Duration
                        if let mins = durationMinutes {
                            Text("\(mins) min")
                                .font(themeManager.currentTheme.dataFont(size: 13))
                                .foregroundStyle(themeManager.currentTheme.tertiaryText)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Content area
            if setCount == 0 {
                // No sets logged yet
                Text("No sets logged yet")
                    .font(themeManager.currentTheme.interFont(size: 14))
                    .foregroundStyle(themeManager.currentTheme.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
            } else if !isWeightedExercise && comparisonReps > 0 {
                // Progress bar for reps-only exercises
                VolumeProgressBar(
                    currentVolume: Double(totalReps),
                    targetVolume: Double(comparisonReps),
                    targetLabel: comparisonLabel,
                    isRepsOnly: true
                )
                .padding(16)
            } else if comparisonVolume > 0 {
                // Progress bar for weighted exercises with comparison data
                VolumeProgressBar(
                    currentVolume: volume,
                    targetVolume: comparisonVolume,
                    targetLabel: comparisonLabel,
                    isRepsOnly: false
                )
                .padding(16)
            } else {
                // Empty progress bar when no comparison data
                VStack(alignment: .leading, spacing: 6) {
                    // Empty progress bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.currentTheme.muted)
                        .frame(height: 8)

                    // Explanatory text
                    Text("Next session will compare to this one")
                        .font(themeManager.currentTheme.captionFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                .padding(16)
            }

            // Bottom divider (when sets follow below)
            if hasSetsBelow {
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(height: 1)
            }
        }
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedCorner(radius: 12, corners: hasSetsBelow ? [.topLeft, .topRight] : .allCorners))
        .overlay(borderOverlay)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if hasSetsBelow {
            TopOpenBorder(radius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        } else {
            RoundedCorner(radius: 12, corners: .allCorners)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        }
    }
}
