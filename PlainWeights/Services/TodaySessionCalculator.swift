//
//  TodaySessionCalculator.swift
//  PlainWeights
//
//  Service for calculating today's workout session metrics
//

import Foundation
import SwiftData

/// Service for calculating today's workout session metrics in real-time
enum TodaySessionCalculator {

    // MARK: - Today's Sets

    /// Get all sets performed today
    static func getTodaysSets(from sets: [ExerciseSet]) -> [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) == today }
    }

    /// Get today's most recent (newest) working set
    static func getTodaysMostRecentSet(from sets: [ExerciseSet]) -> ExerciseSet? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return sets
            .filter { calendar.startOfDay(for: $0.timestamp) == today && !$0.isWarmUp && !$0.isBonus }
            .first  // Sets are already sorted by timestamp descending
    }

    // MARK: - Today's Metrics

    /// Calculate total volume lifted today (updates live as sets are added)
    /// Excludes warm-up and bonus sets from volume calculation
    static func getTodaysVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.workingSets
        return ExerciseVolumeCalculator.calculateVolume(for: workingSets)
    }

    /// Get session metrics for today's session
    /// Excludes warm-up and bonus sets from metrics calculation
    static func getTodaySessionMetrics(from sets: [ExerciseSet]) -> SessionMetrics? {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.workingSets
        guard !workingSets.isEmpty else { return nil }

        return ExerciseVolumeCalculator.getSessionMetrics(for: workingSets, date: Date())
    }

    /// Get today's maximum weight lifted (for Best mode comparisons)
    static func getTodaysMaxWeight(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.workingSets
        return workingSets.map { $0.weight }.max() ?? 0.0
    }

    /// Get today's maximum reps performed (for Best mode comparisons)
    static func getTodaysMaxReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.workingSets
        return workingSets.map { $0.reps }.max() ?? 0
    }

    // MARK: - Session Duration

    /// Get session start time (timestamp of first/oldest set today)
    static func getSessionStartTime(from sets: [ExerciseSet]) -> Date? {
        let todaySets = getTodaysSets(from: sets)
        return todaySets.last?.timestamp  // Sets sorted newest first, .last is oldest
    }

    /// Get most recent set time
    static func getMostRecentSetTime(from sets: [ExerciseSet]) -> Date? {
        let todaySets = getTodaysSets(from: sets)
        return todaySets.first?.timestamp  // Sets sorted newest first
    }

    /// Get session duration in minutes
    /// Duration = time from first set to last set + 3 min rest after last set
    static func getSessionDurationMinutes(from sets: [ExerciseSet]) -> Int? {
        let todaySets = getTodaysSets(from: sets)
        guard !todaySets.isEmpty else { return nil }

        let firstSetTime = todaySets.last?.timestamp   // Oldest set (sorted newest first)
        let lastSetTime = todaySets.first?.timestamp   // Most recent set

        guard let start = firstSetTime, let end = lastSetTime else { return nil }

        // Duration = time between first and last set + 3 min rest after last set
        let duration = end.timeIntervalSince(start) + 180
        return max(1, Int(duration / 60))  // Minimum 1 minute (for single set: ~3 min)
    }

    /// Get today's total reps (sum of working sets only - excludes warm-up and bonus)
    static func getTodaysTotalReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = getTodaysSets(from: sets)
        return todaySets.workingSets.reduce(0) { $0 + $1.reps }
    }
}
