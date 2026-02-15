//
//  RepsAnalytics.swift
//  PlainWeights
//
//  Created by Claude on 06/10/2025.
//

import Foundation

/// Analytics service for rep-based metrics (bodyweight exercises, calisthenics, etc.)
enum RepsAnalytics {

    /// Calculate total reps across all sets
    /// - Parameter sets: Array of ExerciseSet
    /// - Returns: Sum of all reps
    static func calculateTotalReps(from sets: [ExerciseSet]) -> Int {
        sets.reduce(0) { $0 + $1.reps }
    }

    /// Get total reps from today's session
    /// - Parameter sets: Array of ExerciseSet
    /// - Returns: Sum of reps from today only (excluding warm-ups)
    static func getTodayTotalReps(from sets: [ExerciseSet]) -> Int {
        let todaySets = sets.filter { Calendar.current.isDateInToday($0.timestamp) && !$0.isWarmUp }
        return calculateTotalReps(from: todaySets)
    }

    /// Get total reps from the most recent completed session (excluding today)
    /// - Parameter sets: Array of ExerciseSet sorted by timestamp descending
    /// - Returns: Sum of reps from last session, or 0 if no previous session
    static func getLastSessionTotalReps(from sets: [ExerciseSet]) -> Int {
        let calendar = Calendar.current

        // Filter out today's sets
        let historicSets = sets.filter { !calendar.isDateInToday($0.timestamp) }

        guard let mostRecentDate = historicSets.first?.timestamp else {
            return 0
        }

        // Get all sets from the most recent day
        let lastSessionSets = historicSets.filter {
            calendar.isDate($0.timestamp, inSameDayAs: mostRecentDate)
        }

        return calculateTotalReps(from: lastSessionSets)
    }

    /// Get the maximum reps achieved in a single set from the last session
    /// - Parameter sets: Array of ExerciseSet sorted by timestamp descending
    /// - Returns: Max reps from last session, or 0 if no previous session
    static func getMaxRepsFromLastSession(from sets: [ExerciseSet]) -> Int {
        let calendar = Calendar.current

        // Filter out today's sets and warm-ups
        let historicWorkingSets = sets.filter {
            !calendar.isDateInToday($0.timestamp) && !$0.isWarmUp
        }

        guard let mostRecentDate = historicWorkingSets.first?.timestamp else {
            return 0
        }

        // Get all working sets from the most recent day
        let lastSessionSets = historicWorkingSets.filter {
            calendar.isDate($0.timestamp, inSameDayAs: mostRecentDate)
        }

        return lastSessionSets.map { $0.reps }.max() ?? 0
    }

    /// Get total volume of reps from the most recent completed reps-only session (excluding today)
    /// Only considers sessions where all working sets have weight=0
    /// - Parameter sets: Array of ExerciseSet sorted by timestamp descending
    /// - Returns: Sum of all reps from last reps-only session, or 0 if no previous reps-only session
    static func getLastSessionTotalRepsVolume(from sets: [ExerciseSet]) -> Int {
        let calendar = Calendar.current

        // Filter out today's sets and warm-ups
        let historicWorkingSets = sets.filter {
            !calendar.isDateInToday($0.timestamp) && !$0.isWarmUp
        }

        // Group by day
        let grouped = Dictionary(grouping: historicWorkingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Sort days by date descending
        let sortedDays = grouped.keys.sorted(by: >)

        // Find the most recent day that is reps-only (all sets have weight=0)
        for day in sortedDays {
            guard let daySets = grouped[day] else { continue }
            let isRepsOnlyDay = daySets.allSatisfy { $0.weight == 0 }
            if isRepsOnlyDay {
                return calculateTotalReps(from: daySets)
            }
        }

        return 0
    }

    /// Get total reps from the best reps-only session ever (highest total reps in a single day, excluding today)
    /// Only considers sessions where all working sets have weight=0
    /// - Parameter sets: Array of ExerciseSet
    /// - Returns: Highest total reps from any reps-only session, or 0 if no previous reps-only sessions
    static func getBestSessionTotalReps(from sets: [ExerciseSet]) -> Int {
        let calendar = Calendar.current

        // Filter out today's sets and warm-ups
        let historicWorkingSets = sets.filter {
            !calendar.isDateInToday($0.timestamp) && !$0.isWarmUp
        }

        // Group by day
        let grouped = Dictionary(grouping: historicWorkingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Find the day with highest total reps (only considering reps-only days)
        var bestTotal = 0
        for (_, daySets) in grouped {
            // Only consider days where all sets have weight=0
            let isRepsOnlyDay = daySets.allSatisfy { $0.weight == 0 }
            if isRepsOnlyDay {
                let dayTotal = calculateTotalReps(from: daySets)
                if dayTotal > bestTotal {
                    bestTotal = dayTotal
                }
            }
        }

        return bestTotal
    }

    // MARK: - Reps Volume Comparison

    /// Calculate reps volume difference for display (positive = more, negative = left)
    /// - Parameters:
    ///   - todayTotal: Total reps from today's session
    ///   - lastSessionTotal: Total reps from last session
    /// - Returns: Tuple with amount and label ("more" or "left"), or nil if equal or no data
    static func calculateRepsVolumeDifference(todayTotal: Int, lastSessionTotal: Int) -> (amount: Int, label: String)? {
        guard todayTotal > 0 else { return nil }

        let diff = todayTotal - lastSessionTotal
        if diff > 0 {
            return (diff, "more")
        } else if diff < 0 {
            return (abs(diff), "left")
        }
        return nil // Equal, no message
    }
}
