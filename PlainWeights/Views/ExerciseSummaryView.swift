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
    let exercise: Exercise
    @Binding var addSetConfig: AddSetConfig?
    let lastWorkingSetValues: (weight: Double?, reps: Int?)

    // Cache expensive calculation in computed property
    private var sessionMetrics: ExerciseSessionMetricsData {
        ExerciseSessionMetrics.getSessionMetricsWithDefaults(from: sets)
    }

    // Detect exercise type for adaptive UI
    private var exerciseType: ExerciseMetricsType {
        ExerciseMetricsType.determine(from: sets)
    }

    // Rep-based metrics for reps-only exercises
    private var todayTotalReps: Int {
        RepsAnalytics.getTodayTotalReps(from: sets)
    }

    private var lastSessionTotalReps: Int {
        RepsAnalytics.getLastSessionTotalReps(from: sets)
    }

    private var maxRepsLastSession: Int {
        RepsAnalytics.getMaxRepsFromLastSession(from: sets)
    }

    // Direction indicators for volume/reps comparison
    private var volumeDirection: ProgressTracker.PRDirection {
        ProgressTracker.volumeComparisonDirection(
            today: progressState.todayVolume,
            last: progressState.lastCompletedDayInfo?.volume ?? 0
        )
    }

    private var repsDirection: ProgressTracker.PRDirection {
        ProgressTracker.volumeComparisonDirection(
            today: Double(todayTotalReps),
            last: Double(lastSessionTotalReps)
        )
    }

    // Calculate volume difference (positive = over, negative = left)
    private var volumeDifference: (amount: Double, label: String)? {
        guard progressState.todayVolume > 0 else { return nil }

        let lastVolume = progressState.lastCompletedDayInfo?.volume ?? 0
        let diff = progressState.todayVolume - lastVolume

        if diff > 0 {
            return (diff, "over")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
    }

    // Calculate reps difference (positive = over, negative = left)
    private var repsDifference: (amount: Int, label: String)? {
        guard todayTotalReps > 0 else { return nil }

        let diff = todayTotalReps - lastSessionTotalReps
        if diff > 0 {
            return (diff, "over")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // SECTION 1: Last Lifted (full width) - Adaptive based on exercise type
            VStack(alignment: .leading, spacing: 4) {
                // Title with date inline - changes based on exercise type
                HStack(spacing: 4) {
                    Text(exerciseType == .repsOnly ? "MAX REPS LAST DONE" : "MAX LAST LIFTED")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    if let lastCompletedInfo = progressState.lastCompletedDayInfo {
                        Text("(\(Formatters.formatAbbreviatedDayHeader(lastCompletedInfo.date)))")
                            .font(.caption2.italic())
                            .foregroundStyle(.secondary)
                    }
                }

                // Hero number - weight for weight-based, reps for reps-only
                if exerciseType == .repsOnly {
                    // Reps-only: Show max reps as hero number
                    Text("\(maxRepsLastSession)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(maxRepsLastSession > 0 ? .primary : .secondary)
                } else {
                    // Weight-only or Combined: Show weight as hero number
                    Text(ExerciseSetFormatters.formatLastMaxWeight(weight: sessionMetrics.lastSessionMaxWeight, reps: sessionMetrics.lastSessionMaxWeightReps))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)

                    // Show reps subtitle only for combined exercises
                    if exerciseType == .combined && sessionMetrics.lastSessionMaxWeightReps > 0 {
                        Text("\(sessionMetrics.lastSessionMaxWeightReps) reps")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }

            // SECTION 2 & 3: Today's Progression (split horizontally)
            HStack(alignment: .top, spacing: 16) {
                // SECTION 2: Today's Progression (top left) - Adaptive indicators
                VStack(alignment: .leading, spacing: 6) {
                    Text("PROGRESSION")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    if let personalRecords = progressState.personalRecords {
                        HStack(spacing: 8) {
                            // Show weight indicator for weight-only and combined exercises
                            if exerciseType == .weightOnly || exerciseType == .combined {
                                PersonalRecordIndicator(
                                    improvement: personalRecords.weightImprovement,
                                    direction: personalRecords.weightDirection,
                                    unit: "kg"
                                )
                            }

                            // Show reps indicator for reps-only and combined exercises
                            if exerciseType == .repsOnly || exerciseType == .combined {
                                PersonalRecordIndicator(
                                    improvement: Double(personalRecords.repsImprovement),
                                    direction: personalRecords.repsDirection,
                                    unit: " reps"
                                )
                            }
                        }
                    } else {
                        Text("Add a set to see progression metrics")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                // SECTION 3: Volume/Reps (top right) - Adaptive based on exercise type
                VStack(alignment: .trailing, spacing: 6) {
                    // Title changes: VOLUME for weight-based, TOTAL REPS for reps-only
                    Text(exerciseType == .repsOnly ? "TOTAL REPS" : "VOLUME")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            if exerciseType == .repsOnly {
                                // Reps-only: Show cumulative reps comparison in black
                                Text("\(todayTotalReps)/\(lastSessionTotalReps) reps")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                // Show arrow only when sets have been entered
                                if todayTotalReps > 0 {
                                    Image(systemName: repsDirection.iconName)
                                        .font(.caption)
                                        .foregroundStyle(repsDirection.color)
                                }
                            } else {
                                // Weight-only or Combined: Show weight volume in black
                                Text("\(Formatters.formatVolume(progressState.todayVolume))/\(Formatters.formatVolume(progressState.lastCompletedDayInfo?.volume ?? 0)) \(progressState.unit)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                // Show arrow only when sets have been entered
                                if progressState.todayVolume > 0 {
                                    Image(systemName: volumeDirection.iconName)
                                        .font(.caption)
                                        .foregroundStyle(volumeDirection.color)
                                }
                            }
                        }

                        // Show difference (left/over) with directional color
                        if exerciseType == .repsOnly {
                            if let diff = repsDifference {
                                let repsText = diff.amount == 1 ? "rep" : "reps"
                                Text("\(diff.amount) \(repsText) \(diff.label)")
                                    .font(.caption)
                                    .foregroundStyle(repsDirection.color)
                            }
                        } else {
                            if let diff = volumeDifference {
                                Text("\(Formatters.formatVolume(diff.amount)) \(progressState.unit) \(diff.label)")
                                    .font(.caption)
                                    .foregroundStyle(volumeDirection.color)
                            }
                        }
                    }
                }
            }

            // SECTION 4: Action buttons (bottom full width)
            HStack(spacing: 8) {
                Spacer()

                // Add Previous Set button
                Button(action: {
                    addSetConfig = .previous(
                        exercise: exercise,
                        weight: lastWorkingSetValues.weight,
                        reps: lastWorkingSetValues.reps
                    )
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .foregroundStyle(.gray)
                        Text("Add Previous")
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                // Add Set button
                Button(action: {
                    addSetConfig = .empty(exercise: exercise)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Add Set")
                            .foregroundStyle(.black)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.top, 16)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

