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
    var isWarmUp: Bool       // flag to exclude from performance calculations
    var exercise: Exercise?  // parent (optional to handle cascade delete properly)

    init(timestamp: Date = .init(), weight: Double, reps: Int, isWarmUp: Bool = false, exercise: Exercise) {
        self.timestamp = timestamp
        self.weight = weight
        self.reps = reps
        self.isWarmUp = isWarmUp
        self.exercise = exercise

        // Automatically update parent exercise's lastUpdated timestamp
        exercise.lastUpdated = timestamp
    }
}