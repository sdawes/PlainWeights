//
//  ExerciseService.swift
//  PlainWeights
//
//  Service for exercise-related business logic
//

import Foundation
import SwiftData

/// Service for exercise-related business logic
enum ExerciseService {

    /// Check if an exercise name already exists (case-insensitive)
    /// - Parameters:
    ///   - name: The name to check
    ///   - excluding: Optional exercise to exclude (for edit mode)
    ///   - context: The model context to query
    /// - Returns: true if a duplicate exists
    static func nameExists(
        _ name: String,
        excluding: Exercise? = nil,
        context: ModelContext
    ) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmedName.isEmpty else { return false }

        let descriptor = FetchDescriptor<Exercise>()
        let allExercises = (try? context.fetch(descriptor)) ?? []

        return allExercises.contains { exercise in
            // Skip the exercise being edited
            if let excluded = excluding,
               exercise.persistentModelID == excluded.persistentModelID {
                return false
            }
            let existingName = exercise.name.trimmingCharacters(in: .whitespaces).lowercased()
            return existingName == trimmedName
        }
    }
}
