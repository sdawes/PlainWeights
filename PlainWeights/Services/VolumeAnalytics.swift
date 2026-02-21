//
//  VolumeAnalytics.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation
import SwiftData

/// Service for calculating volume-related metrics for exercises
enum VolumeAnalytics {

    // MARK: - Volume Calculations

    /// Calculate volume for a specific set of exercise sets (excludes warm-up sets)
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        sets.workingSets.reduce(0) { $0 + $1.weight * Double($1.reps) }
    }

    // MARK: - Progress Calculations

    /// Calculate unclamped progress ratio (can exceed 1.0)
    static func progressRatioUnclamped(todayVolume: Double, lastCompletedVolume: Double?) -> Double {
        let lastVolume = lastCompletedVolume ?? 0
        if lastVolume == 0 {
            return todayVolume > 0 ? 1.0 : 0.0
        }
        return todayVolume / lastVolume
    }

    /// Calculate progress ratio clamped to 1.0 for progress bar display
    static func progressBarRatio(todayVolume: Double, lastCompletedVolume: Double?) -> Double {
        let unclamped = progressRatioUnclamped(todayVolume: todayVolume, lastCompletedVolume: lastCompletedVolume)
        return min(unclamped, 1.0)
    }

    /// Calculate percentage of last day's volume (can exceed 100%)
    static func percentOfLast(todayVolume: Double, lastCompletedVolume: Double?) -> Int {
        let ratio = progressRatioUnclamped(todayVolume: todayVolume, lastCompletedVolume: lastCompletedVolume)
        return Int(round(ratio * 100))
    }

    /// Calculate gains percentage compared to last completed day
    static func gainsPercent(todayVolume: Double, lastCompletedVolume: Double?) -> Int {
        let lastVolume = lastCompletedVolume ?? 0
        if lastVolume == 0 {
            return todayVolume > 0 ? 100 : 0
        }
        let gain = (todayVolume - lastVolume) / lastVolume * 100
        return Int(round(gain))
    }
}
