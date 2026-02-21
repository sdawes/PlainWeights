//
//  SessionStatsCalculator.swift
//  PlainWeights
//
//  Service for calculating session and exercise duration/rest statistics
//

import Foundation

enum SessionStatsCalculator {

    /// Calculate session duration in minutes for a given day's sets
    /// Includes 3-minute rest period after the last set
    static func getSessionDurationMinutes(from sets: [ExerciseSet]) -> Int? {
        guard !sets.isEmpty else { return nil }
        let sorted = sets.sorted { $0.timestamp < $1.timestamp }
        guard let first = sorted.first, let last = sorted.last else { return nil }

        // Duration = time between first and last set + 3 min rest after last set
        let duration = last.timestamp.timeIntervalSince(first.timestamp) + 180
        return max(1, Int(duration / 60))  // Minimum 1 minute (for single set: ~3 min)
    }

    /// Calculate average rest time in seconds for a collection of sets
    static func getAverageRestSeconds(from sets: [ExerciseSet]) -> Int? {
        let restTimes = sets.compactMap { $0.restSeconds }
        guard !restTimes.isEmpty else { return nil }
        return restTimes.reduce(0, +) / restTimes.count
    }
}
