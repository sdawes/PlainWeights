//
//  AddSetConfig.swift
//  PlainWeights
//
//  Created by Assistant on 2025-10-22.
//

import Foundation

enum AddSetConfig: Identifiable {
    case empty(exercise: Exercise)
    case previous(exercise: Exercise, weight: Double?, reps: Int?)
    case edit(set: ExerciseSet, exercise: Exercise)

    var id: String {
        switch self {
        case .empty: return "empty"
        case .previous: return "previous"
        case .edit(let set, _): return "edit-\(set.persistentModelID)"
        }
    }

    var exercise: Exercise {
        switch self {
        case .empty(let exercise): return exercise
        case .previous(let exercise, _, _): return exercise
        case .edit(_, let exercise): return exercise
        }
    }

    var initialWeight: Double? {
        switch self {
        case .empty: return nil
        case .previous(_, let weight, _): return weight
        case .edit(let set, _): return set.weight
        }
    }

    var initialReps: Int? {
        switch self {
        case .empty: return nil
        case .previous(_, _, let reps): return reps
        case .edit(let set, _): return set.reps
        }
    }

    var setToEdit: ExerciseSet? {
        switch self {
        case .edit(let set, _): return set
        default: return nil
        }
    }
}
