//
//  ExerciseSetFormatters.swift
//  PlainWeights
//
//  Formatters for displaying exercise sets with smart zero handling
//

import Foundation

enum ExerciseSetFormatters {

    // MARK: - Set Display Formatting

    /// Format a single exercise set - always shows "XX kg/lbs x YY reps" format
    static func formatSet(_ set: ExerciseSet, unit: WeightUnit) -> String {
        // Always show full format: "XX kg/lbs x YY reps" (even when 0)
        let displayWeight = unit.fromKg(set.weight)
        return "\(Formatters.formatWeight(displayWeight)) \(unit.displayName) × \(set.reps) reps"
    }

    /// Format last max weight display - always shows weight in current unit
    /// The "Last max weight" field should always display weight, never reps
    static func formatLastMaxWeight(weight: Double, reps: Int, unit: WeightUnit) -> String {
        // Always show weight in current unit format, regardless of exercise type
        let displayWeight = unit.fromKg(weight)
        return "\(Formatters.formatWeight(displayWeight)) \(unit.displayName)"
    }

    /// Format the max weight details line
    static func formatMaxWeightDetails(weight: Double, reps: Int, sets: Int) -> String {
        // Always show "reps" for consistency
        return "\(reps) reps • \(sets) sets"
    }

    /// Format session total - in current unit for consistency
    static func formatSessionTotal(volume: Double, exerciseType: ExerciseMetricsType, unit: WeightUnit) -> String {
        let displayVolume = unit.fromKg(volume)
        return "\(Formatters.formatVolume(displayVolume)) \(unit.displayName)"
    }

    /// Format progress display value - in current unit for consistency
    static func formatProgressValue(volume: Double, exerciseType: ExerciseMetricsType, unit: WeightUnit) -> String {
        let displayVolume = unit.fromKg(volume)
        return "\(Formatters.formatVolume(displayVolume)) \(unit.displayName)"
    }

    // MARK: - Historic Set Display

    /// Format historic set for list display with warm-up indicator
    static func formatHistoricSet(_ set: ExerciseSet, unit: WeightUnit) -> String {
        let baseFormat = formatSet(set, unit: unit)
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