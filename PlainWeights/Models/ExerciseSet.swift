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
    var exercise: Exercise   // parent (non-optional - sets always belong to an exercise)

    init(timestamp: Date = .init(), weight: Double, reps: Int, exercise: Exercise) {
        self.timestamp = timestamp
        self.weight = weight
        self.reps = reps
        self.exercise = exercise
        
        // Automatically update parent exercise's lastUpdated timestamp
        exercise.lastUpdated = timestamp
    }
}