//
//  SessionSummaryView.swift
//  PlainWeights
//
//  Session summary view showing workout stats and exercises
//

import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @Query private var allSets: [ExerciseSet]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

            if let day = displayDay {
                List {
                    // Session info card
                    Section {
                        sessionInfoCard(for: day)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    // Exercises section
                    Section {
                        exercisesHeader
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        ForEach(day.exercises, id: \.id) { exercise in
                            exerciseCard(for: exercise, displayedDay: day.date)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            } else {
                // Empty state
                Spacer()
                VStack(spacing: 12) {
                    RetroLifterView(pixelSize: 5)

                    Text("No Workouts Yet")
                        .font(themeManager.currentTheme.title2Font)

                    Text("Complete your first workout to see a summary here.")
                        .font(themeManager.currentTheme.subheadlineFont)
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                }
                Spacer()
            }
        }
        .background(AnimatedGradientBackground())
    }

    // MARK: - Computed Properties

    private var displayDay: ExerciseDataGrouper.WorkoutDay? {
        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: allSets)
        let todaySets = TodaySessionCalculator.getTodaysSets(from: allSets)

        if todaySets.isEmpty {
            return workoutDays.first
        } else {
            return workoutDays.first { Calendar.current.isDateInToday($0.date) }
        }
    }

    // MARK: - View Components

    private var headerView: some View {
        HStack {
            Text("Session Summary")
                .font(themeManager.currentTheme.title3Font)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func sessionInfoCard(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        let pbCount = day.exercises.flatMap { $0.sets }.filter { $0.isPB }.count
        let allSetsForDay = day.exercises.flatMap { $0.sets }
        let sessionDuration = SessionStatsCalculator.getSessionDurationMinutes(from: allSetsForDay)
        let sessionAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: allSetsForDay)

        VStack(alignment: .leading, spacing: 0) {
            // Header with date and duration
            HStack {
                Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                Spacer()
                if let duration = sessionDuration {
                    Text("\(duration) min")
                        .font(themeManager.currentTheme.dataFont(size: 14))
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.currentTheme.cardHeaderBackground)

            // Divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 1: Exercises, Sets, Volume
            HStack(spacing: 0) {
                metricCell(label: "Exercises", value: "\(day.exerciseCount)")
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Sets", value: "\(day.totalSets)")
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(day.totalVolume)) kg")
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 2: Duration, Avg Rest, PBs
            HStack(spacing: 0) {
                metricCell(
                    label: "Duration",
                    value: sessionDuration.map { "\($0) min" } ?? "—"
                )
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)
                metricCell(
                    label: "Avg Rest",
                    value: sessionAvgRest.map { formatRestTime($0) } ?? "—"
                )
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)
                pbMetricCell(pbCount: pbCount)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func metricCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            Text(value)
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
    }

    /// Metric cell that reserves space for delta row (used in exercise cards)
    @ViewBuilder
    private func metricCellWithDeltaSpace(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            Text(value)
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            // Empty space to match cells with deltas
            Text(" ")
                .font(themeManager.currentTheme.dataFont(size: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
    }

    @ViewBuilder
    private func pbMetricCell(pbCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PBs")
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            Text(pbCount > 0 ? "\(pbCount)" : "—")
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            ZStack {
                themeManager.currentTheme.cardBackgroundColor
                if pbCount > 0 {
                    Color.red.opacity(0.1)
                }
            }
        }
    }

    private var exercisesHeader: some View {
        Text("Exercises")
            .font(themeManager.currentTheme.interFont(size: 14, weight: .semibold))
            .foregroundStyle(themeManager.currentTheme.tertiaryText)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.leading, 8)
    }

    @ViewBuilder
    private func exerciseCard(for workoutExercise: ExerciseDataGrouper.WorkoutExercise, displayedDay: Date) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let workingSets = workoutExercise.sets.filter { !$0.isWarmUp && !$0.isBonus }
        let maxSet = workingSets.max(by: { $0.weight < $1.weight })
        let exerciseDuration = SessionStatsCalculator.getExerciseDurationMinutes(from: workoutExercise.sets)
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

        // Current session values
        let currentMaxWeight = maxSet?.weight ?? 0
        let currentMaxReps = maxSet?.reps ?? workingSets.map { $0.reps }.max() ?? 0
        let currentVolume = workoutExercise.volume

        // Get previous session data for comparison
        let previousSession = getPreviousSessionMetrics(
            for: workoutExercise.exercise,
            before: displayedDay
        )

        // Calculate deltas
        let weightDelta: Double? = previousSession.map { currentMaxWeight - $0.maxWeight }
        let repsDelta: Int? = previousSession.map { currentMaxReps - $0.maxReps }
        let volumeDelta: Double? = previousSession.map { currentVolume - $0.volume }

        VStack(alignment: .leading, spacing: 0) {
            // Header with exercise name and duration
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.currentTheme.secondaryText)
                Spacer()
                if let duration = exerciseDuration {
                    Text("\(duration) min")
                        .font(themeManager.currentTheme.dataFont(size: 14))
                        .monospacedDigit()
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.currentTheme.cardHeaderBackground)

            // Divider below header
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 1: Sets, Max
            HStack(spacing: 0) {
                metricCellWithDeltaSpace(label: "Sets", value: "\(workoutExercise.setCount)")

                // Vertical divider
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)

                if currentMaxWeight > 0 {
                    maxMetricCellWithDelta(
                        weight: currentMaxWeight,
                        reps: currentMaxReps,
                        weightDelta: weightDelta,
                        repsDelta: repsDelta,
                        hasPB: hasPB
                    )
                } else {
                    // Reps-only exercise
                    repsOnlyMetricCellWithDelta(
                        reps: currentMaxReps,
                        repsDelta: repsDelta,
                        hasPB: hasPB
                    )
                }
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, Avg Rest
            HStack(spacing: 0) {
                volumeMetricCellWithDelta(
                    volume: currentVolume,
                    volumeDelta: volumeDelta
                )

                // Vertical divider
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(width: 1)

                metricCellWithDeltaSpace(label: "Avg Rest", value: formatRestTime(exerciseAvgRest))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Previous Session Comparison

    private struct PreviousSessionMetrics {
        let maxWeight: Double
        let maxReps: Int
        let volume: Double
    }

    /// Get metrics from the previous session for this exercise (before the displayed day)
    private func getPreviousSessionMetrics(for exercise: Exercise, before displayedDay: Date) -> PreviousSessionMetrics? {
        let calendar = Calendar.current
        let displayedDayStart = calendar.startOfDay(for: displayedDay)

        // Get all sets for this exercise before the displayed day
        let exerciseSets = allSets.filter { set in
            set.exercise?.persistentModelID == exercise.persistentModelID &&
            calendar.startOfDay(for: set.timestamp) < displayedDayStart &&
            !set.isWarmUp && !set.isBonus
        }

        guard !exerciseSets.isEmpty else { return nil }

        // Group by day and get the most recent
        let grouped = Dictionary(grouping: exerciseSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        guard let mostRecentDay = grouped.keys.max(),
              let previousDaySets = grouped[mostRecentDay] else {
            return nil
        }

        // Calculate metrics from previous session
        let maxSet = previousDaySets.max(by: { $0.weight < $1.weight })
        let maxWeight = maxSet?.weight ?? 0
        let maxReps = maxSet?.reps ?? previousDaySets.map { $0.reps }.max() ?? 0
        let volume = previousDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

        return PreviousSessionMetrics(maxWeight: maxWeight, maxReps: maxReps, volume: volume)
    }

    /// Format rest time: "45s" if under 1 min, "1m 30s" if over
    private func formatRestTime(_ seconds: Int?) -> String {
        guard let seconds = seconds else { return "—" }
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let mins = seconds / 60
            let secs = seconds % 60
            if secs == 0 {
                return "\(mins)m"
            } else {
                return "\(mins)m \(secs)s"
            }
        }
    }

    /// Max weight metric cell with delta underneath
    @ViewBuilder
    private func maxMetricCellWithDelta(
        weight: Double,
        reps: Int,
        weightDelta: Double?,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Label row with PB
            HStack {
                Text("Max Weight")
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
                if hasPB {
                    Spacer()
                    Text("PB")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.red)
                }
            }

            // Value: "70.5 kg × 12"
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(Formatters.formatWeight(weight))
                    .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                Text(" kg")
                    .font(themeManager.currentTheme.interFont(size: 14))
                    .foregroundStyle(.secondary)
                Text(" × ")
                    .font(themeManager.currentTheme.interFont(size: 14))
                    .foregroundStyle(.secondary)
                Text("\(reps)")
                    .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.currentTheme.primaryText)
            }

            // Delta row (combined weight and reps deltas)
            let hasWeightDelta = weightDelta != nil && weightDelta != 0
            let hasRepsDelta = repsDelta != nil && repsDelta != 0
            if hasWeightDelta || hasRepsDelta {
                HStack(spacing: 8) {
                    if let wDelta = weightDelta, wDelta != 0 {
                        Text(formatWeightDelta(wDelta))
                            .font(themeManager.currentTheme.dataFont(size: 12))
                            .monospacedDigit()
                            .foregroundStyle(deltaColor(wDelta))
                    }
                    if let rDelta = repsDelta, rDelta != 0 {
                        Text(formatRepsDelta(rDelta) + " reps")
                            .font(themeManager.currentTheme.dataFont(size: 12))
                            .monospacedDigit()
                            .foregroundStyle(deltaColor(Double(rDelta)))
                    }
                }
            } else {
                // Reserve space for delta row
                Text(" ")
                    .font(themeManager.currentTheme.dataFont(size: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            ZStack {
                themeManager.currentTheme.cardBackgroundColor
                if hasPB {
                    Color.red.opacity(0.1)
                }
            }
        }
    }

    /// Reps-only metric cell with delta underneath
    @ViewBuilder
    private func repsOnlyMetricCellWithDelta(
        reps: Int,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Max Reps")
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
                if hasPB {
                    Spacer()
                    Text("PB")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.red)
                }
            }
            Text("\(reps)")
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let rDelta = repsDelta, rDelta != 0 {
                Text(formatRepsDelta(rDelta))
                    .font(themeManager.currentTheme.dataFont(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(deltaColor(Double(rDelta)))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                // Reserve space for delta row
                Text(" ")
                    .font(themeManager.currentTheme.dataFont(size: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            ZStack {
                themeManager.currentTheme.cardBackgroundColor
                if hasPB {
                    Color.red.opacity(0.1)
                }
            }
        }
    }

    /// Volume metric cell with delta underneath
    @ViewBuilder
    private func volumeMetricCellWithDelta(
        volume: Double,
        volumeDelta: Double?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Volume")
                .font(themeManager.currentTheme.captionFont)
                .foregroundStyle(themeManager.currentTheme.mutedForeground)
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(Formatters.formatVolume(volume))
                    .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.currentTheme.primaryText)
                Text(" kg")
                    .font(themeManager.currentTheme.interFont(size: 14))
                    .foregroundStyle(.secondary)
            }

            if let vDelta = volumeDelta, vDelta != 0 {
                Text(formatVolumeDelta(vDelta))
                    .font(themeManager.currentTheme.dataFont(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(deltaColor(vDelta))
            } else {
                // Reserve space for delta row
                Text(" ")
                    .font(themeManager.currentTheme.dataFont(size: 12))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
    }

    // MARK: - Delta Formatting Helpers

    private func formatWeightDelta(_ delta: Double) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(Formatters.formatWeight(delta))"
    }

    private func formatRepsDelta(_ delta: Int) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(delta)"
    }

    private func formatVolumeDelta(_ delta: Double) -> String {
        if delta == 0 { return "" }
        let sign = delta > 0 ? "+" : ""
        return "\(sign)\(Formatters.formatVolume(delta))"
    }

    private func deltaColor(_ value: Double) -> Color {
        if value > 0 { return .green }
        if value < 0 { return .red }
        return .secondary
    }
}
