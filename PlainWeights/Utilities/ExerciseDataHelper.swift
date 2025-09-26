//
//  ExerciseDataHelper.swift
//  PlainWeights
//
//  Shared helper for common exercise data operations
//  Consolidates "last completed day" logic used across multiple services
//

import Foundation

/// Shared utilities for exercise data operations
enum ExerciseDataHelper {

    /// Information about the last completed exercise session
    struct LastCompletedDayInfo {
        let date: Date
        let sets: [ExerciseSet]
        let volume: Double
        let maxWeight: Double
        let maxWeightReps: Int
        let totalSets: Int
    }

    /// Get comprehensive info about the last completed session (before today)
    /// Consolidates logic used by ExerciseSessionMetrics, VolumeAnalytics, and SessionBreakdown
    static func getLastCompletedDayInfo(from sets: [ExerciseSet]) -> LastCompletedDayInfo? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get sets from before today, excluding warm-ups for calculations
        let historicalSets = sets.filter { set in
            calendar.startOfDay(for: set.timestamp) < today && !set.isWarmUp
        }

        guard !historicalSets.isEmpty else { return nil }

        // Group by day and get the most recent day
        let groupedByDay = Dictionary(grouping: historicalSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        guard let lastDate = groupedByDay.keys.max(),
              let lastDaySets = groupedByDay[lastDate] else {
            return nil
        }

        // Calculate metrics using optimized volume calculator
        let volume = ExerciseVolumeCalculator.calculateVolume(for: lastDaySets)
        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0.0
        let maxWeightSets = lastDaySets.filter { $0.weight == maxWeight }
        let maxWeightReps = maxWeightSets.map { $0.reps }.max() ?? 0
        let totalSets = lastDaySets.count

        return LastCompletedDayInfo(
            date: lastDate,
            sets: lastDaySets,
            volume: volume,
            maxWeight: maxWeight,
            maxWeightReps: maxWeightReps,
            totalSets: totalSets
        )
    }

    /// Get just the sets from the last completed day (useful for further processing)
    static func getLastCompletedDaySets(from sets: [ExerciseSet]) -> [ExerciseSet]? {
        return getLastCompletedDayInfo(from: sets)?.sets
    }
}