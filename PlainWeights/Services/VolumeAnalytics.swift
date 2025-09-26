//
//  VolumeAnalytics.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation
import SwiftData

/// Service for calculating volume-related metrics for exercises
enum VolumeAnalytics {

    // MARK: - Volume Calculations

    /// Get effective load for volume calculations (treats 0kg as 1kg to maintain unit consistency)
    /// - Parameter weight: The weight value from the exercise set
    /// - Returns: Effective load in kg (1.0 for bodyweight, actual weight otherwise)
    private static func effectiveLoad(for weight: Double) -> Double {
        return weight == 0 ? 1.0 : weight
    }
    
    /// Calculate total volume for sets from today (excludes warm-up sets)
    static func todayVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = todaySets(from: sets)
        return todaySets.filter { !$0.isWarmUp }.reduce(0) { $0 + effectiveLoad(for: $1.weight) * Double($1.reps) }
    }

    /// Get all sets from today
    static func todaySets(from sets: [ExerciseSet]) -> [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) == today }
    }
    
    /// Get information about the last completed day (before today)
    static func lastCompletedDayInfo(from sets: [ExerciseSet]) -> (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int)? {
        guard let lastDayInfo = ExerciseDataHelper.getLastCompletedDayInfo(from: sets) else {
            return nil
        }

        return (lastDayInfo.date, lastDayInfo.volume, lastDayInfo.maxWeight, lastDayInfo.maxWeightReps)
    }

    /// Get max weight and all corresponding reps from last completed day
    /// - Parameter sets: Exercise sets to analyze
    /// - Returns: Tuple with max weight and array of all reps at that weight, or nil if no last day
    static func getMaxWeightFromLastDay(from sets: [ExerciseSet]) -> (weight: Double, allReps: [Int])? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)

        guard let lastDay = pastDays.first,
              let allLastDaySets = setsByDay[lastDay] else {
            return nil
        }

        // Filter out warm-up sets for calculations
        let lastDaySets = allLastDaySets.filter { !$0.isWarmUp }
        guard !lastDaySets.isEmpty else { return nil }

        // Find max weight from last day
        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0

        // Get all reps for sets at max weight, sorted by timestamp (newest first)
        let maxWeightReps = lastDaySets
            .filter { $0.weight == maxWeight }
            .sorted { $0.timestamp > $1.timestamp }
            .map { $0.reps }

        return (maxWeight, maxWeightReps)
    }

    /// Get max weight and the highest rep count achieved at that weight from last completed day
    /// - Parameter sets: Exercise sets to analyze
    /// - Returns: Tuple with max weight and the highest rep count at that weight, or nil if no last day
    static func getMaxRepsAtMaxWeight(from sets: [ExerciseSet]) -> (weight: Double, maxReps: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)

        guard let lastDay = pastDays.first,
              let allLastDaySets = setsByDay[lastDay] else {
            return nil
        }

        // Filter out warm-up sets for calculations
        let lastDaySets = allLastDaySets.filter { !$0.isWarmUp }
        guard !lastDaySets.isEmpty else { return nil }

        // Find max weight from last day
        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0

        // Get the highest rep count achieved at max weight
        let maxReps = lastDaySets
            .filter { $0.weight == maxWeight }
            .map { $0.reps }
            .max() ?? 0

        return (maxWeight, maxReps)
    }

    /// Get max weight, best reps at max weight, and total set count from last completed day
    /// - Parameter sets: Exercise sets to analyze
    /// - Returns: Tuple with max weight, highest rep count at that weight, and total sets, or nil if no last day
    static func getMaxWeightAndSessionStats(from sets: [ExerciseSet]) -> (weight: Double, maxReps: Int, totalSets: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)

        guard let lastDay = pastDays.first,
              let allLastDaySets = setsByDay[lastDay] else {
            return nil
        }

        // Filter out warm-up sets for calculations
        let lastDaySets = allLastDaySets.filter { !$0.isWarmUp }
        guard !lastDaySets.isEmpty else { return nil }

        // Find max weight from last day
        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0

        // Get the highest rep count achieved at max weight
        let maxReps = lastDaySets
            .filter { $0.weight == maxWeight }
            .map { $0.reps }
            .max() ?? 0

        // Count total working sets in that session
        let totalSets = lastDaySets.count

        return (maxWeight, maxReps, totalSets)
    }

    /// Calculate volume for a specific set of exercise sets (excludes warm-up sets)
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        sets.filter { !$0.isWarmUp }.reduce(0) { $0 + effectiveLoad(for: $1.weight) * Double($1.reps) }
    }
    
    // MARK: - Progress Calculations
    
    /// Calculate unclamped progress ratio (can exceed 1.0)
    static func progressRatioUnclamped(todayVolume: Double, lastCompletedVolume: Double?) -> Double {
        let lastVolume = lastCompletedVolume ?? 0
        if lastVolume == 0 {
            return todayVolume > 0 ? 1.0 : 0.0  // 100% if any progress from 0
        }
        return todayVolume / lastVolume
    }
    
    /// Calculate progress ratio clamped to 1.0 for progress bar display
    static func progressBarRatio(todayVolume: Double, lastCompletedVolume: Double?) -> Double {
        let unclamped = progressRatioUnclamped(todayVolume: todayVolume, lastCompletedVolume: lastCompletedVolume)
        return min(unclamped, 1.0)
    }
    
    /// Calculate percentage of last day's volume (can exceed 100%)
    static func percentOfLast(todayVolume: Double, lastCompletedVolume: Double?) -> Int {
        let ratio = progressRatioUnclamped(todayVolume: todayVolume, lastCompletedVolume: lastCompletedVolume)
        return Int(round(ratio * 100))
    }
    
    /// Calculate gains percentage compared to last completed day
    static func gainsPercent(todayVolume: Double, lastCompletedVolume: Double?) -> Int {
        let lastVolume = lastCompletedVolume ?? 0
        if lastVolume == 0 {
            return todayVolume > 0 ? 100 : 0  // 100% gain from nothing
        }
        let gain = (todayVolume - lastVolume) / lastVolume * 100
        return Int(round(gain))
    }
    
    // MARK: - Helper Functions
    
    /// Check if progress bar should be shown - always true for consistency
    static func shouldShowProgressBar(lastCompletedVolume: Double?) -> Bool {
        return true
    }
}