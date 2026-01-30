//
//  ExerciseSetService.swift
//  PlainWeights
//
//  Created by Assistant on 2025-09-22.
//
//  Service for all ExerciseSet-related business logic and database operations.
//  Follows clean architecture by separating business logic from views.

import Foundation
import SwiftData
import UIKit

/// Service handling all ExerciseSet operations
enum ExerciseSetService {

    // MARK: - PB Celebration

    /// Trigger haptic feedback and post notification for PB achievement
    private static func triggerPBCelebration() {
        // Strong haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Post notification for confetti animation
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .pbAchieved, object: nil)
        }
    }

    // MARK: - Add Set

    /// Add a new exercise set to the database
    /// - Parameters:
    ///   - weight: Weight in kg
    ///   - reps: Number of repetitions
    ///   - isWarmUp: Whether this is a warm-up set
    ///   - isBonus: Whether this is a bonus set (excluded from metrics like warm-up)
    ///   - isDropSet: Whether this is a drop set
    ///   - isAssisted: Whether this is an assisted set (e.g., spotter help)
    ///   - isPauseAtTop: Whether this is a pause at top set
    ///   - isTimedSet: Whether this is a timed/tempo set
    ///   - tempoSeconds: Tempo duration in seconds (only used when isTimedSet is true)
    ///   - exercise: Parent exercise
    ///   - context: SwiftData model context
    static func addSet(
        weight: Double,
        reps: Int,
        isWarmUp: Bool = false,
        isBonus: Bool = false,
        isDropSet: Bool = false,
        isAssisted: Bool = false,
        isPauseAtTop: Bool = false,
        isTimedSet: Bool = false,
        tempoSeconds: Int = 0,
        to exercise: Exercise,
        context: ModelContext
    ) throws {
        // Validation happens in validateInput, but double-check here
        guard weight >= 0, reps >= 0 else {
            throw ExerciseSetError.invalidInput
        }

        // At least one must be greater than 0 (same logic as validateInput)
        guard weight > 0 || reps > 0 else {
            throw ExerciseSetError.invalidInput
        }

        let set = ExerciseSet(
            weight: weight,
            reps: reps,
            isWarmUp: isWarmUp,
            isBonus: isBonus,
            isDropSet: isDropSet,
            isAssisted: isAssisted,
            isPauseAtTop: isPauseAtTop,
            isTimedSet: isTimedSet,
            tempoSeconds: tempoSeconds,
            exercise: exercise
        )

        context.insert(set)
        try context.save()

        // Capture rest time on the previous set (how long since that set until this one)
        try captureRestTimeOnPreviousSet(currentSet: set, exercise: exercise, context: context)

        // Detect and mark PB after adding the set
        try detectAndMarkPB(for: set, exercise: exercise, context: context)
    }

    // MARK: - Rest Time Capture

    /// Capture rest time on the previous set when a new set is added
    /// - Parameters:
    ///   - currentSet: The newly added set
    ///   - exercise: Parent exercise
    ///   - context: SwiftData model context
    static func captureRestTimeOnPreviousSet(
        currentSet: ExerciseSet,
        exercise: Exercise,
        context: ModelContext
    ) throws {
        let exerciseID = exercise.persistentModelID
        let currentTimestamp = currentSet.timestamp

        // Find the most recent set BEFORE this one for the same exercise
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate<ExerciseSet> { set in
                set.exercise?.persistentModelID == exerciseID && set.timestamp < currentTimestamp
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        var limitedDescriptor = descriptor
        limitedDescriptor.fetchLimit = 1

        guard let previousSet = try context.fetch(limitedDescriptor).first else {
            // No previous set (this is the first set for this exercise today)
            return
        }

        // Calculate rest time in seconds
        let restTime = Int(currentTimestamp.timeIntervalSince(previousSet.timestamp))

        // Cap at 180 seconds (3 minutes)
        previousSet.restSeconds = min(restTime, 180)
        try context.save()
    }

    /// Update rest time on a set (called when timer expires at 180s)
    /// - Parameters:
    ///   - set: The set to update
    ///   - context: SwiftData model context
    static func captureRestTimeExpiry(
        for set: ExerciseSet,
        context: ModelContext
    ) throws {
        set.restSeconds = 180
        try context.save()
    }

    // MARK: - Delete Set

    /// Delete a set from the database
    /// - Parameters:
    ///   - set: The set to delete
    ///   - context: SwiftData model context
    static func deleteSet(
        _ set: ExerciseSet,
        context: ModelContext
    ) throws {
        let wasPB = set.isPB
        let exercise = set.exercise

        context.delete(set)
        try context.save()

        // If deleted set was PB, recalculate for the exercise
        if wasPB, let exercise = exercise {
            try recalculatePB(for: exercise, context: context)
        }
    }

    /// Recalculate PB for an exercise after a PB set is deleted
    /// - Parameters:
    ///   - exercise: The exercise to recalculate PB for
    ///   - context: SwiftData model context
    static func recalculatePB(for exercise: Exercise, context: ModelContext) throws {
        let exerciseID = exercise.persistentModelID
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate<ExerciseSet> { set in
                set.exercise?.persistentModelID == exerciseID && !set.isWarmUp && !set.isBonus
            }
        )

        let allWorkingSets = try context.fetch(descriptor)

        // Clear all PB flags
        for set in allWorkingSets {
            set.isPB = false
        }

        // Find new PB (max weight, then max reps, then earliest timestamp)
        guard let maxWeight = allWorkingSets.map({ $0.weight }).max() else { return }
        let setsAtMaxWeight = allWorkingSets.filter { $0.weight == maxWeight }
        guard let maxReps = setsAtMaxWeight.map({ $0.reps }).max() else { return }
        let bestSets = setsAtMaxWeight.filter { $0.reps == maxReps }

        if let newPB = bestSets.min(by: { $0.timestamp < $1.timestamp }) {
            newPB.isPB = true
        }

        try context.save()
    }

    // MARK: - Update Set

    /// Update an existing exercise set
    /// - Parameters:
    ///   - set: The set to update
    ///   - weight: New weight in kg
    ///   - reps: New number of repetitions
    ///   - isWarmUp: Whether this is a warm-up set
    ///   - isBonus: Whether this is a bonus set (excluded from metrics like warm-up)
    ///   - isDropSet: Whether this is a drop set
    ///   - isAssisted: Whether this is an assisted set (e.g., spotter help)
    ///   - isPauseAtTop: Whether this is a pause at top set
    ///   - isTimedSet: Whether this is a timed/tempo set
    ///   - tempoSeconds: Tempo duration in seconds (only used when isTimedSet is true)
    ///   - context: SwiftData model context
    static func updateSet(
        _ set: ExerciseSet,
        weight: Double,
        reps: Int,
        isWarmUp: Bool,
        isBonus: Bool,
        isDropSet: Bool,
        isAssisted: Bool,
        isPauseAtTop: Bool,
        isTimedSet: Bool,
        tempoSeconds: Int,
        context: ModelContext
    ) throws {
        // Validation
        guard weight >= 0, reps >= 0 else {
            throw ExerciseSetError.invalidInput
        }

        guard weight > 0 || reps > 0 else {
            throw ExerciseSetError.invalidInput
        }

        // Update all fields (timestamp is preserved)
        set.weight = weight
        set.reps = reps
        set.isWarmUp = isWarmUp
        set.isBonus = isBonus
        set.isDropSet = isDropSet
        set.isAssisted = isAssisted
        set.isPauseAtTop = isPauseAtTop
        set.isTimedSet = isTimedSet
        set.tempoSeconds = tempoSeconds

        try context.save()

        // Recalculate PBs since values or warm-up/bonus status may have changed
        if let exercise = set.exercise {
            try detectAndMarkPB(for: set, exercise: exercise, context: context)
        }
    }

    // MARK: - Toggle Warm-Up

    /// Toggle the warm-up status of a set
    /// - Parameters:
    ///   - set: The set to modify
    ///   - context: SwiftData model context
    static func toggleWarmUpStatus(
        _ set: ExerciseSet,
        context: ModelContext
    ) throws {
        set.isWarmUp.toggle()
        try context.save()

        // Recalculate PBs since warm-up status affects eligibility
        if let exercise = set.exercise {
            try detectAndMarkPB(for: set, exercise: exercise, context: context)
        }
    }

    // MARK: - Toggle Drop Set

    /// Toggle the drop set status of a set
    /// - Parameters:
    ///   - set: The set to modify
    ///   - context: SwiftData model context
    static func toggleDropSetStatus(
        _ set: ExerciseSet,
        context: ModelContext
    ) throws {
        set.isDropSet.toggle()
        try context.save()
    }

    // MARK: - PB Detection

    /// Detect and mark personal best (PB) for a new set
    ///
    /// Logic:
    /// 1. Weight takes precedence (highest weight wins)
    /// 2. If multiple sets at same max weight, highest reps wins
    /// 3. If same weight AND reps, earliest timestamp keeps PB
    /// 4. Warm-up and bonus sets are excluded from PB consideration
    ///
    /// - Parameters:
    ///   - newSet: The newly added set to evaluate
    ///   - exercise: Parent exercise
    ///   - context: SwiftData model context
    static func detectAndMarkPB(
        for newSet: ExerciseSet,
        exercise: Exercise,
        context: ModelContext
    ) throws {
        // Only working sets can be PBs (exclude warm-ups and bonus sets)
        guard !newSet.isWarmUp && !newSet.isBonus else { return }

        // Fetch all working sets for this exercise
        let exerciseID = exercise.persistentModelID
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate<ExerciseSet> { set in
                set.exercise?.persistentModelID == exerciseID && !set.isWarmUp && !set.isBonus
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        let allWorkingSets = try context.fetch(descriptor)

        // Find max weight
        guard let maxWeight = allWorkingSets.map({ $0.weight }).max() else {
            // No sets exist, make this one the PB
            newSet.isPB = true
            triggerPBCelebration()
            try context.save()
            return
        }

        // Get all sets at max weight
        let setsAtMaxWeight = allWorkingSets.filter { $0.weight == maxWeight }

        // Find max reps at max weight
        guard let maxReps = setsAtMaxWeight.map({ $0.reps }).max() else { return }

        // Get all sets at max weight and max reps
        let bestSets = setsAtMaxWeight.filter { $0.reps == maxReps }

        // Earliest timestamp wins (first achiever keeps PB)
        guard let currentPB = bestSets.min(by: { $0.timestamp < $1.timestamp }) else { return }

        // Clear all PB flags first
        for set in allWorkingSets {
            set.isPB = false
        }

        // Mark the winner
        currentPB.isPB = true

        // Trigger celebration only if the new set is the PB
        if currentPB.id == newSet.id {
            triggerPBCelebration()
        }

        try context.save()
    }

    // MARK: - Input Validation

    /// Validate text input for weight and reps
    /// - Parameters:
    ///   - weightText: String input for weight (empty treated as 0)
    ///   - repsText: String input for reps (empty treated as 0)
    /// - Returns: Tuple of valid weight and reps, or nil if both are 0
    static func validateInput(
        weightText: String,
        repsText: String
    ) -> (weight: Double, reps: Int)? {
        // Treat empty fields as 0
        let weight = Double(weightText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let reps = Int(repsText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        // Both weight and reps must be non-negative
        guard weight >= 0, reps >= 0 else {
            return nil
        }

        // At least one must be greater than 0
        guard weight > 0 || reps > 0 else {
            return nil
        }

        return (weight, reps)
    }
}

// MARK: - Error Types

enum ExerciseSetError: LocalizedError {
    case invalidInput
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid weight or reps. Weight must be >= 0 and reps must be > 0."
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}