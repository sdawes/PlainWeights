//
//  RecentProgressCalculator.swift
//  PlainWeights
//
//  Calculates progress between the two most recent sessions for an exercise
//

import Foundation

/// Service for calculating progress between the two most recent sessions
enum RecentProgressCalculator {

    struct RecentProgressIndicators {
        let weightImprovement: Double      // e.g., +5.0
        let repsImprovement: Int           // e.g., +2
        let volumeImprovement: Double      // e.g., +20.0
        let weightDirection: ProgressTracker.PRDirection
        let repsDirection: ProgressTracker.PRDirection
        let volumeDirection: ProgressTracker.PRDirection
        let hasValidComparison: Bool       // Has at least 2 sessions
        let isWeightedExercise: Bool       // Most recent session has weight > 0

        var hasAnyChange: Bool {
            weightImprovement != 0 || repsImprovement != 0 || volumeImprovement != 0
        }
    }

    /// Session data for comparison
    private struct SessionData {
        let date: Date
        let maxWeight: Double
        let maxReps: Int
        let volume: Double
    }

    /// Get progress indicators comparing the two most recent sessions
    static func calculate(from sets: [ExerciseSet]) -> RecentProgressIndicators? {
        guard let (recent, previous) = getTwoMostRecentSessions(from: sets) else {
            return nil
        }

        let weightDiff = recent.maxWeight - previous.maxWeight
        let repsDiff = recent.maxReps - previous.maxReps
        let volumeDiff = recent.volume - previous.volume

        let weightDirection: ProgressTracker.PRDirection
        if weightDiff > 0 {
            weightDirection = .up
        } else if weightDiff < 0 {
            weightDirection = .down
        } else {
            weightDirection = .same
        }

        let repsDirection: ProgressTracker.PRDirection
        if repsDiff > 0 {
            repsDirection = .up
        } else if repsDiff < 0 {
            repsDirection = .down
        } else {
            repsDirection = .same
        }

        let volumeDirection: ProgressTracker.PRDirection
        if volumeDiff > 0 {
            volumeDirection = .up
        } else if volumeDiff < 0 {
            volumeDirection = .down
        } else {
            volumeDirection = .same
        }

        return RecentProgressIndicators(
            weightImprovement: weightDiff,
            repsImprovement: repsDiff,
            volumeImprovement: volumeDiff,
            weightDirection: weightDirection,
            repsDirection: repsDirection,
            volumeDirection: volumeDirection,
            hasValidComparison: true,
            isWeightedExercise: recent.maxWeight > 0
        )
    }

    /// Get the two most recent session dates and their metrics
    private static func getTwoMostRecentSessions(from sets: [ExerciseSet]) -> (recent: SessionData, previous: SessionData)? {
        let calendar = Calendar.current

        // Filter to working sets only (exclude warm-up and bonus)
        let workingSets = sets.filter { !$0.isWarmUp && !$0.isBonus }
        guard !workingSets.isEmpty else { return nil }

        // Group sets by day
        let groupedByDay = Dictionary(grouping: workingSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        // Sort days descending (most recent first)
        let sortedDays = groupedByDay.keys.sorted(by: >)

        // Need at least 2 sessions to compare
        guard sortedDays.count >= 2 else { return nil }

        let recentDate = sortedDays[0]
        let previousDate = sortedDays[1]

        guard let recentSets = groupedByDay[recentDate],
              let previousSets = groupedByDay[previousDate] else {
            return nil
        }

        let recentData = SessionData(
            date: recentDate,
            maxWeight: recentSets.map { $0.weight }.max() ?? 0.0,
            maxReps: recentSets.map { $0.reps }.max() ?? 0,
            volume: ExerciseVolumeCalculator.calculateVolume(for: recentSets)
        )

        let previousData = SessionData(
            date: previousDate,
            maxWeight: previousSets.map { $0.weight }.max() ?? 0.0,
            maxReps: previousSets.map { $0.reps }.max() ?? 0,
            volume: ExerciseVolumeCalculator.calculateVolume(for: previousSets)
        )

        return (recent: recentData, previous: previousData)
    }
}
