//
//  ExerciseSummaryView.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 20/09/2025.
//

import SwiftUI
import SwiftData

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
                // Left: Max weight with reps underneath
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last max weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text(ExerciseSetFormatters.formatLastMaxWeight(
                        weight: sessionMetrics.lastSessionMaxWeight,
                        reps: sessionMetrics.lastSessionMaxWeightReps
                    ))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)

                    Text(ExerciseSetFormatters.formatMaxWeightDetails(
                        weight: sessionMetrics.lastSessionMaxWeight,
                        reps: sessionMetrics.lastSessionMaxWeightReps,
                        sets: sessionMetrics.lastSessionTotalSets
                    ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Right: Total volume
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Last session total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text("\(Formatters.formatVolume(sessionMetrics.lastSessionTotalVolume)) kg")
                        .font(.headline.bold())
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)
                }
            }
                .padding(.bottom, 16)

                // Today's progress section (integrated)
                VStack(alignment: .leading, spacing: 12) {
                    // Adaptive header based on exercise type
                    Text(progressState.progressLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    // Volume and percentage row
                    HStack {
                        Text("\(Formatters.formatVolume(progressState.todayVolume)) \(progressState.unit)")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)

                        Spacer()

                        if progressState.canCompareToLast || sessionMetrics.todaysVolume > 0 {
                            Text("\(progressState.percentOfLast)% of last")
                                .font(.headline)
                                .foregroundStyle(progressState.barFillColor)
                        } else if sessionMetrics.hasHistoricalData && !progressState.canCompareToLast {
                            Text(progressState.deltaText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Progress bar - always shown when requested
                    if progressState.showProgressBar {
                        if progressState.canCompareToLast {
                            // Normal progress bar with comparison
                            ProgressView(value: Double(progressState.progressBarRatio))
                                .progressViewStyle(LinearProgressViewStyle(tint: progressState.barFillColor))
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)
                        } else {
                            // Progress bar for new exercises or type changes - show as 100% if today has volume
                            let newExerciseProgress = sessionMetrics.todaysVolume > 0 ? 1.0 : 0.0
                            ProgressView(value: newExerciseProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: sessionMetrics.todaysVolume > 0 ? .green : .secondary.opacity(0.3)))
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                .animation(.easeInOut(duration: 0.3), value: newExerciseProgress)
                        }
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
                Text("\(Formatters.formatVolume(progressState.todayVolume)) kg")
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
