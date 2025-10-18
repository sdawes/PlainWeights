//
//  ExerciseDetailViewV2.swift
//  PlainWeights
//
//  Created for testing new design approach
//

import SwiftUI
import SwiftData

// MARK: - MetricCard Component

struct MetricCard: View {
    let label: String
    let value: String
    let unit: String
    let changeAmount: String?
    let changeDirection: ProgressTracker.PRDirection?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(label.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)

            // Main value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(unit)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            // Change indicator
            if let changeAmount = changeAmount, let direction = changeDirection {
                HStack(spacing: 4) {
                    Image(systemName: direction.iconName)
                        .font(.caption2)
                        .foregroundStyle(direction.color)
                    Text(changeAmount)
                        .font(.caption)
                        .foregroundStyle(direction.color)
                }
            } else {
                // Placeholder for alignment when no change
                Text("—")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - ExerciseDetailViewV2

struct ExerciseDetailViewV2: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    @Query private var sets: [ExerciseSet]

    // Cached progress state
    private var progressState: ProgressTracker.ProgressState? {
        ProgressTracker.createProgressState(from: sets)
    }

    init(exercise: Exercise) {
        self.exercise = exercise
        let id = exercise.persistentModelID
        _sets = Query(
            filter: #Predicate<ExerciseSet> { $0.exercise?.persistentModelID == id },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Three metric cards
                HStack(spacing: 12) {
                    // Card 1: Weight
                    MetricCard(
                        label: "Weight",
                        value: formatWeight(),
                        unit: "kg",
                        changeAmount: formatWeightChange(),
                        changeDirection: progressState?.personalRecords?.weightDirection
                    )

                    // Card 2: Reps
                    MetricCard(
                        label: "Reps",
                        value: formatReps(),
                        unit: "",
                        changeAmount: formatRepsChange(),
                        changeDirection: progressState?.personalRecords?.repsDirection
                    )

                    // Card 3: Volume
                    MetricCard(
                        label: "Volume",
                        value: formatVolume(),
                        unit: "kg",
                        changeAmount: nil,
                        changeDirection: nil
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Formatting Helpers

    private func formatWeight() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatWeight(lastInfo.maxWeight)
    }

    private func formatReps() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return "\(lastInfo.maxWeightReps)"
    }

    private func formatVolume() -> String {
        guard let lastInfo = progressState?.lastCompletedDayInfo else {
            return "0"
        }
        return Formatters.formatVolume(lastInfo.volume)
    }

    private func formatWeightChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        return "\(Formatters.formatWeight(abs(pr.weightImprovement))) kg"
    }

    private func formatRepsChange() -> String? {
        guard let pr = progressState?.personalRecords else {
            return nil
        }
        return "\(abs(pr.repsImprovement))"
    }
}
