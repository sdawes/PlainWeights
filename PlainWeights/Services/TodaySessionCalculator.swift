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
            .filter { calendar.startOfDay(for: $0.timestamp) == today && !$0.isWarmUp }
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
        let workingSets = todaySets.filter { !$0.isWarmUp }
        return workingSets.map { $0.weight }.max() ?? 0.0
    }

    /// Get today's maximum reps performed (for Best mode comparisons)
    static func getTodaysMaxReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = getTodaysSets(from: sets)
        let workingSets = todaySets.filter { !$0.isWarmUp }
        return workingSets.map { $0.reps }.max() ?? 0
    }
}
