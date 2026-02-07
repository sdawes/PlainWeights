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
    // All properties have defaults for CloudKit compatibility
    var name: String = ""
    var tags: [String] = []
    /// Searchable string of all tags joined by spaces (for SwiftData predicate queries)
    var tagsSearchable: String = ""
    var createdDate: Date = Date()
    var lastUpdated: Date = Date()
    var note: String?

    // Inverse to the child relationship; cascade so sets are removed with the exercise
    // Optional for CloudKit compatibility
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet]? = []

    init(name: String, tags: [String] = [], note: String? = nil, createdDate: Date = .init()) {
        self.name = name
        self.tags = tags
        self.tagsSearchable = tags.joined(separator: " ")
        self.note = note
        self.createdDate = createdDate
        self.lastUpdated = createdDate // Initialize with creation date
    }

    /// Update tags and keep searchable string in sync
    func setTags(_ newTags: [String]) {
        tags = newTags
        tagsSearchable = newTags.joined(separator: " ")
    }
}

extension Exercise {
    func bumpUpdated() {
        lastUpdated = Date()
    }
}