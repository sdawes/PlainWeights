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
            // Combined metrics in single bordered component
            if let maxStats = VolumeAnalytics.getMaxWeightAndSessionStats(from: sets),
               let totalVolume = progressState.lastCompletedDayInfo?.volume {

                // Last session metrics section
                HStack(alignment: .top) {
                    // Left: Max weight with reps underneath
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Last max weight")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        Text("\(Formatters.formatWeight(maxStats.weight)) kg")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("\(maxStats.maxReps) reps • \(maxStats.totalSets) sets")
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

                        Text("\(Formatters.formatVolume(totalVolume)) kg")
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
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
            } else {
                // Show today's progress even if no last session data
                TodayProgressComponent(progressState: progressState)
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
