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
    // All properties have defaults for CloudKit compatibility
    // Note: #Index on timestamp would improve query performance but requires iOS 18+
    var timestamp: Date = Date()
    var weight: Double = 0   // kg (or lbs) — Double is fine for 0.25 increments
    var reps: Int = 0
    var isWarmUp: Bool = false       // flag to exclude from performance calculations
    var isBonus: Bool = false        // flag for bonus/extra sets excluded from metrics (like warm-up)
    var isDropSet: Bool = false      // flag to indicate drop set (included in performance calculations)
    var isAssisted: Bool = false     // flag to indicate assisted set (e.g., spotter help)
    var isPauseAtTop: Bool = false   // flag to indicate pause at top technique
    var isTimedSet: Bool = false     // flag to indicate timed/tempo set (slow controlled movement)
    var tempoSeconds: Int = 0        // tempo duration in seconds (only used when isTimedSet is true)
    var isPB: Bool = false           // flag to indicate personal best (highest weight, then reps, then earliest timestamp)
    var restSeconds: Int?            // seconds rested after this set (nil for first set or not yet captured)
    var exercise: Exercise?  // parent (optional to handle cascade delete properly)

    init(timestamp: Date = .init(), weight: Double, reps: Int, isWarmUp: Bool = false, isBonus: Bool = false, isDropSet: Bool = false, isAssisted: Bool = false, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false, exercise: Exercise) {
        self.timestamp = timestamp
        self.weight = weight
        self.reps = reps
        self.isWarmUp = isWarmUp
        self.isBonus = isBonus
        self.isDropSet = isDropSet
        self.isAssisted = isAssisted
        self.isPauseAtTop = isPauseAtTop
        self.isTimedSet = isTimedSet
        self.tempoSeconds = tempoSeconds
        self.isPB = isPB
        self.exercise = exercise

        // Automatically update parent exercise's lastUpdated timestamp
        exercise.lastUpdated = timestamp
    }
}

// MARK: - Array Extension for Working Sets

extension Array where Element == ExerciseSet {
    /// Working sets are sets that count towards metrics (excludes warm-up and bonus sets)
    var workingSets: [ExerciseSet] {
        filter { !$0.isWarmUp && !$0.isBonus }
    }
}

// MARK: - Set Type Color Extension

import SwiftUI

extension ExerciseSet {
    /// Color associated with the set type (nil for normal working sets)
    /// Colors are defined in AppTheme as the single source of truth
    var setTypeColor: Color? {
        if isWarmUp { return AppTheme.warmUpColor }
        if isBonus { return AppTheme.bonusColor }
        if isDropSet { return AppTheme.dropSetColor }
        if isAssisted { return AppTheme.assistedColor }
        if isTimedSet { return AppTheme.timedSetColor }
        if isPauseAtTop { return AppTheme.pauseAtTopColor }
        return nil
    }
}