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
    static func getTodaysVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        return ExerciseVolumeCalculator.calculateVolume(for: todaySets)
    }

    /// Get session metrics for today's session
    static func getTodaySessionMetrics(from sets: [ExerciseSet]) -> SessionMetrics? {
        let todaySets = getTodaysSets(from: sets)
        guard !todaySets.isEmpty else { return nil }

        return ExerciseVolumeCalculator.getSessionMetrics(for: todaySets, date: Date())
    }

    /// Get today's maximum weight lifted (for Best mode comparisons)
    static func getTodaysMaxWeight(from sets: [ExerciseSet]) -> Double {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.filter { !$0.isWarmUp && !$0.isBonus }
        return workingSets.map { $0.weight }.max() ?? 0.0
    }

    /// Get today's maximum reps performed (for Best mode comparisons)
    static func getTodaysMaxReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.filter { !$0.isWarmUp && !$0.isBonus }
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
    /// Logic:
    /// - 1 set, < 3 min elapsed: return nil (don't show)
    /// - 1 set, >= 3 min elapsed: return elapsed time since that set
    /// - 2+ sets: return time from first set to most recent set
    static func getSessionDurationMinutes(from sets: [ExerciseSet]) -> Int? {
        let todaySets = getTodaysSets(from: sets)
        guard !todaySets.isEmpty else { return nil }

        let firstSetTime = todaySets.last?.timestamp   // Oldest set (sorted newest first)
        let lastSetTime = todaySets.first?.timestamp   // Most recent set

        guard let start = firstSetTime, let end = lastSetTime else { return nil }

        if todaySets.count == 1 {
            // Only 1 set - check if 3+ minutes have elapsed
            let elapsed = Date().timeIntervalSince(start)
            let elapsedMinutes = Int(elapsed / 60)
            if elapsedMinutes < 3 {
                return nil  // Don't show duration yet
            }
            return elapsedMinutes  // Show elapsed time since first set
        } else {
            // 2+ sets - duration from first to most recent set
            let duration = end.timeIntervalSince(start)
            return max(0, Int(duration / 60))
        }
    }

    /// Get today's total reps (sum of all sets)
    static func getTodaysTotalReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = getTodaysSets(from: sets)
        return todaySets.reduce(0) { $0 + $1.reps }
    }
}
