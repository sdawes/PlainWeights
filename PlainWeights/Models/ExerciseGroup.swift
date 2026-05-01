//
//  ExerciseGroup.swift
//  PlainWeights
//
//  A named, ordered collection of Exercises the user can save and reuse
//  (e.g. "Leg Day", "Hardship Day"). The relationship to Exercise is
//  many-to-many: a single Exercise (e.g. "Bench Press") can appear in
//  multiple groups without duplicating its data — sets, PBs and history
//  all stay attached to the one Exercise.
//

import Foundation
import SwiftData

@Model
final class ExerciseGroup {
    // All properties have defaults for CloudKit compatibility.
    var id: UUID = UUID()
    var name: String = ""
    var createdDate: Date = Date()
    /// Bumped when the user opens / "uses" this group; used later to
    /// surface recently-used groups at the top of the Groups list.
    var lastUsedDate: Date?

    /// Many-to-many relationship to Exercise. Optional for CloudKit
    /// compatibility. The inverse is declared on Exercise.
    @Relationship var exercises: [Exercise]? = []

    init(name: String, exercises: [Exercise] = [], createdDate: Date = .init()) {
        self.name = name
        self.exercises = exercises
        self.createdDate = createdDate
    }
}
