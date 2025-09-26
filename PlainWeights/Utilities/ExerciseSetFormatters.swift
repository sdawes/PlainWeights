//
//  ExerciseSetFormatters.swift
//  PlainWeights
//
//  Formatters for displaying exercise sets with smart zero handling
//

import Foundation

enum ExerciseSetFormatters {

    // MARK: - Set Display Formatting

    /// Format a single exercise set, hiding zeros appropriately
    static func formatSet(_ set: ExerciseSet) -> String {
        if set.weight == 0 && set.reps > 0 {
            // Bodyweight exercises: "10 reps"
            return "\(set.reps) reps"
        } else if set.weight > 0 && set.reps == 0 {
            // Weight-only exercises: "50 kg"
            return "\(Formatters.formatWeight(set.weight)) kg"
        } else if set.weight > 0 && set.reps > 0 {
            // Standard exercises: "50 kg × 10 reps"
            return "\(Formatters.formatWeight(set.weight)) kg × \(set.reps)"
        } else {
            // Fallback for invalid data
            return "Invalid set"
        }
    }

    /// Format last max weight display - always shows weight in kg
    /// The "Last max weight" field should always display kg, never reps
    static func formatLastMaxWeight(weight: Double, reps: Int) -> String {
        // Always show weight in kg format, regardless of exercise type
        return "\(Formatters.formatWeight(weight)) kg"
    }

    /// Format the max weight details line
    static func formatMaxWeightDetails(weight: Double, reps: Int, sets: Int) -> String {
        // Always show "reps" for consistency
        return "\(reps) reps • \(sets) sets"
    }

    /// Format session total - always in kg for consistency
    static func formatSessionTotal(volume: Double, exerciseType: ExerciseMetricsType) -> String {
        return "\(Formatters.formatVolume(volume)) kg"
    }

    /// Format progress display value - always in kg for consistency
    static func formatProgressValue(volume: Double, exerciseType: ExerciseMetricsType) -> String {
        return "\(Formatters.formatVolume(volume)) kg"
    }

    // MARK: - Historic Set Display

    /// Format historic set for list display with warm-up indicator
    static func formatHistoricSet(_ set: ExerciseSet) -> String {
        let baseFormat = formatSet(set)
        return set.isWarmUp ? "\(baseFormat) (warm-up)" : baseFormat
    }

    // MARK: - Exercise Summary Helpers

    /// Determine if an exercise should be displayed as reps-only based on recent usage
    static func isRepsOnlyExercise(from sets: [ExerciseSet]) -> Bool {
        // Look at recent sets to determine current exercise type
        let recentSets = sets.prefix(10) // Last 10 sets
        return recentSets.allSatisfy { $0.weight == 0 }
    }

    /// Determine if an exercise should be displayed as weight-only based on recent usage
    static func isWeightOnlyExercise(from sets: [ExerciseSet]) -> Bool {
        let recentSets = sets.prefix(10) // Last 10 sets
        return recentSets.allSatisfy { $0.reps == 0 }
    }
}