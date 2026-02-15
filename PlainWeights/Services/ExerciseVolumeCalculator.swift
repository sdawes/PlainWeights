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
    case weightOnly   // Has weight > 0, but reps are irrelevant/not tracked (e.g., sled push)
    case combined     // Has both weight > 0 AND reps > 0 (standard weightlifting)
    case repsOnly     // All weights are 0, only reps matter (bodyweight exercises)

    /// Determine the metrics type for a set of exercise sets
    /// Analyzes working sets (excludes warm-ups) to detect exercise pattern
    static func determine(from sets: [ExerciseSet]) -> ExerciseMetricsType {
        // Only consider working sets for type detection
        let workingSets = sets.workingSets

        // If no working sets, default to combined
        guard !workingSets.isEmpty else { return .combined }

        // Check if sets have meaningful weight or reps
        let hasWeight = workingSets.contains { $0.weight > 0 }
        let hasReps = workingSets.contains { $0.reps > 0 }

        // Determine type based on what data exists
        if hasWeight && hasReps {
            return .combined  // User recorded both weight and reps
        } else if hasWeight && !hasReps {
            return .weightOnly  // Only weight matters (e.g., sled push)
        } else if hasReps && !hasWeight {
            return .repsOnly  // Only reps matter (e.g., bodyweight pull-ups)
        } else {
            return .combined  // Fallback to combined for safety
        }
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

    /// Calculate total volume for a set of exercise sets
    /// Volume = weight × reps (only counted when both are present)
    /// Optimized single-pass algorithm
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        var volume = 0.0

        // Single pass to calculate volume
        for set in sets {
            guard !set.isWarmUp else { continue }

            // Only calculate volume when both weight and reps are present
            if set.weight > 0 && set.reps > 0 {
                volume += set.weight * Double(set.reps)
            }
            // If either weight or reps is 0, volume contribution is 0
        }

        return volume
    }

    /// Calculate weight-only volume for display purposes
    /// Volume = weight × reps (only counted when both are present)
    /// Used for "Lifted today" display
    static func calculateWeightVolume(for sets: [ExerciseSet]) -> Double {
        var volume = 0.0

        // Single pass to calculate weight-based volume
        for set in sets {
            guard !set.isWarmUp else { continue }

            // Only calculate volume when both weight and reps are present
            if set.weight > 0 && set.reps > 0 {
                volume += set.weight * Double(set.reps)
            }
            // If either weight or reps is 0, volume contribution is 0
        }

        return volume
    }

    // MARK: - Session Analysis

    /// Get session metrics for a specific set of sets (today or last session)
    /// Optimized single-pass algorithm to avoid multiple array iterations
    static func getSessionMetrics(for sets: [ExerciseSet], date: Date) -> SessionMetrics {
        let startTime = CFAbsoluteTimeGetCurrent()
        var volume = 0.0
        var maxWeight = 0.0
        var maxWeightReps = 0
        var totalSets = 0

        // Single pass through sets to calculate all metrics
        for set in sets {
            guard !set.isWarmUp else { continue }

            totalSets += 1

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
            }
            // Bodyweight exercises (weight == 0) contribute 0 to weight volume
        }

        // Determine type based on actual data pattern (delegate to determine method)
        let metricsType = ExerciseMetricsType.determine(from: sets)

        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        if timeElapsed > 0.016 { // More than one frame (60fps)
            logger.warning("Slow getSessionMetrics: \((timeElapsed * 1000).formatted(.number.precision(.fractionLength(2))))ms for \(sets.count) sets")
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
        case .weightOnly, .combined:
            return "Last session total"
        case .repsOnly:
            return "Last session total"
        }
    }
}