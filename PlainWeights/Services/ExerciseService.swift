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
    /// Weighted by set count: exercises with more sets contribute more to tag percentages
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

        // Count sets per exercise and collect exercises with tags
        var setCountByExercise: [PersistentIdentifier: Int] = [:]
        var exercisesByID: [PersistentIdentifier: Exercise] = [:]

        for set in todaySets {
            guard let exercise = set.exercise, !exercise.tags.isEmpty else { continue }
            let id = exercise.persistentModelID
            setCountByExercise[id, default: 0] += 1
            exercisesByID[id] = exercise
        }

        guard !exercisesByID.isEmpty else { return [] }

        // Calculate tag weights (weighted by set count, split among tags)
        // Secondary tags are weighted at 33% of primary tags (1/3)
        let secondaryWeight = 0.33
        var tagWeights: [String: Double] = [:]
        var totalSets: Double = 0

        for (id, exercise) in exercisesByID {
            let setCount = Double(setCountByExercise[id] ?? 0)
            totalSets += setCount

            // Calculate effective tag count (primaries at 1.0, secondaries at 0.3)
            let effectiveTagCount = Double(exercise.tags.count) +
                                    Double(exercise.secondaryTags.count) * secondaryWeight

            let baseWeightPerTag = setCount / effectiveTagCount

            // Primary tags at full weight
            for tag in exercise.tags {
                tagWeights[tag, default: 0] += baseWeightPerTag
            }

            // Secondary tags at reduced weight
            for tag in exercise.secondaryTags {
                tagWeights[tag, default: 0] += baseWeightPerTag * secondaryWeight
            }
        }

        guard totalSets > 0 else { return [] }

        // Convert to percentages
        return tagWeights
            .map { (tag: $0.key, percentage: ($0.value / totalSets) * 100) }
            .sorted { $0.percentage > $1.percentage }
    }

    /// Calculate tag distribution percentages for a given set of exercises
    /// Weighted by set count: exercises with more sets contribute more to tag percentages
    /// - Parameter sets: Array of ExerciseSets to analyze
    /// - Returns: Sorted array of (tag, percentage) tuples
    static func tagDistribution(from sets: [ExerciseSet]) -> [(tag: String, percentage: Double)] {
        // Count sets per exercise and collect exercises with tags
        var setCountByExercise: [PersistentIdentifier: Int] = [:]
        var exercisesByID: [PersistentIdentifier: Exercise] = [:]

        for set in sets {
            guard let exercise = set.exercise, !exercise.tags.isEmpty else { continue }
            let id = exercise.persistentModelID
            setCountByExercise[id, default: 0] += 1
            exercisesByID[id] = exercise
        }

        guard !exercisesByID.isEmpty else { return [] }

        // Calculate tag weights (weighted by set count, split among tags)
        // Secondary tags are weighted at 33% of primary tags (1/3)
        let secondaryWeight = 0.33
        var tagWeights: [String: Double] = [:]
        var totalSets: Double = 0

        for (id, exercise) in exercisesByID {
            let setCount = Double(setCountByExercise[id] ?? 0)
            totalSets += setCount

            // Calculate effective tag count (primaries at 1.0, secondaries at 0.3)
            let effectiveTagCount = Double(exercise.tags.count) +
                                    Double(exercise.secondaryTags.count) * secondaryWeight

            let baseWeightPerTag = setCount / effectiveTagCount

            // Primary tags at full weight
            for tag in exercise.tags {
                tagWeights[tag, default: 0] += baseWeightPerTag
            }

            // Secondary tags at reduced weight
            for tag in exercise.secondaryTags {
                tagWeights[tag, default: 0] += baseWeightPerTag * secondaryWeight
            }
        }

        guard totalSets > 0 else { return [] }

        // Convert to percentages
        let distribution = tagWeights.map { tag, weight in
            (tag: tag, percentage: (weight / totalSets) * 100)
        }

        return distribution.sorted { $0.percentage > $1.percentage }
    }

    // MARK: - Tag Suggestions

    /// Curated list of muscle / body-part tags merged into autocomplete suggestions
    /// so brand-new users get useful suggestions before they've built up their own vocabulary.
    /// Stored lowercase to match the normalization in TagInputSection.addTag().
    /// Suggestion-only — these are NOT written to any Exercise, so they don't affect
    /// analytics, tag distribution, or search.
    static let defaultMuscleTags: [String] = [
        "chest", "upper chest", "lower chest", "inner chest",
        "delts", "front delts", "mid delts", "rear delts",
        "back", "lats", "upper back", "traps", "lower back",
        "biceps", "triceps", "forearms",
        "core", "abs", "upper abs", "lower abs", "obliques",
        "quads", "hamstrings", "glutes", "calves", "hip flexors", "adductors", "neck"
    ]

    /// Fetch all unique tags for autocomplete suggestions, sorted alphabetically.
    /// Combines primary + secondary tags from all existing exercises with the curated
    /// `defaultMuscleTags` list. Set-based union dedupes any overlap.
    static func allUniqueTags(context: ModelContext) -> [String] {
        let descriptor = FetchDescriptor<Exercise>()
        let exercises = (try? context.fetch(descriptor)) ?? []

        var allTags = Set<String>()
        for exercise in exercises {
            allTags.formUnion(exercise.tags)
            allTags.formUnion(exercise.secondaryTags)
        }
        allTags.formUnion(defaultMuscleTags)

        return allTags.sorted()
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
