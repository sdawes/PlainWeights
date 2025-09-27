//
//  ExerciseVolumeCalculator.swift
//  PlainWeights
//
//  Service for handling different exercise volume calculation strategies
//  Supports weight-based, reps-based, and mixed exercise types
//

import Foundation
import os.log

enum ExerciseMetricsType {
    case weightBased  // Has weight > 0 (standard or weight-only exercises)
    case repsOnly     // All weights are 0 (bodyweight exercises)

    /// Determine the metrics type for a set of exercise sets
    static func determine(from sets: [ExerciseSet]) -> ExerciseMetricsType {
        // Single pass to check for any weight > 0
        for set in sets {
            if set.weight > 0 {
                return .weightBased
            }
        }
        return .repsOnly
    }
}

struct SessionMetrics {
    let type: ExerciseMetricsType
    let value: Double
    let maxWeight: Double
    let maxWeightReps: Int
    let totalSets: Int
    let date: Date
}

enum ExerciseVolumeCalculator {

    // Performance monitoring
    private static let logger = Logger(subsystem: "com.plainweights.app", category: "performance")

    // MARK: - Volume Calculations

    /// Calculate total volume for a set of exercise sets based on their type
    /// Optimized single-pass algorithm
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        var volume = 0.0

        // Single pass to calculate volume
        for set in sets {
            guard !set.isWarmUp else { continue }

            // Calculate volume based on set values
            if set.weight > 0 && set.reps > 0 {
                // Standard exercise: weight × reps
                volume += set.weight * Double(set.reps)
            } else if set.weight > 0 && set.reps == 0 {
                // Weight-only exercise: just weight
                volume += set.weight
            } else if set.weight == 0 && set.reps > 0 {
                // Reps-only exercise: just reps
                volume += Double(set.reps)
            }
        }

        return volume
    }

    /// Calculate weight-only volume for display purposes (excludes reps-only exercises)
    /// Used for "Lifted today" display to show 0 kg for bodyweight exercises
    static func calculateWeightVolume(for sets: [ExerciseSet]) -> Double {
        var volume = 0.0

        // Single pass to calculate only weight-based volume
        for set in sets {
            guard !set.isWarmUp else { continue }

            // Only count exercises that involve actual weight
            if set.weight > 0 {
                if set.reps > 0 {
                    // Standard exercise: weight × reps
                    volume += set.weight * Double(set.reps)
                } else {
                    // Weight-only exercise: just weight
                    volume += set.weight
                }
            }
            // Skip reps-only exercises (weight = 0) for display consistency
        }

        return volume
    }

    // MARK: - Session Analysis

    /// Get session metrics for a specific set of sets (today or last session)
    /// Optimized single-pass algorithm to avoid multiple array iterations
    static func getSessionMetrics(for sets: [ExerciseSet], date: Date) -> SessionMetrics {
        let startTime = CFAbsoluteTimeGetCurrent()
        var hasWeight = false
        var volume = 0.0
        var maxWeight = 0.0
        var maxWeightReps = 0
        var totalSets = 0

        // Single pass through sets to calculate all metrics
        for set in sets {
            guard !set.isWarmUp else { continue }

            totalSets += 1

            // Track if this session has any weights
            if set.weight > 0 {
                hasWeight = true
            }

            // Update max weight and reps
            if set.weight > maxWeight {
                maxWeight = set.weight
                maxWeightReps = set.reps
            } else if set.weight == maxWeight && set.reps > maxWeightReps {
                maxWeightReps = set.reps
            }

            // Calculate volume based on set type
            if set.weight > 0 && set.reps > 0 {
                // Standard exercise: weight × reps
                volume += set.weight * Double(set.reps)
            } else if set.weight > 0 && set.reps == 0 {
                // Weight-only exercise: just weight
                volume += set.weight
            } else if set.weight == 0 && set.reps > 0 {
                // Reps-only exercise: just reps
                volume += Double(set.reps)
            }
        }

        let metricsType: ExerciseMetricsType = hasWeight ? .weightBased : .repsOnly

        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        if timeElapsed > 0.016 { // More than one frame (60fps)
            logger.warning("Slow getSessionMetrics: \(String(format: "%.2f", timeElapsed * 1000))ms for \(sets.count) sets")
        }

        return SessionMetrics(
            type: metricsType,
            value: volume,
            maxWeight: maxWeight,
            maxWeightReps: maxWeightReps,
            totalSets: totalSets,
            date: date
        )
    }

    // MARK: - Progress Comparison

    /// Calculate progress percentage between two sessions, handling type mismatches
    static func calculateProgress(today: SessionMetrics, last: SessionMetrics?) -> (percentage: Int, canCompare: Bool) {
        guard let last = last else {
            return (0, false) // No previous session
        }

        // Can only compare if session types match
        guard today.type == last.type else {
            return (0, false) // Type mismatch
        }

        guard last.value > 0 else {
            return (0, false) // Avoid division by zero
        }

        let percentage = Int((today.value / last.value) * 100)
        return (percentage, true)
    }

    // MARK: - Display Helpers

    /// Get unit string - always kg for consistency
    static func getUnit(for type: ExerciseMetricsType) -> String {
        return "kg"
    }

    /// Get progress label - always "Lifted today" for consistency
    static func getProgressLabel(for type: ExerciseMetricsType) -> String {
        return "Lifted today"
    }

    /// Get appropriate total label for the metrics type
    static func getTotalLabel(for type: ExerciseMetricsType) -> String {
        switch type {
        case .weightBased:
            return "Last session total"
        case .repsOnly:
            return "Last session total"
        }
    }
}