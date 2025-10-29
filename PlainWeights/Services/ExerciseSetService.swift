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

/// Service handling all ExerciseSet operations
enum ExerciseSetService {

    // MARK: - Add Set

    /// Add a new exercise set to the database
    /// - Parameters:
    ///   - weight: Weight in kg
    ///   - reps: Number of repetitions
    ///   - isWarmUp: Whether this is a warm-up set
    ///   - isDropSet: Whether this is a drop set
    ///   - exercise: Parent exercise
    ///   - context: SwiftData model context
    static func addSet(
        weight: Double,
        reps: Int,
        isWarmUp: Bool = false,
        isDropSet: Bool = false,
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
            isDropSet: isDropSet,
            exercise: exercise
        )

        context.insert(set)
        try context.save()
    }

    // MARK: - Repeat Set

    /// Create a duplicate of an existing set with current timestamp
    /// - Parameters:
    ///   - set: The set to duplicate
    ///   - exercise: Parent exercise
    ///   - context: SwiftData model context
    static func repeatSet(
        _ set: ExerciseSet,
        for exercise: Exercise,
        context: ModelContext
    ) throws {
        let newSet = ExerciseSet(
            weight: set.weight,
            reps: set.reps,
            isWarmUp: false, // New sets default to working sets
            isDropSet: false, // New sets default to regular sets
            exercise: exercise
        )

        context.insert(newSet)
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
        context.delete(set)
        try context.save()
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