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
        VStack(spacing: 16) {

            // Last session metrics section - always shown
            HStack(alignment: .top) {
                // Left: Max weight with details on right
                VStack(alignment: .leading, spacing: 2) {
                    Text("Max last lifted")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(ExerciseSetFormatters.formatLastMaxWeight(
                            weight: sessionMetrics.lastSessionMaxWeight,
                            reps: sessionMetrics.lastSessionMaxWeightReps
                        ))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)

                        Text("(\(ExerciseSetFormatters.formatMaxWeightDetails(weight: sessionMetrics.lastSessionMaxWeight, reps: sessionMetrics.lastSessionMaxWeightReps, sets: sessionMetrics.lastSessionTotalSets)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let lastCompletedInfo = progressState.lastCompletedDayInfo {
                        Text(Formatters.formatAbbreviatedDayHeader(lastCompletedInfo.date))
                            .font(.caption2.italic())
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
                .padding(.bottom, 16)

                // Today's progress section with dual headers
                VStack(alignment: .leading, spacing: 8) {
                    // Dual headers row
                    HStack {
                        Text(progressState.progressLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        Spacer()

                        Text("Today's volume")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }

                    // Values row: Personal record indicators and volume comparison
                    HStack {
                        // Personal record indicators on the left
                        if let personalRecords = progressState.personalRecords {
                            HStack(spacing: 4) {
                                // Weight improvement indicator
                                PersonalRecordIndicator(
                                    improvement: personalRecords.weightImprovement,
                                    direction: personalRecords.weightDirection,
                                    unit: "kg"
                                )

                                // Reps improvement indicator
                                PersonalRecordIndicator(
                                    improvement: Double(personalRecords.repsImprovement),
                                    direction: personalRecords.repsDirection,
                                    unit: " reps"
                                )
                            }
                        }

                        Spacer()

                        // Volume comparison as fraction - always show comparison (use 0 for new exercises)
                        let lastVolume = progressState.lastCompletedDayInfo?.volume ?? 0
                        Text("\(Formatters.formatVolume(progressState.todayVolume))/\(Formatters.formatVolume(lastVolume)) \(progressState.unit)")
                            .font(.headline.bold())
                            .foregroundStyle(progressState.todayVolume >= lastVolume ? .green : .primary)
                    }
                }
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

// MARK: - Today Progress Component

private struct TodayProgressComponent: View {
    let progressState: ProgressTracker.ProgressState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Lifted today")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            // Volume and percentage row
            HStack {
                Text("\(Formatters.formatVolume(progressState.todayWeightVolume)) kg")
                    .font(.headline.bold())
                    .foregroundStyle(.primary)

                Spacer()

                if progressState.canCompareToLast || progressState.todayVolume > 0 {
                    Text("\(progressState.percentOfLast)% of last")
                        .font(.headline)
                        .foregroundStyle(progressState.barFillColor)
                }
            }

            // Modern progress bar
            if progressState.lastCompletedDayInfo != nil {
                ProgressView(value: Double(progressState.progressBarRatio))
                    .progressViewStyle(LinearProgressViewStyle(tint: progressState.barFillColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)
            }

        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
