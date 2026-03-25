//
//  ExerciseDeltaCalculator.swift
//  PlainWeights
//
//  Computes exercise metric deltas (weight, reps, volume) between sessions.
//

import Foundation
import SwiftData

enum ExerciseDeltaCalculator {

    /// Compute deltas for each exercise compared to previous session.
    /// Pre-indexes allSets by exercise ID for O(1) lookup per exercise instead of O(N) full scan.
    static func computeExerciseDeltas(
        for day: ExerciseDataGrouper.WorkoutDay,
        from allSets: [ExerciseSet],
        setsByExercise: [PersistentIdentifier: [ExerciseSet]]? = nil
    ) -> [PersistentIdentifier: ExerciseDeltas] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day.date)

        // Use pre-built index if provided, otherwise build one (single-day case)
        let index = setsByExercise ?? buildWorkingSetIndex(from: allSets)

        var deltas: [PersistentIdentifier: ExerciseDeltas] = [:]

        for exercise in day.exercises {
            let exerciseID = exercise.exercise.persistentModelID
            let workingSets = exercise.sets.workingSets

            // Current session values
            let currentMaxWeight: Double = workingSets.map(\.weight).max() ?? 0
            let isRepsOnly = currentMaxWeight == 0
            // Reps at max weight (consistent with card display), or overall max reps for reps-only
            let currentMaxReps: Int
            if currentMaxWeight > 0 {
                currentMaxReps = workingSets.filter { $0.weight == currentMaxWeight }.map(\.reps).max() ?? 0
            } else {
                currentMaxReps = workingSets.map(\.reps).max() ?? 0
            }
            // For reps-only exercises, use total reps instead of weight × reps volume
            let currentVolume: Double
            if isRepsOnly {
                currentVolume = Double(workingSets.reduce(0) { $0 + $1.reps })
            } else {
                currentVolume = exercise.volume
            }

            // Look up previous sets from pre-built index, filter to before this day
            let allExerciseSets = index[exerciseID] ?? []
            let previousSets = allExerciseSets.filter {
                calendar.startOfDay(for: $0.timestamp) < dayStart
            }

            guard !previousSets.isEmpty else {
                deltas[exerciseID] = .empty
                continue
            }

            // Group by day and get most recent
            let grouped = Dictionary(grouping: previousSets) { set in
                calendar.startOfDay(for: set.timestamp)
            }

            guard let mostRecentDay = grouped.keys.max(),
                  let previousDaySets = grouped[mostRecentDay] else {
                deltas[exerciseID] = .empty
                continue
            }

            // Previous session values (use working sets only for consistency)
            let prevWorkingSets = previousDaySets.filter { !$0.isWarmUp }
            let prevMaxWeight: Double = prevWorkingSets.map(\.weight).max() ?? 0
            // Reps at max weight (consistent with card display), or overall max reps for reps-only
            let prevMaxReps: Int
            if prevMaxWeight > 0 {
                prevMaxReps = prevWorkingSets.filter { $0.weight == prevMaxWeight }.map(\.reps).max() ?? 0
            } else {
                prevMaxReps = prevWorkingSets.map(\.reps).max() ?? 0
            }
            // For reps-only exercises, compare total reps instead of weight × reps volume
            let prevVolume: Double
            if isRepsOnly {
                prevVolume = Double(prevWorkingSets.reduce(0) { $0 + $1.reps })
            } else {
                prevVolume = prevWorkingSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            }

            // Determine direction for each metric
            let weightDir: DeltaDirection = currentMaxWeight > prevMaxWeight ? .up
                : currentMaxWeight < prevMaxWeight ? .down : .same
            let repsDir: DeltaDirection = currentMaxReps > prevMaxReps ? .up
                : currentMaxReps < prevMaxReps ? .down : .same
            let volumeDir: DeltaDirection = currentVolume > prevVolume ? .up
                : currentVolume < prevVolume ? .down : .same

            deltas[exerciseID] = ExerciseDeltas(weight: weightDir, reps: repsDir, volume: volumeDir)
        }

        return deltas
    }

    /// Compute deltas for a single exercise comparing today's working sets against the most recent previous session.
    /// Returns `.empty` if there are no today sets or no previous session to compare against.
    static func computeSingleExerciseDeltas(todaySets: [ExerciseSet], allSets: [ExerciseSet]) -> ExerciseDeltas {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todayWorkingSets = todaySets.workingSets
        guard !todayWorkingSets.isEmpty else { return .empty }

        // Current session values
        let currentMaxWeight: Double = todayWorkingSets.map(\.weight).max() ?? 0
        let isRepsOnly = currentMaxWeight == 0
        // Reps at max weight (matches what the card displays), or overall max reps for reps-only
        let currentMaxReps: Int
        if currentMaxWeight > 0 {
            currentMaxReps = todayWorkingSets.filter { $0.weight == currentMaxWeight }.map(\.reps).max() ?? 0
        } else {
            currentMaxReps = todayWorkingSets.map(\.reps).max() ?? 0
        }
        let currentVolume: Double
        if isRepsOnly {
            currentVolume = Double(todayWorkingSets.reduce(0) { $0 + $1.reps })
        } else {
            currentVolume = todayWorkingSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        }

        // Previous session: working sets before today, grouped by day, most recent day
        let previousSets = allSets.workingSets.filter {
            calendar.startOfDay(for: $0.timestamp) < today
        }
        guard !previousSets.isEmpty else { return .empty }

        let grouped = Dictionary(grouping: previousSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        guard let mostRecentDay = grouped.keys.max(),
              let prevDaySets = grouped[mostRecentDay] else { return .empty }

        // Previous session values
        let prevMaxWeight: Double = prevDaySets.map(\.weight).max() ?? 0
        // Reps at max weight (matches what the card displays), or overall max reps for reps-only
        let prevMaxReps: Int
        if prevMaxWeight > 0 {
            prevMaxReps = prevDaySets.filter { $0.weight == prevMaxWeight }.map(\.reps).max() ?? 0
        } else {
            prevMaxReps = prevDaySets.map(\.reps).max() ?? 0
        }
        let prevVolume: Double
        if isRepsOnly {
            prevVolume = Double(prevDaySets.reduce(0) { $0 + $1.reps })
        } else {
            prevVolume = prevDaySets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        }

        let weightDir: DeltaDirection = currentMaxWeight > prevMaxWeight ? .up
            : currentMaxWeight < prevMaxWeight ? .down : .same
        let repsDir: DeltaDirection = currentMaxReps > prevMaxReps ? .up
            : currentMaxReps < prevMaxReps ? .down : .same
        let volumeDir: DeltaDirection = currentVolume > prevVolume ? .up
            : currentVolume < prevVolume ? .down : .same

        return ExerciseDeltas(weight: weightDir, reps: repsDir, volume: volumeDir)
    }

    /// Build a dictionary index of working sets grouped by exercise ID.
    /// Called once before processing multiple days to avoid repeated O(N) scans.
    static func buildWorkingSetIndex(from allSets: [ExerciseSet]) -> [PersistentIdentifier: [ExerciseSet]] {
        var index: [PersistentIdentifier: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseID = set.exercise?.persistentModelID,
                  !set.isWarmUp else { continue }
            index[exerciseID, default: []].append(set)
        }
        return index
    }
}
