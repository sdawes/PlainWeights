//
//  BestSessionCalculator.swift
//  PlainWeights
//
//  Created by Assistant on 2025-10-22.
//

import Foundation

/// Service for calculating all-time best session metrics for exercises
enum BestSessionCalculator {

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

    /// Calculate best day metrics - finds the best performance day at max weight
    ///
    /// Logic:
    /// - Priority 1: Find the maximum weight ever lifted
    /// - Priority 2: Among all days where that max weight was lifted, find the day with highest total volume
    /// - Returns all metrics from that single best day (max weight, max reps at max weight, total volume)
    /// - For bodyweight exercises, finds the day with highest total reps
    ///
    /// Performance: O(n) for filtering + O(d) for day grouping where d = number of unique days
    ///
    /// - Parameter sets: Array of exercise sets to analyze
    /// - Returns: BestDayMetrics with max weight, reps, and total day volume, or nil if no working sets
    static func calculateBestDayMetrics(from sets: [ExerciseSet]) -> BestDayMetrics? {
        // Filter out warm-up sets
        let workingSets = sets.filter { !$0.isWarmUp }
        guard !workingSets.isEmpty else { return nil }

        // Check if this is a bodyweight exercise
        let isBodyweightExercise = workingSets.allSatisfy { $0.weight == 0 }

        let calendar = Calendar.current

        if isBodyweightExercise {
            // For bodyweight: find the day with highest total reps
            var dayMetrics: [Date: (totalReps: Int, maxReps: Int)] = [:]

            for set in workingSets {
                let dayStart = calendar.startOfDay(for: set.timestamp)

                // Get all sets from this day
                let setsFromDay = workingSets.filter { calendar.startOfDay(for: $0.timestamp) == dayStart }

                // Calculate total reps for the day
                let totalReps = setsFromDay.reduce(0) { $0 + $1.reps }

                // Find max reps from any set on this day
                let maxReps = setsFromDay.map { $0.reps }.max() ?? 0

                dayMetrics[dayStart] = (totalReps: totalReps, maxReps: maxReps)
            }

            // Find the day with highest total reps
            guard let bestDay = dayMetrics.max(by: { $0.value.totalReps < $1.value.totalReps }) else {
                return nil
            }

            return BestDayMetrics(
                maxWeight: 0,
                repsAtMaxWeight: bestDay.value.maxReps,
                totalVolume: Double(bestDay.value.totalReps),
                date: bestDay.key,
                isBodyweight: true
            )
        } else {
            // For weighted exercises: find max weight, then best volume day at that weight
            let maxWeight = workingSets.map { $0.weight }.max() ?? 0

            // Get all sets with max weight
            let maxWeightSets = workingSets.filter { $0.weight == maxWeight }

            // Get all unique days where max weight was lifted
            let daysWithMaxWeight = Set(maxWeightSets.map { calendar.startOfDay(for: $0.timestamp) })

            // For each day with max weight, calculate total volume and max reps at max weight
            var dayMetrics: [Date: (volume: Double, maxReps: Int)] = [:]

            for dayStart in daysWithMaxWeight {
                // Get all working sets from this day
                let setsFromDay = workingSets.filter { calendar.startOfDay(for: $0.timestamp) == dayStart }

                // Calculate total volume for the entire day
                let totalVolume = setsFromDay.reduce(0.0) { sum, set in
                    sum + (set.weight * Double(set.reps))
                }

                // Find the highest reps at max weight on this day
                let maxWeightSetsFromDay = setsFromDay.filter { $0.weight == maxWeight }
                let maxRepsAtMaxWeight = maxWeightSetsFromDay.map { $0.reps }.max() ?? 0

                dayMetrics[dayStart] = (volume: totalVolume, maxReps: maxRepsAtMaxWeight)
            }

            // Find the day with the highest total volume
            guard let bestDay = dayMetrics.max(by: { $0.value.volume < $1.value.volume }) else {
                return nil
            }

            return BestDayMetrics(
                maxWeight: maxWeight,
                repsAtMaxWeight: bestDay.value.maxReps,
                totalVolume: bestDay.value.volume,
                date: bestDay.key,
                isBodyweight: false
            )
        }
    }

    // MARK: - Convenience Methods

    /// Get the best max weight ever lifted (convenience wrapper)
    static func getBestMaxWeight(from sets: [ExerciseSet]) -> Double {
        return calculateBestDayMetrics(from: sets)?.maxWeight ?? 0.0
    }

    /// Get the best reps performed at max weight (convenience wrapper)
    static func getBestMaxReps(from sets: [ExerciseSet]) -> Int {
        return calculateBestDayMetrics(from: sets)?.repsAtMaxWeight ?? 0
    }

    /// Get the best total volume from a single day (convenience wrapper)
    static func getBestVolume(from sets: [ExerciseSet]) -> Double {
        return calculateBestDayMetrics(from: sets)?.totalVolume ?? 0.0
    }
}
