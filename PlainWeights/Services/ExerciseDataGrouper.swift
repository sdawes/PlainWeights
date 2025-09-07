//
//  ExerciseDataGrouper.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation
import SwiftData

/// Service for grouping and organizing exercise data
enum ExerciseDataGrouper {
    
    // MARK: - Day Grouping
    
    /// Group exercise sets by day, sorted with most recent first
    static func groupSetsByDay(_ sets: [ExerciseSet]) -> [(Date, [ExerciseSet])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sets) { set in
            calendar.startOfDay(for: set.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }  // Most recent first
    }
    
    /// Group exercise sets by day with volume calculations
    static func groupSetsWithVolume(_ sets: [ExerciseSet]) -> [(date: Date, sets: [ExerciseSet], volume: Double)] {
        let dayGroups = groupSetsByDay(sets)
        return dayGroups.map { date, daySets in
            let volume = VolumeAnalytics.calculateVolume(for: daySets)
            return (date: date, sets: daySets, volume: volume)
        }
    }
    
    // MARK: - Future Expansion
    
    /// Potential future grouping by week
    static func groupSetsByWeek(_ sets: [ExerciseSet]) -> [(Date, [ExerciseSet])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sets) { set in
            calendar.dateInterval(of: .weekOfYear, for: set.timestamp)?.start ?? set.timestamp
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    /// Potential future grouping by month  
    static func groupSetsByMonth(_ sets: [ExerciseSet]) -> [(Date, [ExerciseSet])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sets) { set in
            calendar.dateInterval(of: .month, for: set.timestamp)?.start ?? set.timestamp
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - Helper Types
    
    /// Represents a day group with metadata
    struct DayGroup {
        let date: Date
        let sets: [ExerciseSet]
        let volume: Double
        let firstSetID: PersistentIdentifier?
        let lastSetID: PersistentIdentifier?
        
        init(date: Date, sets: [ExerciseSet]) {
            self.date = date
            self.sets = sets
            self.volume = VolumeAnalytics.calculateVolume(for: sets)
            self.firstSetID = sets.first?.persistentModelID
            self.lastSetID = sets.last?.persistentModelID
        }
        
        /// Check if a set is the first in this day group
        func isFirst(_ set: ExerciseSet) -> Bool {
            set.persistentModelID == firstSetID
        }
        
        /// Check if a set is the last in this day group
        func isLast(_ set: ExerciseSet) -> Bool {
            set.persistentModelID == lastSetID
        }
    }
    
    /// Create structured day groups with metadata
    static func createDayGroups(from sets: [ExerciseSet]) -> [DayGroup] {
        let dayGroups = groupSetsByDay(sets)
        return dayGroups.map { date, daySets in
            // Defensive sorting: ensure within-group ordering regardless of input
            let sortedSets = daySets.sorted { $0.timestamp > $1.timestamp }
            return DayGroup(date: date, sets: sortedSets)
        }
    }
}