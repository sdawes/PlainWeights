//
//  SessionStatsCalculator.swift
//  PlainWeights
//
//  Service for calculating session and exercise duration/rest statistics
//

import Foundation

enum SessionStatsCalculator {

    /// Calculate session duration in minutes for a given day's sets
    static func getSessionDurationMinutes(from sets: [ExerciseSet]) -> Int? {
        guard sets.count >= 2 else { return nil }
        let sorted = sets.sorted { $0.timestamp < $1.timestamp }
        guard let first = sorted.first, let last = sorted.last else { return nil }
        let duration = last.timestamp.timeIntervalSince(first.timestamp)
        return max(0, Int(duration / 60))
    }

    /// Calculate exercise duration in minutes for sets of a single exercise
    static func getExerciseDurationMinutes(from sets: [ExerciseSet]) -> Int? {
        guard sets.count >= 2 else { return nil }
        let sorted = sets.sorted { $0.timestamp < $1.timestamp }
        guard let first = sorted.first, let last = sorted.last else { return nil }
        let duration = last.timestamp.timeIntervalSince(first.timestamp)
        return max(0, Int(duration / 60))
    }

    /// Calculate average rest time in seconds for a collection of sets
    static func getAverageRestSeconds(from sets: [ExerciseSet]) -> Int? {
        let restTimes = sets.compactMap { $0.restSeconds }
        guard !restTimes.isEmpty else { return nil }
        return restTimes.reduce(0, +) / restTimes.count
    }
}
