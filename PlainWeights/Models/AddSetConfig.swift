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

    var id: String {
        switch self {
        case .empty: return "empty"
        case .previous: return "previous"
        }
    }

    var exercise: Exercise {
        switch self {
        case .empty(let exercise): return exercise
        case .previous(let exercise, _, _): return exercise
        }
    }

    var initialWeight: Double? {
        switch self {
        case .empty: return nil
        case .previous(_, let weight, _): return weight
        }
    }

    var initialReps: Int? {
        switch self {
        case .empty: return nil
        case .previous(_, _, let reps): return reps
        }
    }
}
