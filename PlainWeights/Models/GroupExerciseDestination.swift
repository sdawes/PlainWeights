//
//  GroupExerciseDestination.swift
//  PlainWeights
//
//  Navigation destination used when tapping an exercise inside a
//  GroupCard. Carries the group context so that sets logged during
//  the session are tagged back to this group.
//

import Foundation
import SwiftData

struct GroupExerciseDestination: Hashable {
    let exercise: Exercise
    let group: ExerciseGroup

    func hash(into hasher: inout Hasher) {
        hasher.combine(exercise.persistentModelID)
        hasher.combine(group.persistentModelID)
    }

    static func == (lhs: GroupExerciseDestination, rhs: GroupExerciseDestination) -> Bool {
        lhs.exercise.persistentModelID == rhs.exercise.persistentModelID &&
        lhs.group.persistentModelID == rhs.group.persistentModelID
    }
}
