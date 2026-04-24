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

            // Previous session values
            let prevWorkingSets = previousDaySets
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
            // For reps, check if ANY set in the session beat the reference reps (not just reps at max weight)
            let currentHighestReps = workingSets.map(\.reps).max() ?? 0
            let weightDir: DeltaDirection = currentMaxWeight > prevMaxWeight ? .up
                : currentMaxWeight < prevMaxWeight ? .down : .same
            let repsDir: DeltaDirection = currentHighestReps > prevMaxReps ? .up
                : currentHighestReps < prevMaxReps ? .down : .same
            let volumeDir: DeltaDirection = currentVolume > prevVolume ? .up
                : currentVolume < prevVolume ? .down : .same

            deltas[exerciseID] = ExerciseDeltas(weight: weightDir, reps: repsDir, volume: volumeDir)
        }

        return deltas
    }

    /// Compute deltas for a single exercise comparing today's working sets against reference values.
    /// Each metric checks if ANY individual set today beat the reference — once beaten, it stays beaten.
    /// Returns `.empty` if there are no today sets or reference values are all zero.
    static func computeSingleExerciseDeltas(
        todaySets: [ExerciseSet],
        refMaxWeight: Double,
        refMaxReps: Int,
        refTotalVolume: Double,
        isRepsOnly: Bool
    ) -> ExerciseDeltas {
        let todayWorkingSets = todaySets.workingSets
        guard !todayWorkingSets.isEmpty else { return .empty }
        guard refMaxWeight > 0 || refMaxReps > 0 || refTotalVolume > 0 else { return .empty }

        // Check if ANY individual set today beat each metric (high-water mark — once beaten, stays beaten)
        let weightBeaten = todayWorkingSets.contains { $0.weight > refMaxWeight }
        let repsBeaten = todayWorkingSets.contains { $0.reps > refMaxReps }

        // Volume is cumulative — compare session totals
        let currentVolume: Double
        if isRepsOnly {
            currentVolume = Double(todayWorkingSets.reduce(0) { $0 + $1.reps })
        } else {
            currentVolume = todayWorkingSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
        }
        let volumeBeaten = currentVolume > refTotalVolume

        // Determine direction: beaten = .up, otherwise check current aggregate vs ref
        let weightDir: DeltaDirection
        if weightBeaten {
            weightDir = .up
        } else {
            let currentMaxWeight: Double = todayWorkingSets.map(\.weight).max() ?? 0
            weightDir = currentMaxWeight < refMaxWeight ? .down : .same
        }

        let repsDir: DeltaDirection
        if repsBeaten {
            repsDir = .up
        } else {
            let currentMaxReps: Int = todayWorkingSets.map(\.reps).max() ?? 0
            repsDir = currentMaxReps < refMaxReps ? .down : .same
        }

        let volumeDir: DeltaDirection = volumeBeaten ? .up
            : currentVolume < refTotalVolume ? .down : .same

        return ExerciseDeltas(weight: weightDir, reps: repsDir, volume: volumeDir)
    }

    /// Build a dictionary index of sets grouped by exercise ID.
    /// Called once before processing multiple days to avoid repeated O(N) scans.
    static func buildWorkingSetIndex(from allSets: [ExerciseSet]) -> [PersistentIdentifier: [ExerciseSet]] {
        var index: [PersistentIdentifier: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseID = set.exercise?.persistentModelID else { continue }
            index[exerciseID, default: []].append(set)
        }
        return index
    }
}
