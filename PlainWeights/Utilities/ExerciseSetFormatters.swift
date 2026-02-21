//
//  ExerciseSetFormatters.swift
//  PlainWeights
//
//  Formatters for displaying exercise sets with smart zero handling
//

import Foundation

enum ExerciseSetFormatters {

    /// Format a single exercise set - always shows "XX kg/lbs x YY reps" format
    static func formatSet(_ set: ExerciseSet, unit: WeightUnit) -> String {
        let displayWeight = unit.fromKg(set.weight)
        return "\(Formatters.formatWeight(displayWeight)) \(unit.displayName) × \(set.reps) reps"
    }
}
