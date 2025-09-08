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
    
    /// Calculate total volume for sets from today
    static func todayVolume(from sets: [ExerciseSet]) -> Double {
        let todaySets = todaySets(from: sets)
        return todaySets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    /// Get all sets from today
    static func todaySets(from sets: [ExerciseSet]) -> [ExerciseSet] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sets.filter { calendar.startOfDay(for: $0.timestamp) == today }
    }
    
    /// Get information about the last completed day (before today)
    static func lastCompletedDayInfo(from sets: [ExerciseSet]) -> (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int)? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group sets by day
        let setsByDay = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        
        // Find the most recent day before today with sets
        let pastDays = setsByDay.keys.filter { $0 < today }.sorted(by: >)
        
        guard let lastDay = pastDays.first,
              let lastDaySets = setsByDay[lastDay] else {
            return nil
        }
        
        let volume = lastDaySets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        let maxWeight = lastDaySets.map { $0.weight }.max() ?? 0
        
        // Find reps corresponding to max weight (most recent if multiple)
        let maxWeightSet = lastDaySets
            .filter { $0.weight == maxWeight }
            .sorted { $0.timestamp > $1.timestamp }
            .first
        let maxWeightReps = maxWeightSet?.reps ?? 0
        
        return (lastDay, volume, maxWeight, maxWeightReps)
    }
    
    /// Calculate volume for a specific set of exercise sets
    static func calculateVolume(for sets: [ExerciseSet]) -> Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    // MARK: - Progress Calculations
    
    /// Calculate unclamped progress ratio (can exceed 1.0)
    static func progressRatioUnclamped(todayVolume: Double, lastCompletedVolume: Double?) -> Double {
        guard let lastVolume = lastCompletedVolume, lastVolume > 0 else { return 0 }
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
        guard let lastVolume = lastCompletedVolume, lastVolume > 0 else { return 0 }
        let gain = (todayVolume - lastVolume) / lastVolume * 100
        return Int(round(gain))
    }
    
    // MARK: - Helper Functions
    
    /// Check if progress bar should be shown
    static func shouldShowProgressBar(lastCompletedVolume: Double?) -> Bool {
        guard let lastVolume = lastCompletedVolume else { return false }
        return lastVolume > 0
    }
}