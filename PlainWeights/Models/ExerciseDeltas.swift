//
//  ExerciseDeltas.swift
//  PlainWeights
//
//  Data types for tracking exercise metric changes between sessions.
//

import SwiftUI

/// Change direction for a metric: up, down, or same
enum DeltaDirection {
    case up, down, same, noData

    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .same: return Color(red: 1.0, green: 0.75, blue: 0.0) // True amber #FFBF00
        case .noData: return .gray.opacity(0.3)
        }
    }
}

/// Deltas for an exercise compared to previous session
struct ExerciseDeltas {
    let weight: DeltaDirection
    let reps: DeltaDirection
    let volume: DeltaDirection

    static let empty = ExerciseDeltas(weight: .noData, reps: .noData, volume: .noData)
}
