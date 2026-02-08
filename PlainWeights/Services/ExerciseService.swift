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

    // MARK: - Tag Analytics

    /// Calculate tag distribution percentages for exercises done today
    /// Each exercise contributes equally (1.0), split among its tags
    static func todayTagDistribution(context: ModelContext) -> [(tag: String, percentage: Double)] {
        // Get today's date range
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()

        // Query today's sets
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate<ExerciseSet> { set in
                set.timestamp >= startOfDay && set.timestamp < endOfDay
            }
        )

        let todaySets = (try? context.fetch(descriptor)) ?? []

        // Get unique exercises done today (that have tags)
        var uniqueExercises: [Exercise] = []
        var seenIDs = Set<PersistentIdentifier>()
        for set in todaySets {
            if let exercise = set.exercise,
               !exercise.tags.isEmpty,
               !seenIDs.contains(exercise.persistentModelID) {
                seenIDs.insert(exercise.persistentModelID)
                uniqueExercises.append(exercise)
            }
        }

        guard !uniqueExercises.isEmpty else { return [] }

        // Calculate tag weights
        var tagWeights: [String: Double] = [:]
        for exercise in uniqueExercises {
            let weight = 1.0 / Double(exercise.tags.count)
            for tag in exercise.tags {
                tagWeights[tag, default: 0] += weight
            }
        }

        // Convert to percentages
        let totalWeight = Double(uniqueExercises.count)
        return tagWeights
            .map { (tag: $0.key, percentage: ($0.value / totalWeight) * 100) }
            .sorted { $0.percentage > $1.percentage }
    }

    // MARK: - Duplicate Name Check

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
