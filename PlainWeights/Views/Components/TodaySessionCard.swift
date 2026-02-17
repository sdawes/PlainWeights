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
    var exerciseTypeChanged: Bool = false  // True when exercise switched between bodyweight and weighted

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 14))
                        .frame(width: 20)
                    Text("Today's Sets")
                        .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                }
                .foregroundStyle(themeManager.effectiveTheme.primaryText)

                Spacer()

                // Stats: running total + duration
                if setCount > 0 {
                    HStack(spacing: 12) {
                        // Running total (bold styling)
                        if isWeightedExercise {
                            HStack(spacing: 0) {
                                Text(Formatters.formatVolume(themeManager.displayWeight(volume)))
                                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .bold))
                                Text(" \(themeManager.weightUnit.displayName)")
                                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .medium))
                            }
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        } else {
                            HStack(spacing: 0) {
                                Text("\(totalReps)")
                                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .bold))
                                Text(" reps")
                                    .font(themeManager.effectiveTheme.dataFont(size: 15, weight: .medium))
                            }
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        }

                        // Duration
                        if let mins = durationMinutes {
                            Text("\(mins) min")
                                .font(themeManager.effectiveTheme.dataFont(size: 13))
                                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Content area
            if setCount == 0 {
                // No sets logged yet
                Text("No sets logged yet")
                    .font(themeManager.effectiveTheme.interFont(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
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
                // First session — preview bar + baseline + motivational nudge
                VStack(alignment: .leading, spacing: 6) {
                    if exerciseTypeChanged {
                        // Empty bar for type switch
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.effectiveTheme.muted)
                            .frame(height: 8)

                        Text("Switched to weighted — comparison starts next session")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    } else {
                        // Muted preview bar with progress fill
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(themeManager.effectiveTheme.muted)
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(themeManager.effectiveTheme.mutedForeground.opacity(0.3))
                                    .frame(width: geometry.size.width * 0.6, height: 8)
                            }
                        }
                        .frame(height: 8)

                        if isWeightedExercise {
                            Text("\(Formatters.formatVolume(themeManager.displayWeight(volume))) \(themeManager.weightUnit.displayName) total volume")
                                .font(themeManager.effectiveTheme.captionFont)
                                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                        } else {
                            Text("\(totalReps) total reps")
                                .font(themeManager.effectiveTheme.captionFont)
                                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                        }

                        Text(isWeightedExercise
                            ? "Next session will track volume vs today"
                            : "Next session will track reps vs today")
                            .font(themeManager.effectiveTheme.captionFont)
                            .italic()
                            .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                    }
                }
                .padding(16)
            }

            // Bottom divider (when sets follow below)
            if hasSetsBelow {
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(height: 1)
            }
        }
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedCorner(radius: 12, corners: hasSetsBelow ? [.topLeft, .topRight] : .allCorners))
        .overlay(borderOverlay)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if hasSetsBelow {
            TopOpenBorder(radius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        } else {
            RoundedCorner(radius: 12, corners: .allCorners)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        }
    }
}
