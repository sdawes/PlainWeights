//
//  ExerciseSummaryView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 20/09/2025.
//

import SwiftUI
import SwiftData

// MARK: - Personal Record Indicator Component

struct PersonalRecordIndicator: View {
    let improvement: Double
    let direction: ProgressTracker.PRDirection
    let unit: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: direction.iconName)
                .font(.caption2)
                .foregroundStyle(direction.color)
            Text("\(improvement > 0 ? "+" : improvement < 0 ? "-" : "")\(formatImprovement())\(unit)")
                .font(.caption2.bold())
                .foregroundStyle(direction.color)
        }
    }

    private func formatImprovement() -> String {
        // Handle zero case for same performance
        if improvement == 0 {
            return "0"
        }

        if unit == "kg" {
            return Formatters.formatWeight(abs(improvement))
        } else {
            return String(Int(abs(improvement)))
        }
    }
}

struct ExerciseSummaryView: View {
    let progressState: ProgressTracker.ProgressState
    let sets: [ExerciseSet]

    // Cache expensive calculation in computed property
    private var sessionMetrics: ExerciseSessionMetricsData {
        ExerciseSessionMetrics.getSessionMetricsWithDefaults(from: sets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Title and date with sets underneath
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Max last lifted")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if let lastCompletedInfo = progressState.lastCompletedDayInfo {
                        Text(Formatters.formatAbbreviatedDayHeader(lastCompletedInfo.date))
                            .font(.caption2.italic())
                            .foregroundStyle(.secondary)
                    }

                    if sessionMetrics.lastSessionTotalSets > 0 {
                        Text("\(sessionMetrics.lastSessionTotalSets) sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Hero number section: weight on left with reps underneath
            VStack(alignment: .leading, spacing: 4) {
                Text(ExerciseSetFormatters.formatLastMaxWeight(
                    weight: sessionMetrics.lastSessionMaxWeight,
                    reps: sessionMetrics.lastSessionMaxWeightReps
                ))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)

                if sessionMetrics.lastSessionMaxWeightReps > 0 {
                    Text("\(sessionMetrics.lastSessionMaxWeightReps) reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Grid section: Today comparison + Volume
            HStack(alignment: .top, spacing: 16) {
                // Left column: Today metrics
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    if let personalRecords = progressState.personalRecords {
                        HStack(spacing: 8) {
                            PersonalRecordIndicator(
                                improvement: personalRecords.weightImprovement,
                                direction: personalRecords.weightDirection,
                                unit: "kg"
                            )
                            PersonalRecordIndicator(
                                improvement: Double(personalRecords.repsImprovement),
                                direction: personalRecords.repsDirection,
                                unit: " reps"
                            )
                        }
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                // Right column: Volume metrics
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Volume")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    HStack(spacing: 4) {
                        Text("\(Formatters.formatVolume(progressState.todayVolume))/\(Formatters.formatVolume(progressState.lastCompletedDayInfo?.volume ?? 0)) \(progressState.unit)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(progressState.todayVolume >= (progressState.lastCompletedDayInfo?.volume ?? 0) ? .green : .primary)

                        if progressState.todayVolume > (progressState.lastCompletedDayInfo?.volume ?? 0) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background {
            ZStack {
                // Ultra-thin material blur for glassmorphism
                Color.clear
                    .background(.ultraThinMaterial)

                // Light blue to white gradient for transparent glass appearance
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.4),
                        Color.white.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

