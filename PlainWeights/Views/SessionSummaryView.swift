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
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Complete your first workout to see a summary here.")
                    )
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
                .fontWeight(.bold)
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

                // PB stat with purple styling
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(pbCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Circle()
                            .fill(.purple)
                            .frame(width: 18, height: 18)
                            .overlay {
                                Text("PB")
                                    .font(.system(size: 8))
                                    .italic()
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                    }
                    Text(pbCount == 1 ? "PB" : "PBs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
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
                    Circle()
                        .fill(.purple)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("PB")
                                .font(.system(size: 10))
                                .italic()
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                }
            }

            // Category, sets, volume
            HStack {
                Text(workoutExercise.exercise.category)
                    .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.tertiary)

                Text("\(workoutExercise.setCount) sets")
                    .foregroundStyle(.secondary)

                Text("•")
                    .foregroundStyle(.tertiary)

                Text("\(Formatters.formatVolume(workoutExercise.volume)) kg")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            // Max weight × reps
            if let maxSet = workoutExercise.sets.filter({ !$0.isWarmUp }).max(by: { $0.weight < $1.weight }) {
                HStack {
                    Text("Max:")
                        .foregroundStyle(.tertiary)
                    Text("\(Formatters.formatWeight(maxSet.weight)) kg × \(maxSet.reps)")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
