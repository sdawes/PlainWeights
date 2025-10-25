//
//  LastSessionCalculator.swift
//  PlainWeights
//
//  Service for calculating last completed session metrics
//  (most recent day before today)
//

import Foundation
import SwiftData

/// Service for calculating last completed session metrics
/// Provides data about the most recent workout day before today
enum LastSessionCalculator {

    // MARK: - Last Session Metrics

    /// Calculate the maximum weight lifted in the last completed session (not today)
    static func getLastSessionMaxWeight(from sets: [ExerciseSet]) -> Double {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0.0
        }
        return lastSessionInfo.maxWeight
    }

    /// Calculate total reps performed at max weight in last completed session
    static func getLastSessionMaxReps(from sets: [ExerciseSet]) -> Int {
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
    static func getLastSessionVolume(from sets: [ExerciseSet]) -> Double {
        guard let lastSessionInfo = getLastCompletedSessionInfo(from: sets) else {
            return 0.0
        }
        return lastSessionInfo.volume
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

    /// Check if exercise has any historical session data (not first-time)
    static func hasLastSession(from sets: [ExerciseSet]) -> Bool {
        return getLastCompletedSessionInfo(from: sets) != nil
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
}
