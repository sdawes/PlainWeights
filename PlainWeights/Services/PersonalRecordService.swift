//
//  PersonalRecordService.swift
//  PlainWeights
//
//  Created by Assistant on 2025-10-22.
//

import Foundation

/// Service for calculating all-time personal records for exercises
enum PersonalRecordService {

    // MARK: - Data Structures

    /// Represents an all-time personal record for an exercise
    struct PersonalRecord {
        let weight: Double
        let reps: Int
        let date: Date
        let isBodyweight: Bool  // True if weight is 0 (bodyweight exercise)
    }

    /// Enhanced PR data including the full day's performance when PR was achieved
    struct BestDayMetrics {
        let maxWeight: Double        // Best weight ever lifted
        let repsAtMaxWeight: Int     // Reps at that max weight
        let totalVolume: Double      // Total volume for that entire day
        let date: Date              // Date when this PR occurred
        let isBodyweight: Bool
    }

    // MARK: - PR Calculation

    /// Calculate the all-time personal record for an exercise
    ///
    /// Logic:
    /// - Finds the set with the highest weight
    /// - If multiple sets have the same max weight, returns the one with highest reps
    /// - For bodyweight exercises (0kg), returns the set with highest reps
    /// - Excludes warm-up sets from calculations
    /// - Returns nil if no working sets exist
    ///
    /// Performance: O(n) single pass through sets array
    ///
    /// - Parameter sets: Array of exercise sets to analyze
    /// - Returns: PersonalRecord with best weight/reps combination, or nil if no working sets
    static func calculateAllTimePR(from sets: [ExerciseSet]) -> PersonalRecord? {
        // Filter out warm-up sets
        let workingSets = sets.filter { !$0.isWarmUp }

        // Return nil if no working sets
        guard !workingSets.isEmpty else { return nil }

        // Check if this is a bodyweight exercise (all sets have 0 weight)
        let isBodyweightExercise = workingSets.allSatisfy { $0.weight == 0 }

        if isBodyweightExercise {
            // For bodyweight: find set with maximum reps
            guard let bestSet = workingSets.max(by: { $0.reps < $1.reps }) else {
                return nil
            }

            return PersonalRecord(
                weight: 0,
                reps: bestSet.reps,
                date: bestSet.timestamp,
                isBodyweight: true
            )
        } else {
            // For weighted exercises: find max weight first
            let maxWeight = workingSets.map { $0.weight }.max() ?? 0

            // Get all sets with max weight
            let maxWeightSets = workingSets.filter { $0.weight == maxWeight }

            // Among max weight sets, find the one with highest reps
            guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else {
                return nil
            }

            return PersonalRecord(
                weight: bestSet.weight,
                reps: bestSet.reps,
                date: bestSet.timestamp,
                isBodyweight: false
            )
        }
    }

    // MARK: - Best Day Metrics

    /// Calculate best day metrics including the full day's performance when PR was achieved
    ///
    /// Logic:
    /// - Finds the personal record (max weight + reps)
    /// - Identifies the date when this PR occurred
    /// - Calculates total volume for ALL sets on that day
    /// - Returns complete metrics for that best day
    ///
    /// Performance: O(n) + O(n) = O(n) - two passes through sets array
    ///
    /// - Parameter sets: Array of exercise sets to analyze
    /// - Returns: BestDayMetrics with max weight, reps, and total day volume, or nil if no working sets
    static func calculateBestDayMetrics(from sets: [ExerciseSet]) -> BestDayMetrics? {
        // First, get the personal record
        guard let pr = calculateAllTimePR(from: sets) else {
            return nil
        }

        // Get all sets from the same day as the PR
        let calendar = Calendar.current
        let prDayStart = calendar.startOfDay(for: pr.date)

        let setsFromPRDay = sets.filter { set in
            let setDayStart = calendar.startOfDay(for: set.timestamp)
            return setDayStart == prDayStart && !set.isWarmUp
        }

        // Calculate total volume for that day
        let totalVolume = setsFromPRDay.reduce(0.0) { sum, set in
            sum + (set.weight * Double(set.reps))
        }

        return BestDayMetrics(
            maxWeight: pr.weight,
            repsAtMaxWeight: pr.reps,
            totalVolume: totalVolume,
            date: pr.date,
            isBodyweight: pr.isBodyweight
        )
    }
}
