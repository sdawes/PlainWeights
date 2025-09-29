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
        VStack(spacing: 8) {
            // Card 1: Max Last Lifted (Full Width)
            MaxLastLiftedCard(
                sessionMetrics: sessionMetrics,
                lastCompletedInfo: progressState.lastCompletedDayInfo
            )

            // Card 2 & 3: Set Comparison and Today's Volume (Side by Side)
            HStack(spacing: 8) {
                SetComparisonCard(
                    progressLabel: progressState.progressLabel,
                    personalRecords: progressState.personalRecords
                )

                TodaysVolumeCard(
                    todayVolume: progressState.todayVolume,
                    lastVolume: progressState.lastCompletedDayInfo?.volume ?? 0,
                    unit: progressState.unit
                )
            }
        }
        .listRowSeparator(.hidden)
        .padding(.vertical, 8)
    }
}

// MARK: - Card Components

private struct MaxLastLiftedCard: View {
    let sessionMetrics: ExerciseSessionMetricsData
    let lastCompletedInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int)?

    var body: some View {
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

            if let lastCompletedInfo = lastCompletedInfo {
                Text(Formatters.formatAbbreviatedDayHeader(lastCompletedInfo.date))
                    .font(.caption2.italic())
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 70)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

private struct SetComparisonCard: View {
    let progressLabel: String
    let personalRecords: ProgressTracker.PersonalRecordIndicators?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(progressLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if let personalRecords = personalRecords {
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
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 70)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

private struct TodaysVolumeCard: View {
    let todayVolume: Double
    let lastVolume: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's volume")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text("\(Formatters.formatVolume(todayVolume))/\(Formatters.formatVolume(lastVolume)) \(unit)")
                .font(.headline.bold())
                .foregroundStyle(todayVolume >= lastVolume ? .green : .primary)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 70)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
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
