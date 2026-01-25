//
//  SessionSummaryView.swift
//  PlainWeights
//
//  Created by Claude on 09/12/2025.
//

import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @Query private var allSets: [ExerciseSet]

    var body: some View {
        NavigationStack {
            Group {
                if let day = displayDay {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header section
                            headerSection(for: day)

                            // Stats bar
                            statsBar(for: day)

                            // Exercise list
                            exerciseList(for: day)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 12) {
                        RetroLifterView(pixelSize: 5)

                        Text("No Workouts Yet")
                            .font(.title2)

                        Text("Complete your first workout to see a summary here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Session Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(AnimatedGradientBackground())
        }
    }

    // MARK: - Computed Properties

    private var displayDay: ExerciseDataGrouper.WorkoutDay? {
        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: allSets)
        let todaySets = TodaySessionCalculator.getTodaysSets(from: allSets)

        if todaySets.isEmpty {
            // No sets today - show last session
            return workoutDays.first
        } else {
            // Show today
            return workoutDays.first { Calendar.current.isDateInToday($0.date) }
        }
    }

    private var isShowingToday: Bool {
        guard let day = displayDay else { return false }
        return Calendar.current.isDateInToday(day.date)
    }

    // MARK: - View Components

    @ViewBuilder
    private func headerSection(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        VStack(spacing: 4) {
            Text(isShowingToday ? "Today's Session" : "Last Session")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(day.date, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.title2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func statsBar(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        let pbCount = day.exercises.flatMap { $0.sets }.filter { $0.isPB }.count

        HStack(spacing: 0) {
            statItem(value: "\(day.exerciseCount)", label: "exercises")

            Divider()
                .frame(height: 30)

            statItem(value: "\(day.totalSets)", label: "sets")

            Divider()
                .frame(height: 30)

            statItem(value: Formatters.formatVolume(day.totalVolume), label: "kg")

            if pbCount > 0 {
                Divider()
                    .frame(height: 30)

                // PB stat with trophy
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(pbCount)")
                            .font(.title3)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(themeManager.currentTheme.primaryText)
                    }
                    Text(pbCount == 1 ? "PB" : "PBs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(themeManager.currentTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func exerciseList(for day: ExerciseDataGrouper.WorkoutDay) -> some View {
        VStack(spacing: 12) {
            ForEach(day.exercises) { exercise in
                exerciseCard(for: exercise)
            }
        }
    }

    @ViewBuilder
    private func exerciseCard(for workoutExercise: ExerciseDataGrouper.WorkoutExercise) -> some View {
        let hasPB = workoutExercise.sets.contains { $0.isPB }

        VStack(alignment: .leading, spacing: 8) {
            // Exercise name with PB badge
            HStack {
                Text(workoutExercise.exercise.name)
                    .font(.headline)

                Spacer()

                if hasPB {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(themeManager.currentTheme.primaryText)
                }
            }

            // Tags (if any)
            if !workoutExercise.exercise.tags.isEmpty {
                TagPillsRow(tags: workoutExercise.exercise.tags)
            }

            // Sets and volume
            HStack {
                Text("\(workoutExercise.setCount) sets")
                    .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.tertiary)

                Text("\(Formatters.formatVolume(workoutExercise.volume)) kg")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            // Max weight × reps
            if let maxSet = workoutExercise.sets.filter({ !$0.isWarmUp && !$0.isBonus }).max(by: { $0.weight < $1.weight }) {
                HStack {
                    Text("Max:")
                        .foregroundStyle(.tertiary)
                    Text("\(Formatters.formatWeight(maxSet.weight)) kg × \(maxSet.reps)")
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
