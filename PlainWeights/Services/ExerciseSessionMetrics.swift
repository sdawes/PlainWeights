//
//  ExerciseSessionMetrics.swift
//  PlainWeights
//
//  Service for calculating metrics between exercise sessions
//  Provides data for the Exercise Summary component
//

import Foundation
import SwiftData

/// Service for calculating session-to-session exercise metrics
enum ExerciseSessionMetrics {

    // MARK: - Last Completed Session Metrics

    /// Calculate the maximum weight lifted in the last completed session (not today)
    static func getLastSessionMaxWeight(from sets: [ExerciseSet]) -> Double {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0.0
        }
        return lastSessionInfo.maxWeight
    }

    /// Calculate total reps performed at max weight in last completed session
    static func getLastSessionMaxWeightReps(from sets: [ExerciseSet]) -> Int {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0
        }
        return lastSessionInfo.maxWeightReps
    }

    /// Calculate total number of sets in last completed session
    static func getLastSessionTotalSets(from sets: [ExerciseSet]) -> Int {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0
        }
        return lastSessionInfo.totalSets
    }

    /// Calculate total volume from last completed session
    static func getLastSessionTotalVolume(from sets: [ExerciseSet]) -> Double {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0.0
        }
        return lastSessionInfo.volume
    }

    /// Get session metrics for today's session
    static func getTodaySessionMetrics(from sets: [ExerciseSet]) -> SessionMetrics? {
        let todaySets = getTodaysSets(from: sets)
        guard !todaySets.isEmpty else { return nil }

        return ExerciseVolumeCalculator.getSessionMetrics(for: todaySets, date: Date())
    }

    /// Get session metrics for the last completed session
    static func getLastSessionMetrics(from sets: [ExerciseSet]) -> SessionMetrics? {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return nil
        }

        let calendar = Calendar.current
        let lastSessionSets = sets.filter { set in
            calendar.startOfDay(for: set.timestamp) == calendar.startOfDay(for: lastSessionInfo.date) && !set.isWarmUp
        }

        return ExerciseVolumeCalculator.getSessionMetrics(for: lastSessionSets, date: lastSessionInfo.date)
    }

    /// Get the date of the last completed session
    static func getLastSessionDate(from sets: [ExerciseSet]) -> Date? {
        return getLastCompletedSessionInfo(from: sets)?.date
    }

    // MARK: - Today's Session Metrics

    /// Calculate total volume lifted today (updates live as sets are added)
    static func getTodaysVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        return ExerciseVolumeCalculator.calculateVolume(for: todaySets)
    }

    /// Get all sets performed today
    static func getTodaysSets(from sets: [ExerciseSet]) -> [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) == today }
    }

    // MARK: - Session Comparison & State

    /// Check if exercise has any historical session data (not first-time)
    static func hasHistoricalSessionData(from sets: [ExerciseSet]) -> Bool {
        return getLastCompletedSessionInfo(from: sets) != nil
    }

    /// Create complete session metrics with zero defaults for new exercises
    /// Optimized to compute all metrics in minimal passes over the data
    static func getSessionMetricsWithDefaults(from sets: [ExerciseSet]) -> ExerciseSessionMetricsData {
        // Get last session info once (single shared call)
        let lastDayInfo = ExerciseDataHelper.getLastCompletedDayInfo(from: sets)

        // Calculate today's volume once
        let todaysVolume = getTodaysVolume(from: sets)

        // Calculate weight-only volume for last session (shows 0 kg for bodyweight exercises)
        let lastSessionWeightVolume = lastDayInfo != nil ?
            ExerciseVolumeCalculator.calculateWeightVolume(for: lastDayInfo!.sets) : 0.0

        return ExerciseSessionMetricsData(
            lastSessionMaxWeight: lastDayInfo?.maxWeight ?? 0.0,
            lastSessionMaxWeightReps: lastDayInfo?.maxWeightReps ?? 0,
            lastSessionTotalSets: lastDayInfo?.totalSets ?? 0,
            lastSessionTotalVolume: lastDayInfo?.volume ?? 0.0,
            lastSessionTotalWeightVolume: lastSessionWeightVolume,
            todaysVolume: todaysVolume,
            hasHistoricalData: lastDayInfo != nil
        )
    }

    // MARK: - Private Helper Methods

    /// Get comprehensive info about the last completed session (before today)
    private static func getLastCompletedSessionInfo(from sets: [ExerciseSet]) -> (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int, totalSets: Int)? {
        guard let lastDayInfo = ExerciseDataHelper.getLastCompletedDayInfo(from: sets) else {
            return nil
        }

        return (
            date: lastDayInfo.date,
            volume: lastDayInfo.volume,
            maxWeight: lastDayInfo.maxWeight,
            maxWeightReps: lastDayInfo.maxWeightReps,
            totalSets: lastDayInfo.totalSets
        )
    }

    /// Get effective load for volume calculations (treats 0kg as 1kg for bodyweight exercises)
    private static func effectiveLoad(for weight: Double) -> Double {
        return weight == 0 ? 1.0 : weight
    }
}

// MARK: - Session Metrics Data Structure

/// Complete session metrics for the Exercise Summary component
struct ExerciseSessionMetricsData {
    let lastSessionMaxWeight: Double
    let lastSessionMaxWeightReps: Int
    let lastSessionTotalSets: Int
    let lastSessionTotalVolume: Double
    let lastSessionTotalWeightVolume: Double  // Weight-only volume for display
    let todaysVolume: Double
    let hasHistoricalData: Bool
}