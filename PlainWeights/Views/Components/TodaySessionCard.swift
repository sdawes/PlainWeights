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

            // Content area - empty state only (progress bar moved to ComparisonMetricsCard)
            if setCount == 0 {
                HStack(spacing: 4) {
                    Text("Press")
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                    Text("to add a set and get going")
                }
                .font(themeManager.effectiveTheme.interFont(size: 14))
                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(16)
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
