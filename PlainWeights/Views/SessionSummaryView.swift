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

                        ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, exercise in
                            exerciseRow(for: exercise, index: index, total: day.exercises.count)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
            // Header with date
            Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                .foregroundStyle(themeManager.currentTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
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
            if pbCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                    Text("\(pbCount)")
                        .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                        .foregroundStyle(themeManager.currentTheme.primaryText)
                }
            } else {
                Text("—")
                    .font(themeManager.currentTheme.dataFont(size: 20, weight: .semibold))
                    .foregroundStyle(themeManager.currentTheme.primaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardBackgroundColor)
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
    private func exerciseRow(for workoutExercise: ExerciseDataGrouper.WorkoutExercise, index: Int, total: Int) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }
        let maxSet = workoutExercise.sets.filter { !$0.isWarmUp && !$0.isBonus }.max(by: { $0.weight < $1.weight })
        let exerciseDuration = SessionStatsCalculator.getExerciseDurationMinutes(from: workoutExercise.sets)
        let exerciseAvgRest = SessionStatsCalculator.getAverageRestSeconds(from: workoutExercise.sets)

        VStack(spacing: 0) {
            // Divider at top (not for first row)
            if index > 0 {
                Rectangle()
                    .fill(themeManager.currentTheme.borderColor)
                    .frame(height: 1)
            }

            // Content
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Exercise name
                    Text(workoutExercise.exercise.name)
                        .font(themeManager.currentTheme.interFont(size: 17, weight: .semibold))

                    // Stats line: sets, volume, max
                    HStack(spacing: 4) {
                        Text("\(workoutExercise.setCount)")
                            .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                        Text("sets")
                            .font(themeManager.currentTheme.interFont(size: 14))

                        Text("•")
                            .foregroundStyle(themeManager.currentTheme.tertiaryText)

                        Text(Formatters.formatVolume(workoutExercise.volume))
                            .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                        Text("kg")
                            .font(themeManager.currentTheme.interFont(size: 14))

                        if let maxSet = maxSet, maxSet.weight > 0 {
                            Text("•")
                                .foregroundStyle(themeManager.currentTheme.tertiaryText)

                            Text("Max:")
                                .font(themeManager.currentTheme.interFont(size: 14))
                            Text("\(Formatters.formatWeight(maxSet.weight))")
                                .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                            Text("×")
                                .font(themeManager.currentTheme.interFont(size: 14))
                            Text("\(maxSet.reps)")
                                .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(themeManager.currentTheme.mutedForeground)

                    // Duration and rest time line
                    if exerciseDuration != nil || exerciseAvgRest != nil {
                        HStack(spacing: 4) {
                            if let duration = exerciseDuration {
                                Text("\(duration)")
                                    .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                                Text("min")
                                    .font(themeManager.currentTheme.interFont(size: 14))
                            }

                            if exerciseDuration != nil && exerciseAvgRest != nil {
                                Text("•")
                                    .foregroundStyle(themeManager.currentTheme.tertiaryText)
                            }

                            if let avgRest = exerciseAvgRest {
                                Text("~\(avgRest)")
                                    .font(themeManager.currentTheme.dataFont(size: 14, weight: .semibold))
                                Text("s rest")
                                    .font(themeManager.currentTheme.interFont(size: 14))
                            }
                        }
                        .foregroundStyle(themeManager.currentTheme.mutedForeground)
                    }
                }

                Spacer()

                // PB indicator (badge-style matching warmup/bonus)
                if hasPB {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                        Text("PB")
                            .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if hasPB {
                    pbTintBackground
                }
            }
        }
        .background(
            RoundedCorner(radius: 12, corners: cornersForRow(index: index, total: total))
                .fill(themeManager.currentTheme.cardBackgroundColor)
        )
        .overlay(borderOverlay(index: index, total: total))
    }

    /// Red tint background for exercise rows with PBs (matching SetRowView warmup/bonus pattern)
    private var pbTintBackground: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 2)
            Rectangle()
                .fill(Color.red.opacity(0.1))
        }
        .padding(.leading, 12)
    }

    // MARK: - Helper Functions

    private func cornersForRow(index: Int, total: Int) -> UIRectCorner {
        if total == 1 { return .allCorners }
        if index == 0 { return [.topLeft, .topRight] }
        if index == total - 1 { return [.bottomLeft, .bottomRight] }
        return []
    }

    @ViewBuilder
    private func borderOverlay(index: Int, total: Int) -> some View {
        if total == 1 {
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        } else if index == 0 {
            TopOpenBorder(radius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        } else if index == total - 1 {
            BottomOpenBorder(radius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        } else {
            SidesOnlyBorder()
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        }
    }
}
