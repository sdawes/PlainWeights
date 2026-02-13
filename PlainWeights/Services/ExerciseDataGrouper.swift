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
        let calendar = Calendar.current
        
        // Group by day in a single pass
        var dayGroups: [Date: [ExerciseSet]] = [:]
        dayGroups.reserveCapacity(sets.count / 10) // Estimate capacity
        
        for set in sets {
            let day = calendar.startOfDay(for: set.timestamp)
            dayGroups[day, default: []].append(set)
        }
        
        // Sort each day's sets and create DayGroup objects
        return dayGroups.map { date, daySets in
            let sortedSets = daySets.sorted { $0.timestamp > $1.timestamp }
            return DayGroup(date: date, sets: sortedSets)
        }.sorted { $0.date > $1.date }  // Most recent first
    }

    /// Separate today's sets from historic sets for better UX during active workouts
    static func separateTodayFromHistoric(sets: [ExerciseSet]) -> (todaySets: [ExerciseSet], historicGroups: [DayGroup]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Split and group in a single pass
        var todaySets: [ExerciseSet] = []
        var historicGroups: [Date: [ExerciseSet]] = [:]
        
        todaySets.reserveCapacity(20) // Typical workout size
        historicGroups.reserveCapacity(sets.count / 10)

        for set in sets {
            let setDay = calendar.startOfDay(for: set.timestamp)
            if setDay == today {
                todaySets.append(set)
            } else {
                historicGroups[setDay, default: []].append(set)
            }
        }

        // Sort today's sets
        todaySets.sort { $0.timestamp > $1.timestamp }

        // Create day groups for historic sets
        let historicDayGroups = historicGroups.map { date, daySets in
            let sortedSets = daySets.sorted { $0.timestamp > $1.timestamp }
            return DayGroup(date: date, sets: sortedSets)
        }.sorted { $0.date > $1.date }

        return (todaySets: todaySets, historicGroups: historicDayGroups)
    }

    // MARK: - Workout Journal Grouping

    /// Represents a single exercise's work within a day for the workout journal
    struct WorkoutExercise: Identifiable {
        let id: PersistentIdentifier
        let exercise: Exercise
        let sets: [ExerciseSet]
        let setCount: Int
        let volume: Double

        init?(from sets: [ExerciseSet]) {
            guard let exercise = sets.first?.exercise else { return nil }

            self.id = exercise.persistentModelID
            self.exercise = exercise
            self.sets = sets.sorted { $0.timestamp > $1.timestamp }
            self.setCount = sets.count
            self.volume = VolumeAnalytics.calculateVolume(for: sets)
        }
    }

    /// Represents a workout day for the journal view
    struct WorkoutDay {
        let date: Date
        let exercises: [WorkoutExercise]
        let totalVolume: Double
        let exerciseCount: Int
        let totalSets: Int
    }

    /// Create workout journal groups from sets
    /// Groups sets by day, then by exercise within each day
    /// - Parameter sets: Exercise sets to group (should be pre-sorted newest first)
    /// - Returns: Array of WorkoutDay objects, newest day first
    static func createWorkoutJournal(from sets: [ExerciseSet]) -> [WorkoutDay] {
        // First group by day
        let dayGroups = createDayGroups(from: sets)

        // Transform each day into a WorkoutDay
        return dayGroups.map { dayGroup in
            // Group this day's sets by exercise
            let setsByExercise = Dictionary(grouping: dayGroup.sets) {
                $0.exercise?.persistentModelID
            }

            // Create WorkoutExercise for each exercise
            var exercises: [WorkoutExercise] = []
            exercises.reserveCapacity(setsByExercise.count)

            for (_, exerciseSets) in setsByExercise {
                if let workoutExercise = WorkoutExercise(from: exerciseSets) {
                    exercises.append(workoutExercise)
                }
            }

            // Sort exercises: most recent set first, then alphabetically
            exercises.sort { a, b in
                let aTime = a.sets.first?.timestamp ?? .distantPast
                let bTime = b.sets.first?.timestamp ?? .distantPast
                if aTime != bTime { return aTime > bTime }
                return a.exercise.name.localizedCaseInsensitiveCompare(b.exercise.name) == .orderedAscending
            }

            return WorkoutDay(
                date: dayGroup.date,
                exercises: exercises,
                totalVolume: dayGroup.volume,
                exerciseCount: exercises.count,
                totalSets: dayGroup.sets.count
            )
        }
    }
}
