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
                .font(.callout)
                .foregroundStyle(direction.color)
            Text(formatText())
                .font(.callout)
                .foregroundStyle(direction.color)
        }
    }

    private func formatText() -> String {
        // Format the value
        let value: String
        if unit == "kg" {
            value = Formatters.formatWeight(abs(improvement))
        } else {
            value = String(Int(abs(improvement)))
        }

        // Return just value and unit (no descriptive words)
        return "\(value)\(unit)"
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

    // Rep-based metrics
    private var todayTotalReps: Int {
        RepsAnalytics.getTodayTotalReps(from: sets)
    }

    // Direction indicator for weight volume comparison
    private var volumeDirection: ProgressTracker.PRDirection {
        ProgressTracker.volumeComparisonDirection(
            today: progressState.todayVolume,
            last: progressState.lastCompletedDayInfo?.volume ?? 0
        )
    }

    // Weight volume difference (positive = more, negative = left)
    private var volumeDifference: (amount: Double, label: String)? {
        guard progressState.todayVolume > 0 else { return nil }

        let lastVolume = progressState.lastCompletedDayInfo?.volume ?? 0
        let diff = progressState.todayVolume - lastVolume

        if diff > 0 {
            return (diff, "more")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
    }

    // Reps volume direction (today's total reps vs last session total reps volume)
    private var repsVolumeDirection: ProgressTracker.PRDirection {
        ProgressTracker.volumeComparisonDirection(
            today: Double(todayTotalReps),
            last: Double(sessionMetrics.lastSessionTotalRepsVolume)
        )
    }

    // Reps volume difference (positive = over, negative = left)
    private var repsVolumeDifference: (amount: Int, label: String)? {
        RepsAnalytics.calculateRepsVolumeDifference(
            todayTotal: todayTotalReps,
            lastSessionTotal: sessionMetrics.lastSessionTotalRepsVolume
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ROW 1: Max Weight and Associated Reps (unified section)
            VStack(alignment: .leading, spacing: 12) {
                // Title on left, date on right (date bottom-aligned with title)
                HStack(alignment: .bottom, spacing: 0) {
                    Text("MAX LAST LIFTED")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 12)

                    if let lastCompletedInfo = progressState.lastCompletedDayInfo {
                        Text(Formatters.formatAbbreviatedDayHeader(lastCompletedInfo.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 12)
                    }
                }

                // Values row - mirroring Row 2 column structure
                HStack(alignment: .bottom, spacing: 0) {
                    // Left column: Max weight value (aligned with WEIGHT PROGRESSION)
                    Text("\(Formatters.formatWeight(sessionMetrics.lastSessionMaxWeight)) kg")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 12)

                    // Right column: Reps value (aligned with REPS PROGRESSION)
                    Text("\(sessionMetrics.lastSessionMaxWeightReps) reps")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(sessionMetrics.hasHistoricalData ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                }
            }

            // ROW 2 & 3: All sections with vertical dividers
            HStack(alignment: .top, spacing: 0) {
                // LEFT COLUMN: Weight Progress + Weight Volume
                VStack(alignment: .leading, spacing: 0) {
                    // SECTION 2: Weight Progress
                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()

                        if let personalRecords = progressState.personalRecords {
                            PersonalRecordIndicator(
                                improvement: personalRecords.weightImprovement,
                                direction: personalRecords.weightDirection,
                                unit: "kg"
                            )
                        } else {
                            Text("0 kg")
                                .font(.callout)
                                .foregroundStyle(.primary)
                        }

                        Spacer()
                    }
                    .frame(height: 70)

                    // Divider between section 2 and 4
                    Divider()
                        .padding(.vertical, 8)

                    // SECTION 4: Weight Volume (below section 2)
                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                // Show arrow first when sets have been entered
                                if progressState.todayVolume > 0 {
                                    Image(systemName: volumeDirection.iconName)
                                        .font(.callout)
                                        .foregroundStyle(volumeDirection.color)
                                }

                                // Weight volume comparison
                                Text("\(Formatters.formatVolume(progressState.todayVolume))/\(Formatters.formatVolume(progressState.lastCompletedDayInfo?.volume ?? 0)) \(progressState.unit)")
                                    .font(.callout)
                                    .foregroundStyle(.primary)
                            }

                            // Show difference (left/more) with directional color
                            if let diff = volumeDifference {
                                Text("\(Formatters.formatVolume(diff.amount)) \(progressState.unit) \(diff.label)")
                                    .font(.caption.italic())
                                    .foregroundStyle(volumeDirection.color)
                            }
                        }

                        Spacer()
                    }
                    .frame(height: 70)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 12)

                Divider()

                // RIGHT COLUMN: Reps Progress + Reps Volume
                VStack(alignment: .leading, spacing: 0) {
                    // SECTION 3: Reps Progress
                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()

                        if let personalRecords = progressState.personalRecords {
                            PersonalRecordIndicator(
                                improvement: Double(personalRecords.repsImprovement),
                                direction: personalRecords.repsDirection,
                                unit: " reps"
                            )
                        } else {
                            Text("0 reps")
                                .font(.callout)
                                .foregroundStyle(.primary)
                        }

                        Spacer()
                    }
                    .frame(height: 70)

                    // Divider between section 3 and 5
                    Divider()
                        .padding(.vertical, 8)

                    // SECTION 5: Reps Volume (below section 3)
                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                // Show arrow first when sets have been entered
                                if todayTotalReps > 0 {
                                    Image(systemName: repsVolumeDirection.iconName)
                                        .font(.callout)
                                        .foregroundStyle(repsVolumeDirection.color)
                                }

                                // Reps volume comparison
                                Text("\(todayTotalReps)/\(sessionMetrics.lastSessionTotalRepsVolume) reps")
                                    .font(.callout)
                                    .foregroundStyle(.primary)
                            }

                            // Show difference (left/more) with directional color
                            if let diff = repsVolumeDifference {
                                let repsText = diff.amount == 1 ? "rep" : "reps"
                                Text("\(diff.amount) \(repsText) \(diff.label)")
                                    .font(.caption.italic())
                                    .foregroundStyle(repsVolumeDirection.color)
                            }
                        }

                        Spacer()
                    }
                    .frame(height: 70)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            }

            // SECTION 7: Action buttons (bottom full width)
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

