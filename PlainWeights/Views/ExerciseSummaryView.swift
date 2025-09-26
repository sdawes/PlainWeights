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

    var body: some View {
        VStack(spacing: 16) {
            // Get session metrics (always available, with zero defaults for new exercises)
            let sessionMetrics = ExerciseSessionMetrics.getSessionMetricsWithDefaults(from: sets)

            // Last session metrics section - always shown
            HStack(alignment: .top) {
                // Left: Max weight with reps underneath
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last max weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text("\(Formatters.formatWeight(sessionMetrics.lastSessionMaxWeight)) kg")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)

                    Text("\(sessionMetrics.lastSessionMaxWeightReps) reps • \(sessionMetrics.lastSessionTotalSets) sets")
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

                        if sessionMetrics.hasHistoricalData {
                            Text("\(progressState.percentOfLast)% of last")
                                .font(.headline)
                                .foregroundStyle(progressState.barFillColor)
                        }
                    }

                    // Progress bar - always shown but greyed out for new exercises
                    ProgressView(value: sessionMetrics.hasHistoricalData ? Double(progressState.progressBarRatio) : 0.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: sessionMetrics.hasHistoricalData ? progressState.barFillColor : .secondary))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .animation(.easeInOut(duration: 0.3), value: progressState.progressBarRatio)

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

                if progressState.lastCompletedDayInfo != nil {
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
