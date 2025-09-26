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

    /// Get the date of the last completed session
    static func getLastSessionDate(from sets: [ExerciseSet]) -> Date? {
        return getLastCompletedSessionInfo(from: sets)?.date
    }

    // MARK: - Today's Session Metrics

    /// Calculate total volume lifted today (updates live as sets are added)
    static func getTodaysVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        return todaySets.filter { !$0.isWarmUp }.reduce(0) { total, set in
            total + effectiveLoad(for: set.weight) * Double(set.reps)
        }
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
    static func getSessionMetricsWithDefaults(from sets: [ExerciseSet]) -> SessionMetrics {
        return SessionMetrics(
            lastSessionMaxWeight: getLastSessionMaxWeight(from: sets),
            lastSessionMaxWeightReps: getLastSessionMaxWeightReps(from: sets),
            lastSessionTotalSets: getLastSessionTotalSets(from: sets),
            lastSessionTotalVolume: getLastSessionTotalVolume(from: sets),
            todaysVolume: getTodaysVolume(from: sets),
            hasHistoricalData: hasHistoricalSessionData(from: sets)
        )
    }

    // MARK: - Private Helper Methods

    /// Get comprehensive info about the last completed session (before today)
    private static func getLastCompletedSessionInfo(from sets: [ExerciseSet]) -> (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int, totalSets: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get sets from before today, excluding warm-ups
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

        // Calculate metrics for that day
        let volume = lastDaySets.reduce(0) { total, set in
            total + effectiveLoad(for: set.weight) * Double(set.reps)
        }

        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0.0
        let maxWeightSets = lastDaySets.filter { $0.weight == maxWeight }
        let maxWeightReps = maxWeightSets.map { $0.reps }.max() ?? 0
        let totalSets = lastDaySets.count

        return (date: lastDate, volume: volume, maxWeight: maxWeight, maxWeightReps: maxWeightReps, totalSets: totalSets)
    }

    /// Get effective load for volume calculations (treats 0kg as 1kg for bodyweight exercises)
    private static func effectiveLoad(for weight: Double) -> Double {
        return weight == 0 ? 1.0 : weight
    }
}

// MARK: - Session Metrics Data Structure

/// Complete session metrics for the Exercise Summary component
struct SessionMetrics {
    let lastSessionMaxWeight: Double
    let lastSessionMaxWeightReps: Int
    let lastSessionTotalSets: Int
    let lastSessionTotalVolume: Double
    let todaysVolume: Double
    let hasHistoricalData: Bool
}