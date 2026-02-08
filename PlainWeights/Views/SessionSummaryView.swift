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

    // Cached previous session metrics to avoid O(n*m) recomputation per exercise
    @State private var cachedPreviousMetrics: [PersistentIdentifier: PreviousSessionMetrics] = [:]

    // Cached display day - prevents expensive recomputation on every render
    @State private var cachedDisplayDay: ExerciseDataGrouper.WorkoutDay?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

            if let day = cachedDisplayDay {
                List {
                    // Session info card
                    Section {
                        sessionInfoCard(for: day)
                    }
                    .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 0, trailing: 16))
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
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
                        .font(themeManager.effectiveTheme.title2Font)

                    Text("Complete your first workout to see a summary here.")
                        .font(themeManager.effectiveTheme.subheadlineFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                }
                Spacer()
            }
        }
        .background(AnimatedGradientBackground())
        .onAppear {
            updateCaches()
        }
        .onChange(of: allSets) { _, _ in
            updateCaches()
        }
    }

    // MARK: - Cache Management

    /// Update all cached values - called on appear and when allSets changes
    private func updateCaches() {
        // Compute display day first (expensive operation - only do once)
        let day = Self.computeDisplayDay(from: allSets)
        cachedDisplayDay = day

        // Then compute previous metrics using the cached day
        guard let day else {
            cachedPreviousMetrics = [:]
            return
        }
        cachedPreviousMetrics = Self.computeAllPreviousSessionMetrics(
            for: day.exercises,
            from: allSets,
            before: day.date
        )
    }

    // MARK: - Static Computation Functions

    /// Compute display day from sets - expensive operation, should only be called when data changes
    private static func computeDisplayDay(from allSets: [ExerciseSet]) -> ExerciseDataGrouper.WorkoutDay? {
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
                .font(themeManager.effectiveTheme.title3Font)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
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
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(formatDuration(sessionDuration))
                    .font(themeManager.effectiveTheme.dataFont(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 1: Exercises, Sets, Volume
            HStack(spacing: 0) {
                metricCell(label: "Exercises", value: "\(day.exerciseCount)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Sets", value: "\(day.totalSets)")
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(day.totalVolume)) kg")
            }

            // Divider between rows
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Duration, Avg Rest, PBs
            HStack(spacing: 0) {
                metricCell(
                    label: "Duration",
                    value: formatDuration(sessionDuration)
                )
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                metricCell(
                    label: "Avg Rest",
                    value: sessionAvgRest.map { formatRestTime($0) } ?? "—"
                )
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)
                pbMetricCell(pbCount: pbCount)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func metricCell(label: String, value: String) -> some View {
        HStack(spacing: 0) {
            // Left spacer (matches delta cells: 8pt spacer + 3pt bar space)
            Color.clear.frame(width: 11)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(themeManager.effectiveTheme.captionFont)
                    .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                Text(value)
                    .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    @ViewBuilder
    private func pbMetricCell(pbCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PBs")
                .font(themeManager.effectiveTheme.captionFont)
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            // Value: "3 × ⭐"
            HStack(alignment: .center, spacing: 0) {
                Text("\(pbCount)")
                    .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(" × ")
                    .font(themeManager.effectiveTheme.interFont(size: 14))
                    .foregroundStyle(.secondary)
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(themeManager.effectiveTheme.pbColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    private var exercisesHeader: some View {
        HStack(spacing: 6) {
            Text("Exercises")
                .font(themeManager.effectiveTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
            InfoButton(text: "Delta values show the difference compared to your last session for each exercise.")
        }
        .padding(.top, 20)
        .padding(.bottom, 4)
        .padding(.leading, 8)
    }

    @ViewBuilder
    private func exerciseCard(for workoutExercise: ExerciseDataGrouper.WorkoutExercise, displayedDay: Date) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let workingSets = workoutExercise.sets.workingSets
        let maxSet = workingSets.max(by: { $0.weight < $1.weight })
        let exerciseDuration = SessionStatsCalculator.getExerciseDurationMinutes(from: workoutExercise.sets)
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

        // Current session values
        let currentMaxWeight = maxSet?.weight ?? 0
        // For weighted exercises: reps from the heaviest set
        // For reps-only exercises: actual max reps across all sets
        let currentMaxReps = currentMaxWeight > 0
            ? (maxSet?.reps ?? 0)
            : (workingSets.map { $0.reps }.max() ?? 0)
        let currentVolume = workoutExercise.volume

        // Get previous session data for comparison (O(1) lookup from pre-computed cache)
        let previousSession = cachedPreviousMetrics[workoutExercise.exercise.persistentModelID]

        // Calculate deltas
        let weightDelta: Double? = previousSession.map { currentMaxWeight - $0.maxWeight }
        let repsDelta: Int? = previousSession.map { currentMaxReps - $0.maxReps }
        let volumeDelta: Double? = previousSession.map { currentVolume - $0.volume }

        VStack(alignment: .leading, spacing: 0) {
            // Header with exercise name and duration
            HStack(spacing: 8) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Text(workoutExercise.exercise.name)
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)
                Spacer()
                Text(formatDuration(exerciseDuration))
                    .font(themeManager.effectiveTheme.dataFont(size: 14))
                    .monospacedDigit()
                    .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider below header
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 1: Sets, Max
            HStack(spacing: 0) {
                metricCell(label: "Sets", value: "\(workoutExercise.setCount)")

                // Vertical divider
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
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
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, Avg Rest
            HStack(spacing: 0) {
                volumeMetricCellWithDelta(
                    volume: currentVolume,
                    volumeDelta: volumeDelta
                )

                // Vertical divider
                Rectangle()
                    .fill(themeManager.effectiveTheme.borderColor)
                    .frame(width: 1)

                metricCell(label: "Avg Rest", value: formatRestTime(exerciseAvgRest))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }

    // MARK: - Previous Session Comparison

    private struct PreviousSessionMetrics {
        let maxWeight: Double
        let maxReps: Int
        let volume: Double
    }

    /// Compute all previous session metrics in a single pass - O(n) instead of O(n*e)
    private static func computeAllPreviousSessionMetrics(
        for exercises: [ExerciseDataGrouper.WorkoutExercise],
        from allSets: [ExerciseSet],
        before displayedDay: Date
    ) -> [PersistentIdentifier: PreviousSessionMetrics] {
        let calendar = Calendar.current
        let displayedDayStart = calendar.startOfDay(for: displayedDay)

        // Get exercise IDs we care about
        let exerciseIDs = Set(exercises.map { $0.exercise.persistentModelID })

        // Single pass: filter and group by exercise ID
        var setsByExercise: [PersistentIdentifier: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseID = set.exercise?.persistentModelID,
                  exerciseIDs.contains(exerciseID),
                  calendar.startOfDay(for: set.timestamp) < displayedDayStart,
                  !set.isWarmUp && !set.isBonus else {
                continue
            }
            setsByExercise[exerciseID, default: []].append(set)
        }

        // For each exercise, find most recent day and compute metrics
        var result: [PersistentIdentifier: PreviousSessionMetrics] = [:]
        for (exerciseID, exerciseSets) in setsByExercise {
            // Group by day
            let grouped = Dictionary(grouping: exerciseSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }

            guard let mostRecentDay = grouped.keys.max(),
                  let previousDaySets = grouped[mostRecentDay] else {
                continue
            }

            // Calculate metrics
            let maxSet = previousDaySets.max(by: { $0.weight < $1.weight })
            let maxWeight = maxSet?.weight ?? 0
            // For weighted exercises: reps from the heaviest set
            // For reps-only exercises: actual max reps across all sets
            let maxReps = maxWeight > 0
                ? (maxSet?.reps ?? 0)
                : (previousDaySets.map { $0.reps }.max() ?? 0)
            let volume = previousDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

            result[exerciseID] = PreviousSessionMetrics(maxWeight: maxWeight, maxReps: maxReps, volume: volume)
        }

        return result
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

    /// Format session/exercise duration: "45 min" if under 1 hr, "1 hr 2 min" if over
    private func formatDuration(_ minutes: Int?) -> String {
        guard let minutes = minutes else { return "—" }
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hrs = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hrs) hr"
            } else {
                return "\(hrs) hr \(mins) min"
            }
        }
    }

    /// Max weight metric cell with inline deltas and accent bar
    @ViewBuilder
    private func maxMetricCellWithDelta(
        weight: Double,
        reps: Int,
        weightDelta: Double?,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: weightDelta, repsDelta: repsDelta)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Label row with PB
                    HStack {
                        Text("Max Weight")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        if hasPB {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
                    }

                    // Value with inline deltas: "45 kg -5.5 × 10 +2"
                    (
                        Text(Formatters.formatWeight(weight))
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(" kg")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text(weightDelta.flatMap { $0 != 0 ? " \(formatWeightDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(weightDelta ?? 0))
                        + Text(" × ")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text("\(reps)")
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    /// Reps-only metric cell with inline delta and accent bar
    @ViewBuilder
    private func repsOnlyMetricCellWithDelta(
        reps: Int,
        repsDelta: Int?,
        hasPB: Bool
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: nil, repsDelta: repsDelta)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Max Reps")
                            .font(themeManager.effectiveTheme.captionFont)
                            .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                        if hasPB {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(themeManager.effectiveTheme.pbColor)
                        }
                    }
                    // Value with inline delta: "12 +2"
                    (
                        Text("\(reps)")
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(repsDelta.flatMap { $0 != 0 ? " \(formatRepsDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(Double(repsDelta ?? 0)))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
    }

    /// Volume metric cell with inline delta and accent bar
    @ViewBuilder
    private func volumeMetricCellWithDelta(
        volume: Double,
        volumeDelta: Double?
    ) -> some View {
        let accentColor = deltaAccentColor(weightDelta: volumeDelta, repsDelta: nil)

        HStack(spacing: 0) {
            // Left spacer (always present for consistent alignment)
            Color.clear.frame(width: 8)

            // Accent bar + shaded content area
            HStack(spacing: 0) {
                if let color = accentColor {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                } else {
                    // Reserve space for accent bar even when not present
                    Color.clear.frame(width: 3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Volume")
                        .font(themeManager.effectiveTheme.captionFont)
                        .foregroundStyle(themeManager.effectiveTheme.mutedForeground)
                    // Value with inline delta: "1,250 kg +150"
                    (
                        Text(Formatters.formatVolume(volume))
                            .font(themeManager.effectiveTheme.dataFont(size: 20, weight: .semibold))
                            .foregroundStyle(themeManager.effectiveTheme.primaryText)
                        + Text(" kg")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(.secondary)
                        + Text(volumeDelta.flatMap { $0 != 0 ? " \(formatVolumeDelta($0))" : nil } ?? "")
                            .font(themeManager.effectiveTheme.dataFont(size: 14))
                            .foregroundStyle(deltaColor(volumeDelta ?? 0))
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                if let color = accentColor {
                    color.opacity(0.08)
                } else {
                    themeManager.effectiveTheme.cardBackgroundColor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
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

    /// Determine accent bar color based on deltas
    /// Green if any positive, red if any negative (green takes priority if both)
    private func deltaAccentColor(weightDelta: Double?, repsDelta: Int?) -> Color? {
        let hasPositive = (weightDelta ?? 0) > 0 || (repsDelta ?? 0) > 0
        let hasNegative = (weightDelta ?? 0) < 0 || (repsDelta ?? 0) < 0

        if hasPositive { return .green }
        if hasNegative { return .red }
        return nil
    }
}
