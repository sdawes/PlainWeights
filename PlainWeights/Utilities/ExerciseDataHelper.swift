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
        let isDropSet: Bool         // Whether the max weight set was a drop set
        let isPauseAtTop: Bool      // Whether the max weight set was a pause at top set
        let isTimedSet: Bool        // Whether the max weight set was a timed set
        let tempoSeconds: Int       // Tempo duration in seconds
        let isPB: Bool              // Whether the max weight set is marked as a PB
    }

    /// Complete session metrics for the Exercise Summary component
    struct SessionMetricsData {
        let lastSessionMaxWeight: Double
        let lastSessionMaxWeightReps: Int
        let lastSessionTotalSets: Int
        let lastSessionTotalVolume: Double
        let lastSessionTotalWeightVolume: Double  // Weight-only volume for display
        let lastSessionTotalRepsVolume: Int       // Total reps volume from last session
        let todaysVolume: Double
        let hasHistoricalData: Bool
    }

    /// Get comprehensive info about the last completed session (before today)
    /// Consolidates logic used by session calculators, VolumeAnalytics, and SessionBreakdown
    static func getLastCompletedDayInfo(from sets: [ExerciseSet]) -> LastCompletedDayInfo? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get sets from before today, excluding warm-ups and bonus sets for calculations
        let historicalSets = sets.filter { set in
            calendar.startOfDay(for: set.timestamp) < today && !set.isWarmUp && !set.isBonus
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

        // Find the actual best set to get its flags (matches BestSessionCalculator logic)
        let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps })

        return LastCompletedDayInfo(
            date: lastDate,
            sets: lastDaySets,
            volume: volume,
            maxWeight: maxWeight,
            maxWeightReps: maxWeightReps,
            totalSets: totalSets,
            isDropSet: bestSet?.isDropSet ?? false,
            isPauseAtTop: bestSet?.isPauseAtTop ?? false,
            isTimedSet: bestSet?.isTimedSet ?? false,
            tempoSeconds: bestSet?.tempoSeconds ?? 0,
            isPB: bestSet?.isPB ?? false
        )
    }

    /// Get just the sets from the last completed day (useful for further processing)
    static func getLastCompletedDaySets(from sets: [ExerciseSet]) -> [ExerciseSet]? {
        return getLastCompletedDayInfo(from: sets)?.sets
    }

    /// Create complete session metrics with zero defaults for new exercises
    /// Optimized to compute all metrics in minimal passes over the data
    static func getSessionMetricsWithDefaults(from sets: [ExerciseSet]) -> SessionMetricsData {
        // Get last session info once (single shared call)
        let lastDayInfo = getLastCompletedDayInfo(from: sets)

        // Calculate today's volume using TodaySessionCalculator
        let todaysVolume = TodaySessionCalculator.getTodaysVolume(from: sets)

        // Calculate weight-only volume for last session (shows 0 kg for bodyweight exercises)
        let lastSessionWeightVolume = lastDayInfo != nil ?
            ExerciseVolumeCalculator.calculateWeightVolume(for: lastDayInfo!.sets) : 0.0

        // Calculate total reps volume for last session
        let lastSessionRepsVolume = RepsAnalytics.getLastSessionTotalRepsVolume(from: sets)

        return SessionMetricsData(
            lastSessionMaxWeight: lastDayInfo?.maxWeight ?? 0.0,
            lastSessionMaxWeightReps: lastDayInfo?.maxWeightReps ?? 0,
            lastSessionTotalSets: lastDayInfo?.totalSets ?? 0,
            lastSessionTotalVolume: lastDayInfo?.volume ?? 0.0,
            lastSessionTotalWeightVolume: lastSessionWeightVolume,
            lastSessionTotalRepsVolume: lastSessionRepsVolume,
            todaysVolume: todaysVolume,
            hasHistoricalData: lastDayInfo != nil
        )
    }
}