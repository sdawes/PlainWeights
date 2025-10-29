//
//  ExerciseSet.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var timestamp: Date
    var weight: Double       // kg (or lbs) — Double is fine for 0.25 increments
    var reps: Int
    var isWarmUp: Bool = false       // flag to exclude from performance calculations
    var isDropSet: Bool = false      // flag to indicate drop set (included in performance calculations)
    var exercise: Exercise?  // parent (optional to handle cascade delete properly)

    init(timestamp: Date = .init(), weight: Double, reps: Int, isWarmUp: Bool = false, isDropSet: Bool = false, exercise: Exercise) {
        self.timestamp = timestamp
        self.weight = weight
        self.reps = reps
        self.isWarmUp = isWarmUp
        self.isDropSet = isDropSet
        self.exercise = exercise

        // Automatically update parent exercise's lastUpdated timestamp
        exercise.lastUpdated = timestamp
    }
}