//
//  Exercise.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 16/08/2025.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var category: String
    var createdDate: Date

    // Inverse to the child relationship; cascade so sets are removed with the exercise
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet] = []

    init(name: String, category: String, createdDate: Date = .init()) {
        self.name = name
        self.category = category
        self.createdDate = createdDate
    }
}