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
                            exerciseCard(for: exercise)
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
            .background(themeManager.currentTheme.muted.opacity(0.3))

            // Divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 1: Exercises, Sets, Volume
            HStack(spacing: 1) {
                metricCell(label: "Exercises", value: "\(day.exerciseCount)")
                metricCell(label: "Sets", value: "\(day.totalSets)")
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(day.totalVolume)) kg")
            }
            .background(themeManager.currentTheme.borderColor)

            // Divider between rows
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 2: Duration, Avg Rest, PBs
            HStack(spacing: 1) {
                metricCell(
                    label: "Duration",
                    value: sessionDuration.map { "\($0) min" } ?? "—"
                )
                metricCell(
                    label: "Avg Rest",
                    value: sessionAvgRest.map { "\($0)s" } ?? "—"
                )
                pbMetricCell(pbCount: pbCount)
            }
            .background(themeManager.currentTheme.borderColor)
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
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .foregroundStyle(themeManager.currentTheme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    private func exerciseCard(for workoutExercise: ExerciseDataGrouper.WorkoutExercise) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let maxSet = workoutExercise.sets.filter { !$0.isWarmUp && !$0.isBonus }.max(by: { $0.weight < $1.weight })
        let exerciseDuration = SessionStatsCalculator.getExerciseDurationMinutes(from: workoutExercise.sets)
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

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
                        .foregroundStyle(themeManager.currentTheme.tertiaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(themeManager.currentTheme.muted.opacity(0.3))

            // Divider
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 1: Sets, Max
            HStack(spacing: 1) {
                metricCell(label: "Sets", value: "\(workoutExercise.setCount)")
                if let maxSet = maxSet, maxSet.weight > 0 {
                    pbHighlightedMetricCell(
                        label: "Max",
                        value: "\(Formatters.formatWeight(maxSet.weight)) × \(maxSet.reps)",
                        hasPB: hasPB
                    )
                } else {
                    pbHighlightedMetricCell(
                        label: "Max Reps",
                        value: "\(maxSet?.reps ?? workoutExercise.sets.map { $0.reps }.max() ?? 0)",
                        hasPB: hasPB
                    )
                }
            }
            .background(themeManager.currentTheme.borderColor)

            // Divider between rows
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)

            // Row 2: Volume, Avg Rest
            HStack(spacing: 1) {
                metricCell(label: "Volume", value: "\(Formatters.formatVolume(workoutExercise.volume)) kg")
                metricCell(label: "Avg Rest", value: formatRestTime(exerciseAvgRest))
            }
            .background(themeManager.currentTheme.borderColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
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

    /// Metric cell with optional PB highlight (red tinted background with PB label)
    @ViewBuilder
    private func pbHighlightedMetricCell(label: String, value: String, hasPB: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(themeManager.currentTheme.captionFont)
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)
                if hasPB {
                    Spacer()
                    Text("PB")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.red)
                }
            }
            Text(value)
                .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                .foregroundStyle(themeManager.currentTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                themeManager.currentTheme.cardBackgroundColor
                if hasPB {
                    Color.red.opacity(0.1)
                }
            }
        }
    }
}
