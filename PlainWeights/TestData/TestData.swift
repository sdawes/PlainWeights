// COPY FROM HERE ========================================================

//
//  TestData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//  Last Updated: 27 Nov 2025 at 15:39:31
//
//  Real Gym Data
//  59 exercises, 47 workout sessions (22 Sep 2025 - 25 Nov 2025)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData")
        logger.info("Generating test data (Real gym data - 59 exercises, 47 sessions)...")

        // Clear existing data
        clearAllData(modelContext: modelContext)

        generateGymData(modelContext: modelContext)
        logger.info("Test Data Set 4 generation completed")
    }

    // MARK: - Data Generation

    private static func generateGymData(modelContext: ModelContext) {
        // EXPORT DATE: 27 Nov 2025 at 15:39:31

        // Exercise definitions with notes and timestamps
        let exerciseData: [(name: String, category: String, note: String?, createdDate: Date, lastUpdated: Date)] = [
    (name: "Dumbbell lateral raises", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 18, 17, 30, 15)),
    (name: "Press-ups", category: "Chest", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 1, 9, 52, 25)),
    (name: "Landmine Row", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 23, 19, 26, 42)),
    (name: "Romanian deadlift ", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 9, 15, 52, 38)),
    (name: "Dumbbell flys", category: "Chest ", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 9, 27, 17, 12, 57)),
    (name: "Tricep Dips", category: "Triceps", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 16, 9, 52)),
    (name: "Chest press machine", category: "Chest", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 17, 13, 31, 21)),
    (name: "Incline chest press machine", category: "Chest", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 15, 55, 13)),
    (name: "Leg press", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 16, 56, 41)),
    (name: "T Bar Row", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 27, 15, 37, 32)),
    (name: "Seated cable row", category: "Back", note: "8 is 54kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 4, 10, 21, 42)),
    (name: "Seated dumbbell Arnold press", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 29, 17, 25, 39)),
    (name: "Dumbbell shoulder shrugs", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 1, 20, 50, 58)),
    (name: "Seated Incline Dumbell Curls", category: "Bicep", note: "Bench number 5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 18, 12, 9)),
    (name: "Rope Face Pulls", category: "Back", note: "8 is 45kg, 9 is 50.5kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 18, 1, 15)),
    (name: "Reverse dumbbell flys", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 21, 57, 14)),
    (name: "Pull ups", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 17, 35, 36)),
    (name: "Single cable lateral raise", category: "Shoulders", note: "2 - 15kg, 3 - 17.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 16, 21, 43)),
    (name: "Toes to bar", category: "Core", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 9, 16, 37, 31)),
    (name: "Seated tricep dips", category: "Tricep", note: "With bench level box full out", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 17, 58, 47)),
    (name: "Dumbbell shoulder press", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 16, 27, 10)),
    (name: "Seated dumbbell curl (on knee)", category: "Bicep", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 17, 58, 15)),
    (name: "Dumbbell split squats", category: "Legs", note: "Number of reps done on one side logged", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 23, 28)),
    (name: "Leg Raises", category: "Legs", note: "6 is 43kg, 7 is 48.5, 8 is 54, 9 is 59.5, 10 is 65", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 36, 49)),
    (name: "Butterfly sit up", category: "Core", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 21, 57, 4)),
    (name: "Hamstring Curls", category: "Legs", note: "4 is 32kg, 5 is 37.5, 6 is 43kg, 7 is 48.5kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 8, 57)),
    (name: "Lat pull down", category: "Back", note: "9 - 59.5kg, 10 - 65kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 10, 18, 11, 44)),
    (name: "Upright cable row", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 9, 26, 16, 55, 28)),
    (name: "Front lateral dumbbell raise", category: "Shoulder", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 29, 17, 36, 55)),
    (name: "Knees to toe", category: "Core", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 18, 19, 20)),
    (name: "Chest Press", category: "Chest", note: "What can I say about a chest press??", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 15, 43, 21)),
    (name: "Barbell Lunges", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 9, 30, 17, 7, 30)),
    (name: "Tricep rope pushdown", category: "Triceps", note: "7 - 39.5, , 8 - 45", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 16, 35, 35)),
    (name: "Box jumps", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 47, 13)),
    (name: "Front lateral cable raise", category: "Shoulders", note: "3 is 17.5, 4 23 and 5 28.5, 2 handed pull", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 17, 36, 47)),
    (name: "Dumbbell chest press", category: "Chest", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 18, 17, 15, 24)),
    (name: "Overhead Tricep Rope Pulls", category: "Triceps", note: "7 is 39.5 and 8 is 45", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 18, 10, 52, 2)),
    (name: "Sled Push", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 6, 17, 6, 21)),
    (name: "Calf Raises", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 31, 9)),
    (name: "Landmine Shoulder Press", category: "Shoulder ", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 23, 19, 18, 45)),
    (name: "Incline Dumbbell Chest Press", category: "Chest", note: "Include the raise as one", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 18, 17, 6, 35)),
    (name: "Ball tricep pushdown", category: "Tricep", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 29, 17, 43, 1)),
    (name: "Standing dumbbell hammer curls", category: "Bicep", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 21, 17, 53, 6)),
    (name: "Hyper extensions", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 28, 17, 47, 19)),
    (name: "Reverse Cable Flys", category: "Back", note: "2 15 and 3 17.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 17, 49, 37)),
    (name: "Straight arm cable pulldown", category: "Back", note: "8 is 45kg 9 is 50.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 22, 15, 30, 32)),
    (name: "Shoulder press machine ", category: "Shoulders", note: "4 - 32kg, 5 - 37.5, 6 - 43kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 17, 14, 33)),
    (name: "Barbell squat", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 20, 16, 25, 1)),
    (name: "EZ bar curl", category: "Biceps", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 3, 17, 38, 25)),
    (name: "Chest Cable Flys", category: "Chest", note: "3 is 17.5 and 4 is 23", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 23, 16, 13, 10)),
    (name: "Bicep rope curls", category: "Bicep", note: "8 is 45kg, , 9 is 50.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 24, 17, 55, 57)),
    (name: "Deadlifts (Trapbar)", category: "Back", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 19, 32, 36)),
    (name: "Dumbbell hammer curls ", category: "Bicep", note: "Single arm raises each count as one rep.", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 19, 17, 20, 39)),
    (name: "Cable chest flys mid", category: "Chest", note: "6 holes from the top", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 1, 9, 17, 4)),
    (name: "Dumbbell lunges", category: "Legs", note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 21, 23, 51, 8)),
    (name: "Single arm back pull machine", category: "Back", note: nil as String?, createdDate: date(2025, 11, 9, 16, 6, 34), lastUpdated: date(2025, 11, 9, 16, 14, 21)),
    (name: "Barbell shoulder press", category: "Shoulders", note: nil as String?, createdDate: date(2025, 11, 10, 18, 2, 11), lastUpdated: date(2025, 11, 10, 18, 7, 4)),
    (name: "Deadlifts", category: "Back", note: nil as String?, createdDate: date(2025, 11, 20, 16, 25, 23), lastUpdated: date(2025, 11, 20, 16, 33, 10)),
    (name: "Dumbbell Romanian deadlift", category: "Hamstring Legs", note: nil as String?, createdDate: date(2025, 11, 25, 17, 12, 23), lastUpdated: date(2025, 11, 25, 17, 15, 42)),
        ]

        // Create exercises
        var exercises: [String: Exercise] = [:]
        for data in exerciseData {
            let exercise = Exercise(name: data.name, category: data.category, note: data.note, createdDate: data.createdDate)
            exercise.lastUpdated = data.lastUpdated
            exercises[data.name] = exercise
            modelContext.insert(exercise)
        }

        // Helper function to create timestamps
        func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = hour
            components.minute = minute
            components.second = second
            return Calendar.current.date(from: components)!
        }

        // Helper function to add a working set
        func addSet(exercise: String, weight: Double, reps: Int, timestamp: Date, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            modelContext.insert(set)
        }

        // Helper function to add a warm-up set
        func addWarmUpSet(exercise: String, weight: Double, reps: Int, timestamp: Date, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: true, isDropSet: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: false, exercise: ex)
            modelContext.insert(set)
        }

        // Helper function to add a drop set
        func addDropSet(exercise: String, weight: Double, reps: Int, timestamp: Date, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: true, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            modelContext.insert(set)
        }

        // SESSION 1: 2025-09-22 17:00:00
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 0, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 3, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0))
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 10, 0))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 13, 0))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 15, 0))
        // Chest Cable Flys: 3 sets
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 17, 0))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 20, 0))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 23, 0))
        // Tricep Dips: 3 sets
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 25, 0))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 30, 0))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 33, 0))
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 35, 0))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 37, 0))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 40, 0))
        // Barbell squat: 3 sets
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 0, 0))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 3, 0))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 5, 0))
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 6, 0), isPB: true)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 9, 0))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 12, 0))
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 24, 0))
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 26, 0))
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 30, 0))
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 32, 0))
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 35, 0))
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 38, 0))
        // Calf Raises: 3 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 40, 0))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 43, 0))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 45, 0))

        // SESSION 2: 2025-09-24 17:03:30
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 3, 30))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 7, 0))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 9, 0))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 11, 0))
        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 14, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 16, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 18, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 20, 0))
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 22, 30))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 25, 0))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 27, 30))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 30, 0))
        // Rope Face Pulls: 3 sets
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 32, 30))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 34, 30))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 36, 30))
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 39, 0))
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 41, 30))
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 44, 0))
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 46, 30))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 49, 0))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 51, 30))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 54, 0))
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 47, 30))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 48, 30))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 49, 30))

        // SESSION 3: 2025-09-25 16:57:05
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 25, 16, 57, 5))
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 13, timestamp: date(2025, 9, 25, 16, 58, 2))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 0, 9))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 1, 32))
        // Hamstring Curls: 1 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 25, 17, 4, 30))
        // Calf Raises: 2 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 9, 25, 17, 7, 26))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 9, 25, 17, 8, 47))
        // Barbell squat: 5 sets
        addWarmUpSet(exercise: "Barbell squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 25, 17, 13, 4))
        addSet(exercise: "Barbell squat", weight: 40.0, reps: 8, timestamp: date(2025, 9, 25, 17, 15, 31))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 39))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 44))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 21, 54))
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 25, 36))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 28, 6))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 32, 50))
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 11, timestamp: date(2025, 9, 25, 17, 41, 22))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 25, 17, 42, 28))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 12, timestamp: date(2025, 9, 25, 17, 46, 16))
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 48, 31))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 49, 56))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 9, timestamp: date(2025, 9, 25, 17, 52, 8))

        // SESSION 4: 2025-09-26 16:16:57
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 12, timestamp: date(2025, 9, 26, 16, 16, 57))
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 13, timestamp: date(2025, 9, 26, 16, 19, 9))
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 15, timestamp: date(2025, 9, 26, 16, 22, 17))
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 9, 26, 16, 25, 12))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 27, 22))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 30, 22))
        // Front lateral cable raise: 3 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 12, timestamp: date(2025, 9, 26, 16, 34, 9))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 35, 47))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 37, 55))
        // Seated dumbbell Arnold press: 4 sets
        addSet(exercise: "Seated dumbbell Arnold press", weight: 7.5, reps: 10, timestamp: date(2025, 9, 26, 16, 39, 59))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 41, 25))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 43, 45))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 12, timestamp: date(2025, 9, 26, 16, 47, 38))
        // Upright cable row: 3 sets
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 51, 18), isPB: true)
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 53, 44))
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 55, 28))
        // Butterfly sit up: 2 sets
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 57, 33), isPB: true)
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 59, 27))

        // SESSION 5: 2025-09-27 16:41:23
        // Chest Press: 6 sets
        addWarmUpSet(exercise: "Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 41, 23))
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 8, timestamp: date(2025, 9, 27, 16, 41, 36))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 5, timestamp: date(2025, 9, 27, 16, 44, 32))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 9, 27, 16, 46, 53))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 9, 27, 16, 49, 41), isPB: true)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 9, 27, 16, 52, 45))
        // Incline Dumbbell Chest Press: 4 sets
        addWarmUpSet(exercise: "Incline Dumbbell Chest Press", weight: 17.5, reps: 8, timestamp: date(2025, 9, 27, 16, 55, 12))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 56, 47))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 0, 12))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 3, 31))
        // Dumbbell flys: 3 sets
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 7, timestamp: date(2025, 9, 27, 17, 5, 27))
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 14, timestamp: date(2025, 9, 27, 17, 8, 59), isPB: true)
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 10, timestamp: date(2025, 9, 27, 17, 12, 57))
        // Tricep Dips: 4 sets
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 8, timestamp: date(2025, 9, 27, 17, 15, 10))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 17, 1))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 19, 23))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 21, 59))
        // Overhead Tricep Rope Pulls: 5 sets
        addWarmUpSet(exercise: "Overhead Tricep Rope Pulls", weight: 28.5, reps: 10, timestamp: date(2025, 9, 27, 17, 24, 57))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 12, timestamp: date(2025, 9, 27, 17, 27, 11))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 29, 38))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 6, timestamp: date(2025, 9, 27, 17, 31, 31))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 34, 3))

        // SESSION 6: 2025-09-29 17:06:07
        // Straight arm cable pulldown: 3 sets
        addSet(exercise: "Straight arm cable pulldown", weight: 45.0, reps: 13, timestamp: date(2025, 9, 29, 17, 6, 7))
        addSet(exercise: "Straight arm cable pulldown", weight: 47.5, reps: 12, timestamp: date(2025, 9, 29, 17, 8, 3))
        addSet(exercise: "Straight arm cable pulldown", weight: 47.5, reps: 10, timestamp: date(2025, 9, 29, 17, 10, 0))
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 9, timestamp: date(2025, 9, 29, 17, 11, 39))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 9, timestamp: date(2025, 9, 29, 17, 13, 40))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 15, 59))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 18, 59))
        // Reverse dumbbell flys: 2 sets
        addSet(exercise: "Reverse dumbbell flys", weight: 10.0, reps: 12, timestamp: date(2025, 9, 29, 17, 23, 8))
        addSet(exercise: "Reverse dumbbell flys", weight: 12.0, reps: 12, timestamp: date(2025, 9, 29, 17, 24, 57), isPB: true)
        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 30, 21))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 29, 17, 32, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 35, 9))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 38, 39))
        // Bicep rope curls: 4 sets
        addWarmUpSet(exercise: "Bicep rope curls", weight: 42.0, reps: 14, timestamp: date(2025, 9, 29, 17, 40, 14))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 41, 54))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 43, 4))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 45, 12))

        // SESSION 7: 2025-09-29 20:51:28
        // Reverse dumbbell flys: 1 sets
        addSet(exercise: "Reverse dumbbell flys", weight: 10.0, reps: 15, timestamp: date(2025, 9, 29, 20, 51, 28))

        // SESSION 8: 2025-09-30 16:48:49
        // Barbell squat: 5 sets
        addWarmUpSet(exercise: "Barbell squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 30, 16, 48, 49))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 51, 24))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 54, 4))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 56, 13))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 58, 25))
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 0, 30))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 4, 10))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 7, 30))
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 30, 17, 11, 9))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 30, 17, 12, 28))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 16, timestamp: date(2025, 9, 30, 17, 14, 0))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 15, 31))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 17, 23))
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 37.5, reps: 11, timestamp: date(2025, 9, 30, 17, 19, 5))
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 30, 17, 20, 2))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 8, timestamp: date(2025, 9, 30, 17, 21, 33))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 30, 17, 23, 15))
        // Calf Raises: 3 sets
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 25, 5))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 26, 46))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 28, 16))

        // SESSION 9: 2025-10-01 20:19:17
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 19, 17))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 1, 20, 21, 22))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 25, 30))
        // Dumbbell shoulder press: 2 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 27, 20))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 30, 46))
        // Single cable lateral raise: 3 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 1, 20, 37, 12))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 38, 10))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 40, 23))
        // Dumbbell shoulder shrugs: 1 sets
        addSet(exercise: "Dumbbell shoulder shrugs", weight: 22.5, reps: 12, timestamp: date(2025, 10, 1, 20, 50, 58), isPB: true)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 56, 5))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 58, 31))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 0, 55))
        // Hyper extensions: 3 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 9, 45))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 11, 10))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 13, 8))

        // SESSION 10: 2025-10-02 16:12:52
        // Chest Press: 5 sets
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 9, timestamp: date(2025, 10, 2, 16, 12, 52))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 14, 54))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 17, 30))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 10, 2, 16, 19, 59))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 22, 51))
        // Incline chest press machine: 2 sets
        addWarmUpSet(exercise: "Incline chest press machine", weight: 20.0, reps: 10, timestamp: date(2025, 10, 2, 16, 25, 59))
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 8, timestamp: date(2025, 10, 2, 16, 28, 18))
        // Chest Cable Flys: 4 sets
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 2, 16, 35, 43))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 37, 38))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 39, 24))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 40, 55))
        // Incline chest press machine: 2 sets
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 8))
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 13))
        // Tricep Dips: 4 sets
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 8, timestamp: date(2025, 10, 2, 16, 45, 5))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 46, 50))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 50, 5))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 10, 2, 16, 52, 55))
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 2, 16, 57, 27))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 16, 59, 14), isPB: true)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 1, 16))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 3, 41))

        // SESSION 11: 2025-10-02 20:28:56
        // T Bar Row: 1 sets
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 20, 28, 56))

        // SESSION 12: 2025-10-04 10:08:18
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 9, timestamp: date(2025, 10, 4, 10, 8, 18))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 10, 4, 10, 11, 10))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 8, timestamp: date(2025, 10, 4, 10, 14, 34))
        // Seated cable row: 1 sets
        addSet(exercise: "Seated cable row", weight: 54.0, reps: 10, timestamp: date(2025, 10, 4, 10, 21, 42), isPB: true)
        // Deadlifts (Trapbar): 3 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 4, 10, 26, 16))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 28, 3))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 31, 47))
        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 10, 4, 10, 32, 58))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 35, 38))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 38, 16))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 6, timestamp: date(2025, 10, 4, 10, 39, 52))

        // SESSION 13: 2025-10-06 16:36:26
        // Leg press: 4 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2025, 10, 6, 16, 36, 26))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 38, 42))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 40, 44))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 43, 20))
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 37.5, reps: 15, timestamp: date(2025, 10, 6, 16, 48, 45))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 6, 16, 49, 49))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 6, 16, 52, 3))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 6, 16, 54, 52))
        // Sled Push: 4 sets
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 16, 58, 9), isPB: true)
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 0, 11))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 2, 56))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 6, 21))
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 6, 17, 8, 17))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 14, timestamp: date(2025, 10, 6, 17, 10, 46))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 14, timestamp: date(2025, 10, 6, 17, 13, 9))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 10, 6, 17, 15, 49))

        // SESSION 14: 2025-10-07 16:46:03
        // Dumbbell chest press: 4 sets
        addWarmUpSet(exercise: "Dumbbell chest press", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 16, 46, 3))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 47, 4))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 51, 9))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 53, 43))
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 8, timestamp: date(2025, 10, 7, 16, 55, 28))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 7, 16, 58, 34))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 10, 7, 17, 1, 58))
        // Dumbbell shoulder press: 3 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 4, 44))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 6, 31))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 11, 32))
        // Tricep Dips: 4 sets
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 7, timestamp: date(2025, 10, 7, 17, 11, 44))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 7, 17, 13, 12))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 15, 43))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 19, 19))
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 17, 22, 27))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 25, 36))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 26, 29))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 28, 51))
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 30, 18))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 32, 26))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 34, 27))
        // Chest Cable Flys: 3 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2025, 10, 7, 17, 38, 31))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 11, timestamp: date(2025, 10, 7, 17, 39, 39))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 7, 17, 42, 29))

        // SESSION 15: 2025-10-08 16:25:55
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 25, 55))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 26, 15))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 28, 7))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 31, 5))
        // T Bar Row: 4 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 10, timestamp: date(2025, 10, 8, 16, 34, 47))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 8, timestamp: date(2025, 10, 8, 16, 36, 23))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 10, timestamp: date(2025, 10, 8, 16, 39, 27))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 9, timestamp: date(2025, 10, 8, 16, 42, 42))
        // Reverse Cable Flys: 4 sets
        addWarmUpSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 13, timestamp: date(2025, 10, 8, 16, 45, 7))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 47, 50))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 50, 10))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 10, 8, 16, 52, 20))
        // Straight arm cable pulldown: 3 sets
        addSet(exercise: "Straight arm cable pulldown", weight: 45.0, reps: 14, timestamp: date(2025, 10, 8, 16, 54, 55))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 56, 31))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 58, 2))
        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 8, 16, 59, 49))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 1, 55))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 3, 54))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 7, 19))
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 8, 50))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 10, 5))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 8, 17, 11, 33))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 5, timestamp: date(2025, 10, 8, 18, 5, 41))

        // SESSION 16: 2025-10-09 21:27:42
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 9, 21, 27, 42))
        addSet(exercise: "Chest Cable Flys", weight: 22.0, reps: 14, timestamp: date(2025, 10, 9, 21, 28, 8))

        // SESSION 17: 2025-10-10 16:26:45
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 10, 16, 26, 45))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 10, 10, 16, 30, 50))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 33, 45))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 36, 25))
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 10, 16, 39, 58))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 10, 16, 43, 10))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 46, 8))
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 10, timestamp: date(2025, 10, 10, 16, 51, 26))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 10, timestamp: date(2025, 10, 10, 16, 51, 30))
        // Dumbbell lateral raises: 4 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 14, timestamp: date(2025, 10, 10, 16, 53, 22))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 10, 16, 55, 49))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 14, timestamp: date(2025, 10, 10, 16, 58, 13))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 11, timestamp: date(2025, 10, 10, 17, 1, 1))
        // Shoulder press machine : 4 sets
        addSet(exercise: "Shoulder press machine ", weight: 32.0, reps: 10, timestamp: date(2025, 10, 10, 17, 3, 54))
        addSet(exercise: "Shoulder press machine ", weight: 32.0, reps: 10, timestamp: date(2025, 10, 10, 17, 4, 56))
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 10, 17, 6, 45))
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 7, timestamp: date(2025, 10, 10, 17, 8, 38))
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 10, 10, 17, 10, 29))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 12, timestamp: date(2025, 10, 10, 17, 12, 5))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 10, 10, 17, 13, 44))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 10, 10, 17, 14, 51))
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 10, 17, 17, 57))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 10, 17, 19, 37))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 10, 17, 21, 26))

        // SESSION 18: 2025-10-11 08:37:00
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 11, 8, 37, 0))
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 37, 45))
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 40, 1))
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 41, 39))
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 15, timestamp: date(2025, 10, 11, 8, 44, 4))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 15, timestamp: date(2025, 10, 11, 8, 49, 52))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 15, timestamp: date(2025, 10, 11, 8, 49, 53))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 14, timestamp: date(2025, 10, 11, 8, 49, 56))
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 54.0, reps: 10, timestamp: date(2025, 10, 11, 8, 52, 4))
        addSet(exercise: "Lat pull down", weight: 54.0, reps: 10, timestamp: date(2025, 10, 11, 8, 54, 17))
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 7, timestamp: date(2025, 10, 11, 8, 56, 39))
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 10, 11, 8, 58, 56))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 8, timestamp: date(2025, 10, 11, 9, 1, 19))
        addSet(exercise: "T Bar Row", weight: 32.5, reps: 7, timestamp: date(2025, 10, 11, 9, 3, 27))
        addSet(exercise: "T Bar Row", weight: 32.5, reps: 10, timestamp: date(2025, 10, 11, 9, 6, 48))
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 8, timestamp: date(2025, 10, 11, 9, 9, 49))
        // Seated Incline Dumbell Curls: 3 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 10, 11, 9, 12, 53))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 10, 11, 9, 14, 45))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 11, 9, 19, 16))
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 11, 9, 20, 11))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 11, 9, 22, 57))

        // SESSION 19: 2025-10-13 19:10:59
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 20.0, reps: 14, timestamp: date(2025, 10, 13, 19, 10, 59))
        addSet(exercise: "Incline chest press machine", weight: 25.0, reps: 13, timestamp: date(2025, 10, 13, 19, 11, 10))
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 12, timestamp: date(2025, 10, 13, 19, 11, 19))
        addSet(exercise: "Incline chest press machine", weight: 35.0, reps: 10, timestamp: date(2025, 10, 13, 19, 11, 28))
        // Chest press machine: 4 sets
        addSet(exercise: "Chest press machine", weight: 35.0, reps: 12, timestamp: date(2025, 10, 13, 19, 13, 3))
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 13, 19, 15, 52))
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 10, timestamp: date(2025, 10, 13, 19, 18, 55))
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 13, 19, 21, 32))
        // Shoulder press machine : 3 sets
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 13, 19, 26, 2))
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 13, 19, 28, 16))
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 9, timestamp: date(2025, 10, 13, 19, 30, 52))
        // Single cable lateral raise: 2 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 13, 19, 33, 8))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 35, 13))
        // Front lateral cable raise: 2 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 35, 28))
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 38, 27))
        // Single cable lateral raise: 2 sets
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 38, 34))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 41, 7))
        // Front lateral cable raise: 1 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 41, 13))
        // Tricep Dips: 4 sets
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 8, timestamp: date(2025, 10, 13, 19, 44, 17))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 10, 13, 19, 45, 53))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 10, 13, 19, 48, 14))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 13, 19, 50, 56))

        // SESSION 20: 2025-10-15 11:33:50
        // Chest press machine: 2 sets
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 15, 11, 33, 50))
        addSet(exercise: "Chest press machine", weight: 55.0, reps: 13, timestamp: date(2025, 10, 15, 11, 34, 0))

        // SESSION 21: 2025-10-15 16:45:53
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 15, 16, 45, 53))
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2025, 10, 15, 16, 46, 35))
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 15, 16, 50, 27))
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 15, 16, 51, 9))
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 12, timestamp: date(2025, 10, 15, 16, 55, 41), isPB: true)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 15, 16, 56, 35))
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 12, timestamp: date(2025, 10, 15, 16, 58, 43))
        // Straight arm cable pulldown: 2 sets
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 11, timestamp: date(2025, 10, 15, 17, 2, 6))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 11, timestamp: date(2025, 10, 15, 17, 3, 54))
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 10, 15, 17, 4, 3))
        // T Bar Row: 4 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 10, timestamp: date(2025, 10, 15, 17, 8, 22))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 10, 15, 17, 10, 19))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 15, 17, 12, 54))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 7, timestamp: date(2025, 10, 15, 17, 15, 10))
        // Rope Face Pulls: 3 sets
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 15, 17, 17, 22))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 15, 17, 19, 14))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 15, 17, 21, 31))
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 15, 17, 22, 30))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 10, timestamp: date(2025, 10, 15, 17, 25, 31))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 10, 15, 17, 27, 12))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 10, timestamp: date(2025, 10, 15, 17, 29, 3))
        // Seated Incline Dumbell Curls: 3 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 15, 17, 31, 5))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 15, 17, 33, 8))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 15, 17, 35, 22))

        // SESSION 22: 2025-10-16 19:29:22
        // Leg press: 4 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 14, timestamp: date(2025, 10, 16, 19, 29, 22))
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 32, 38))
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 35, 17))
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 37, 50))
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 37.5, reps: 12, timestamp: date(2025, 10, 16, 19, 42, 0))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 11, timestamp: date(2025, 10, 16, 19, 44, 15))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 16, 19, 46, 39))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 9, timestamp: date(2025, 10, 16, 19, 50, 26))
        // Leg Raises: 4 sets
        addWarmUpSet(exercise: "Leg Raises", weight: 45.5, reps: 10, timestamp: date(2025, 10, 16, 19, 51, 52))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 9, timestamp: date(2025, 10, 16, 19, 52, 58))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 16, 19, 55, 26))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 16, 19, 57, 31))
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 16, 20, 2, 15))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 16, 20, 4, 37))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 67.5, reps: 10, timestamp: date(2025, 10, 16, 20, 8, 12))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 67.5, reps: 9, timestamp: date(2025, 10, 16, 20, 10, 35))
        // Dumbbell split squats: 3 sets
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 10, timestamp: date(2025, 10, 16, 20, 15, 24))
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 10, timestamp: date(2025, 10, 16, 20, 16, 47))
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 7, timestamp: date(2025, 10, 16, 20, 20, 34))
        // Calf Raises: 4 sets
        addWarmUpSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 16, 20, 21, 58))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 14, timestamp: date(2025, 10, 16, 20, 23, 15))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 13, timestamp: date(2025, 10, 16, 20, 25, 45))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 14, timestamp: date(2025, 10, 16, 20, 27, 31))
        // Hyper extensions: 2 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 16, 20, 29, 14))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 16, 20, 30, 13))

        // SESSION 23: 2025-10-17 13:31:15
        // Chest press machine: 3 sets
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 15), isPB: true)
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 18))
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 21))

        // SESSION 24: 2025-10-18 09:45:27
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 18, 9, 45, 27))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 18, 9, 47, 55))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 9, 55, 49))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 9, timestamp: date(2025, 10, 18, 9, 56, 37))
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 1, 58))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 5, 29))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 12, 10))
        // Dumbbell shoulder press: 3 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 10, 18, 10, 12, 28))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 18, 10, 19, 16))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 8, timestamp: date(2025, 10, 18, 10, 19, 20))
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2025, 10, 18, 10, 20, 34), isPB: true)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2025, 10, 18, 10, 22, 58))
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 10, 18, 10, 26, 44))
        // Tricep Dips: 3 sets
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 18, 10, 37, 37))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 10, 18, 10, 38, 25))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 10, 18, 10, 42, 2))
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 18, 10, 45, 15))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 18, 10, 50, 4))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 9, timestamp: date(2025, 10, 18, 10, 50, 7))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 7, timestamp: date(2025, 10, 18, 10, 52, 2))

        // SESSION 25: 2025-10-21 17:15:43
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 8, timestamp: date(2025, 10, 21, 17, 15, 43))
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 21, 17, 17, 27))
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 21, 17, 20, 4))
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 21, 17, 22, 16))
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 9, timestamp: date(2025, 10, 21, 17, 25, 14))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 30, 18))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 30, 21))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 32, 49))
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 9, timestamp: date(2025, 10, 21, 17, 35, 47))
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 9, timestamp: date(2025, 10, 21, 17, 38, 2))
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 7, timestamp: date(2025, 10, 21, 17, 40, 30))
        // Standing dumbbell hammer curls: 3 sets
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 20, timestamp: date(2025, 10, 21, 17, 48, 55), isPB: true)
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 18, timestamp: date(2025, 10, 21, 17, 50, 35))
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 20, timestamp: date(2025, 10, 21, 17, 53, 6))
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 54, 27))
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 56, 11))
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 57, 51))
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 2, 47))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 5, 28))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 7, 15))

        // SESSION 26: 2025-10-22 19:32:22
        // Hamstring Curls: 4 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 22, 19, 32, 22))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 22, 19, 34, 23))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 6, timestamp: date(2025, 10, 22, 19, 36, 21))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 5, timestamp: date(2025, 10, 22, 19, 36, 55))
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 22, 19, 39, 55))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 22, 19, 41, 23))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 22, 19, 43, 33))
        // Tricep Dips: 4 sets
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 10, 22, 19, 48, 13))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 10, 22, 19, 50, 13))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 22, 19, 53, 3))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 22, 19, 55, 26))
        // Incline chest press machine: 3 sets
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 10, 22, 19, 59, 16))
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 22, 20, 1, 25))
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 10, 22, 20, 3, 34))
        // T Bar Row: 5 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 12, timestamp: date(2025, 10, 22, 20, 5, 56))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 22, 20, 8, 13))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 9, timestamp: date(2025, 10, 22, 20, 11, 21))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 22, 20, 13, 41))
        addSet(exercise: "T Bar Row", weight: 20.0, reps: 8, timestamp: date(2025, 10, 22, 20, 14, 49))

        // SESSION 27: 2025-10-23 19:00:45
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 20, timestamp: date(2025, 10, 23, 19, 0, 45))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 14, timestamp: date(2025, 10, 23, 19, 4, 32))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 15, timestamp: date(2025, 10, 23, 19, 4, 36))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 15, timestamp: date(2025, 10, 23, 19, 6, 48))
        // Landmine Shoulder Press: 3 sets
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 14, 25), isPB: true)
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 16, 41))
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 18, 45))
        // Landmine Row: 3 sets
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 12, timestamp: date(2025, 10, 23, 19, 22, 17))
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 15, timestamp: date(2025, 10, 23, 19, 24, 28), isPB: true)
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 15, timestamp: date(2025, 10, 23, 19, 26, 42))
        // Reverse Cable Flys: 2 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 23, 19, 29, 26))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 10, 23, 19, 30, 59))

        // SESSION 28: 2025-10-28 16:35:49
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2025, 10, 28, 16, 35, 49))
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 28, 16, 37, 41))
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 41, 3))
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 43, 37))
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 46, 22))
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 15, timestamp: date(2025, 10, 28, 16, 48, 59))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 28, 16, 51, 21))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 16, 53, 52))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 16, 57, 57))
        // Leg Raises: 4 sets
        addWarmUpSet(exercise: "Leg Raises", weight: 43.0, reps: 12, timestamp: date(2025, 10, 28, 16, 59, 11))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 1, 8))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 3, 16))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 6, 3))
        // Hamstring Curls: 1 sets
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 17, 7, 29))
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 18, timestamp: date(2025, 10, 28, 17, 10, 19))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 16, timestamp: date(2025, 10, 28, 17, 12, 24))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 28, 17, 15, 5))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 28, 17, 17, 0))
        // Dumbbell lunges: 3 sets
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 10, timestamp: date(2025, 10, 28, 17, 20, 15))
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 14, timestamp: date(2025, 10, 28, 17, 20, 22))
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 14, timestamp: date(2025, 10, 28, 17, 22, 27))
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 28, 17, 27, 50))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 28, 17, 29, 36))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 10, timestamp: date(2025, 10, 28, 17, 32, 44))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 10, 28, 17, 35, 43), isPB: true)
        // Hyper extensions: 3 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 28, 17, 46, 13))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 28, 17, 46, 16))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 13, timestamp: date(2025, 10, 28, 17, 47, 19), isPB: true)

        // SESSION 29: 2025-10-29 16:57:05
        // EZ bar curl: 4 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 15, timestamp: date(2025, 10, 29, 16, 57, 5))
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 11, timestamp: date(2025, 10, 29, 16, 57, 12))
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 11, timestamp: date(2025, 10, 29, 16, 59, 25))
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 12, timestamp: date(2025, 10, 29, 17, 1, 56))
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 10, 29, 17, 4, 7))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 29, 17, 6, 13))
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 15, timestamp: date(2025, 10, 29, 17, 8, 44))
        addDropSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 29, 17, 11, 42))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 29, 17, 13, 52))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 29, 17, 16, 2))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 29, 17, 18, 2))
        // Seated dumbbell Arnold press: 3 sets
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 8, timestamp: date(2025, 10, 29, 17, 20, 58))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 10, timestamp: date(2025, 10, 29, 17, 23, 15), isPB: true)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 8, timestamp: date(2025, 10, 29, 17, 25, 39))
        // Dumbbell lateral raises: 1 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 27, 53))
        // Front lateral dumbbell raise: 1 sets
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 10, timestamp: date(2025, 10, 29, 17, 28, 39), isPB: true)
        // Dumbbell lateral raises: 1 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 31, 9))
        // Front lateral dumbbell raise: 2 sets
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 6, timestamp: date(2025, 10, 29, 17, 31, 20))
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 7, timestamp: date(2025, 10, 29, 17, 36, 55))
        // Dumbbell lateral raises: 2 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 36, 59))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 37, 2))
        // Ball tricep pushdown: 3 sets
        addSet(exercise: "Ball tricep pushdown", weight: 17.5, reps: 15, timestamp: date(2025, 10, 29, 17, 39, 29))
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 10, timestamp: date(2025, 10, 29, 17, 40, 29), isPB: true)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 10, timestamp: date(2025, 10, 29, 17, 43, 1))
        // Tricep rope pushdown: 2 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 11, timestamp: date(2025, 10, 29, 17, 44, 33))
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 29, 17, 46, 49))

        // SESSION 30: 2025-10-30 18:59:43
        // Tricep rope pushdown: 1 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 30, 18, 59, 43))
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 30, 19, 14, 10))
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 30, 19, 16, 3))
        addSet(exercise: "Leg press", weight: 120.0, reps: 6, timestamp: date(2025, 10, 30, 19, 18, 22))
        addDropSet(exercise: "Leg press", weight: 100.0, reps: 12, timestamp: date(2025, 10, 30, 19, 22, 8))
        // Romanian deadlift : 3 sets
        addSet(exercise: "Romanian deadlift ", weight: 40.0, reps: 10, timestamp: date(2025, 10, 30, 19, 25, 37))
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 10, timestamp: date(2025, 10, 30, 19, 27, 28))
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 10, timestamp: date(2025, 10, 30, 19, 34, 42))
        // Dumbbell split squats: 1 sets
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 6, timestamp: date(2025, 10, 30, 19, 34, 58))
        // Toes to bar: 4 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 41, 37))
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 43, 30))
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 45, 44))
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 6, timestamp: date(2025, 10, 30, 19, 47, 25))
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 30, 19, 48, 41))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 30, 19, 50, 50))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 14, timestamp: date(2025, 10, 30, 19, 52, 23))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 30, 19, 53, 51))
        // Box jumps: 3 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 10, timestamp: date(2025, 10, 30, 19, 56, 47))
        addSet(exercise: "Box jumps", weight: 0.0, reps: 12, timestamp: date(2025, 10, 30, 19, 57, 36))
        addSet(exercise: "Box jumps", weight: 0.0, reps: 12, timestamp: date(2025, 10, 30, 20, 0, 0))

        // SESSION 31: 2025-11-01 08:56:40
        // Incline Dumbbell Chest Press: 5 sets
        addWarmUpSet(exercise: "Incline Dumbbell Chest Press", weight: 17.5, reps: 12, timestamp: date(2025, 11, 1, 8, 56, 40))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 1, 8, 58, 4))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 9, timestamp: date(2025, 11, 1, 9, 1, 1))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 1, 9, 5, 4))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 11, 1, 9, 8, 44))
        // Cable chest flys mid: 4 sets
        addSet(exercise: "Cable chest flys mid", weight: 17.5, reps: 12, timestamp: date(2025, 11, 1, 9, 10, 33))
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 10, timestamp: date(2025, 11, 1, 9, 12, 21))
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 10, timestamp: date(2025, 11, 1, 9, 16, 20))
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 11, timestamp: date(2025, 11, 1, 9, 17, 4), isPB: true)
        // Dumbbell shoulder press: 3 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 11, 1, 9, 19, 27))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 11, 1, 9, 22, 9))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 11, 1, 9, 25, 37))
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 15, timestamp: date(2025, 11, 1, 9, 28, 4))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 15, timestamp: date(2025, 11, 1, 9, 30, 26))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 13, timestamp: date(2025, 11, 1, 9, 33, 15))
        // EZ bar curl: 2 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 10, timestamp: date(2025, 11, 1, 9, 36, 13))
        addSet(exercise: "EZ bar curl", weight: 10.0, reps: 8, timestamp: date(2025, 11, 1, 9, 38, 4), isPB: true)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 10, timestamp: date(2025, 11, 1, 9, 43, 58))
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 8, timestamp: date(2025, 11, 1, 9, 44, 2))
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 10, timestamp: date(2025, 11, 1, 9, 45, 53))
        // Bicep rope curls: 1 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 47, 41))
        // Press-ups: 2 sets
        addSet(exercise: "Press-ups", weight: 0.0, reps: 10, timestamp: date(2025, 11, 1, 9, 48, 22), isPB: true)
        addSet(exercise: "Press-ups", weight: 0.0, reps: 10, timestamp: date(2025, 11, 1, 9, 49, 34))
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 49, 40))
        addDropSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 52, 20))
        // Press-ups: 1 sets
        addSet(exercise: "Press-ups", weight: 0.0, reps: 10, timestamp: date(2025, 11, 1, 9, 52, 25))

        // SESSION 32: 2025-11-03 17:11:55
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 11, 55))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 14, 11))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 17, 5))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 21, 0))
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 3, 17, 26, 25))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 3, 17, 28, 49))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 11, 3, 17, 31, 17))
        // EZ bar curl: 3 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 17, timestamp: date(2025, 11, 3, 17, 33, 42))
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 17, timestamp: date(2025, 11, 3, 17, 36, 10))
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 14, timestamp: date(2025, 11, 3, 17, 38, 25))
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 10, timestamp: date(2025, 11, 3, 17, 41, 19))
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 8, timestamp: date(2025, 11, 3, 17, 43, 6))
        addDropSet(exercise: "Lat pull down", weight: 59.5, reps: 8, timestamp: date(2025, 11, 3, 17, 45, 54))
        // Rope Face Pulls: 3 sets
        addSet(exercise: "Rope Face Pulls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 3, 17, 48, 34))
        addSet(exercise: "Rope Face Pulls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 3, 17, 50, 56))
        addSet(exercise: "Rope Face Pulls", weight: 50.5, reps: 12, timestamp: date(2025, 11, 3, 17, 52, 40))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 15, timestamp: date(2025, 11, 3, 17, 55, 43))
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 15, timestamp: date(2025, 11, 3, 17, 57, 10))
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 13, timestamp: date(2025, 11, 3, 17, 59, 15))

        // SESSION 33: 2025-11-04 16:46:00
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 11, 4, 16, 46, 0))
        addSet(exercise: "Leg press", weight: 120.0, reps: 11, timestamp: date(2025, 11, 4, 16, 48, 25))
        addSet(exercise: "Leg press", weight: 120.0, reps: 12, timestamp: date(2025, 11, 4, 16, 51, 8))
        addSet(exercise: "Leg press", weight: 120.0, reps: 12, timestamp: date(2025, 11, 4, 16, 53, 51))
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 15, timestamp: date(2025, 11, 4, 16, 55, 41))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 11, 4, 16, 57, 7))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 11, 4, 16, 59, 26))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 4, 17, 4, 38))
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 11, 4, 17, 4, 44))
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 6, 48))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 8, 54))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 10, 52))
        // Toes to bar: 2 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 12, timestamp: date(2025, 11, 4, 17, 23, 40))
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 12, timestamp: date(2025, 11, 4, 17, 25, 54))

        // SESSION 34: 2025-11-05 17:09:47
        // Shoulder press machine : 3 sets
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 10, timestamp: date(2025, 11, 5, 17, 9, 47))
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 13, timestamp: date(2025, 11, 5, 17, 11, 34))
        addSet(exercise: "Shoulder press machine ", weight: 43.0, reps: 8, timestamp: date(2025, 11, 5, 17, 14, 33), isPB: true)
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 11, 5, 17, 17, 56))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 12, timestamp: date(2025, 11, 5, 17, 19, 34))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 5, 17, 21, 48))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 5, 17, 24, 19))
        // Front lateral cable raise: 1 sets
        addSet(exercise: "Front lateral cable raise", weight: 20.0, reps: 15, timestamp: date(2025, 11, 5, 17, 25, 59))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 11, 5, 17, 28, 53))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 5, 17, 30, 43))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 5, 17, 33, 5))
        // Front lateral cable raise: 2 sets
        addSet(exercise: "Front lateral cable raise", weight: 20.0, reps: 15, timestamp: date(2025, 11, 5, 17, 34, 28))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 15, timestamp: date(2025, 11, 5, 17, 36, 47), isPB: true)
        // Bicep rope curls: 1 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 15, timestamp: date(2025, 11, 5, 17, 38, 49))
        // Tricep rope pushdown: 2 sets
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 15, timestamp: date(2025, 11, 5, 17, 40, 24))
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 17, timestamp: date(2025, 11, 5, 17, 42, 56))
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 5, 17, 43, 56))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 13, timestamp: date(2025, 11, 5, 17, 46, 30))
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 12, timestamp: date(2025, 11, 5, 17, 50, 13))
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 10, timestamp: date(2025, 11, 5, 17, 51, 55))
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 15, timestamp: date(2025, 11, 5, 17, 54, 47), isPB: true)
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 12, timestamp: date(2025, 11, 5, 17, 55, 44))
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 14, timestamp: date(2025, 11, 5, 17, 58, 15))
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 13, timestamp: date(2025, 11, 5, 17, 58, 47), isPB: true)
        // Deadlifts (Trapbar): 5 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 11, 5, 18, 1, 45))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 11, 5, 18, 3, 35))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 18, 6, 10))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 18, 8, 54))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 19, 32, 36))

        // SESSION 35: 2025-11-06 23:05:16
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 6, 23, 5, 16))

        // SESSION 36: 2025-11-07 16:45:33
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 7, 16, 45, 33))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 7, 16, 48, 7), isPB: true)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 16, 51, 15))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 16, 53, 54))
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 7, 16, 58, 34), isPB: true)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 17, 1, 14))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 9, timestamp: date(2025, 11, 7, 17, 5, 26))
        // Dumbbell shoulder press: 2 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 12, timestamp: date(2025, 11, 7, 17, 8, 20), isPB: true)
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 8, timestamp: date(2025, 11, 7, 17, 11, 29))
        // Chest Cable Flys: 3 sets
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 20, timestamp: date(2025, 11, 7, 17, 14, 58))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 17, 38))
        addSet(exercise: "Chest Cable Flys", weight: 22.5, reps: 13, timestamp: date(2025, 11, 7, 17, 19, 30))
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 22, 41), isPB: true)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 27, 24))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 7, 17, 27, 28))
        // Tricep Dips: 4 sets
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 11, 7, 17, 31, 26))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 12, timestamp: date(2025, 11, 7, 17, 33, 47))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 11, 7, 17, 37, 33))
        addSet(exercise: "Tricep Dips", weight: 7.0, reps: 8, timestamp: date(2025, 11, 7, 17, 39, 20))
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 12, timestamp: date(2025, 11, 7, 17, 43, 0), isPB: true)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 7, 17, 44, 42))
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 8, timestamp: date(2025, 11, 7, 17, 46, 52))
        // Dumbbell shoulder press: 1 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 8, timestamp: date(2025, 11, 7, 17, 48, 54))

        // SESSION 37: 2025-11-08 16:25:44
        // Barbell squat: 4 sets
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 11, 8, 16, 25, 44))
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 8, 16, 27, 23))
        addSet(exercise: "Barbell squat", weight: 6.0, reps: 11, timestamp: date(2025, 11, 8, 16, 30, 3))
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 8, 16, 33, 27))
        // Pull ups: 3 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 38, 8), isPB: true)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 40, 11))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 43, 25))
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 7, timestamp: date(2025, 11, 8, 16, 48, 12))
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 8, 16, 51, 4))
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 8, 16, 52, 48))
        // Seated Incline Dumbell Curls: 3 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 11, 8, 16, 54, 51))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 8, 16, 57, 11))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 8, 16, 59, 52))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 8, 17, 4, 40))
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 8, 17, 5, 27))
        addDropSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 8, timestamp: date(2025, 11, 8, 17, 9, 10))
        // Calf Raises: 3 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 18, timestamp: date(2025, 11, 8, 17, 11, 4))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 16, timestamp: date(2025, 11, 8, 17, 12, 37))
        addSet(exercise: "Calf Raises", weight: 50.0, reps: 17, timestamp: date(2025, 11, 8, 17, 14, 30))

        // SESSION 38: 2025-11-09 15:32:17
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 15, timestamp: date(2025, 11, 9, 15, 32, 17))
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2025, 11, 9, 15, 33, 43))
        addSet(exercise: "Leg press", weight: 130.0, reps: 11, timestamp: date(2025, 11, 9, 15, 35, 49))
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2025, 11, 9, 15, 37, 42))
        addSet(exercise: "Leg press", weight: 130.0, reps: 13, timestamp: date(2025, 11, 9, 15, 39, 50))
        // Hamstring Curls: 1 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 12, timestamp: date(2025, 11, 9, 15, 41, 20))
        // Romanian deadlift : 4 sets
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 12, timestamp: date(2025, 11, 9, 15, 45, 56))
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 6, timestamp: date(2025, 11, 9, 15, 47, 26))
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 9, timestamp: date(2025, 11, 9, 15, 49, 27), isPB: true)
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 9, timestamp: date(2025, 11, 9, 15, 52, 38))
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 9, 15, 54, 9))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 9, 15, 55, 52))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 9, timestamp: date(2025, 11, 9, 15, 58, 19))
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 11, 9, 15, 59, 32))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 9, 16, 1, 13))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 11, 9, 16, 3, 38))
        // Single arm back pull machine: 4 sets
        addSet(exercise: "Single arm back pull machine", weight: 15.0, reps: 12, timestamp: date(2025, 11, 9, 16, 6, 42))
        addSet(exercise: "Single arm back pull machine", weight: 15.0, reps: 12, timestamp: date(2025, 11, 9, 16, 8, 38))
        addSet(exercise: "Single arm back pull machine", weight: 20.0, reps: 10, timestamp: date(2025, 11, 9, 16, 11, 21))
        addSet(exercise: "Single arm back pull machine", weight: 20.0, reps: 12, timestamp: date(2025, 11, 9, 16, 14, 21), isPB: true)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 9, 16, 17, 5))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 9, 16, 20, 46))
        addDropSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 11, 9, 16, 20, 54))
        // Toes to bar: 3 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 13, timestamp: date(2025, 11, 9, 16, 32, 42), isPB: true)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 11, 9, 16, 37, 29))
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 11, 9, 16, 37, 31))

        // SESSION 39: 2025-11-10 17:27:30
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 11, 10, 17, 27, 30))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 12, timestamp: date(2025, 11, 10, 17, 29, 30))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 17, 31, 45))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 10, 17, 34, 34))
        // Dumbbell chest press: 2 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 10, 17, 37, 27))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 10, 17, 39, 27))
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 11, 10, 17, 44, 49))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 10, 17, 46, 52))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 10, 17, 49, 9))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 11, 10, 17, 51, 26))
        // Tricep Dips: 3 sets
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 12, timestamp: date(2025, 11, 10, 17, 56, 6))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 11, 10, 17, 57, 47))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 10, timestamp: date(2025, 11, 10, 17, 59, 44))
        // Barbell shoulder press: 3 sets
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 12, timestamp: date(2025, 11, 10, 18, 2, 17))
        addSet(exercise: "Barbell shoulder press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 18, 4, 8), isPB: true)
        addSet(exercise: "Barbell shoulder press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 18, 7, 4))
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 10, 18, 8, 0))
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 7, timestamp: date(2025, 11, 10, 18, 10, 0))
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 9, timestamp: date(2025, 11, 10, 18, 11, 44), isPB: true)

        // SESSION 40: 2025-11-18 16:57:25
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 18, 16, 57, 25))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 15, timestamp: date(2025, 11, 18, 17, 0, 13))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 12, timestamp: date(2025, 11, 18, 17, 3, 18))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 18, 17, 6, 35))
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 18, 17, 9, 54))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 9, timestamp: date(2025, 11, 18, 17, 12, 40))
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 6, timestamp: date(2025, 11, 18, 17, 15, 24))
        // Dumbbell shoulder press: 3 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 12, timestamp: date(2025, 11, 18, 17, 17, 12))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 11, timestamp: date(2025, 11, 18, 17, 20, 33))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 11, 18, 17, 23, 22))
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 24, 57))
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 27, 34))
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 30, 15))
        // Tricep Dips: 3 sets
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 33, 36))
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 36, 6))
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 39, 23))
        // Tricep rope pushdown: 4 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 42, 18))
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 44, 11))
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 46, 30))
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 48, 58))

        // SESSION 41: 2025-11-19 16:26:53
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 19, 16, 26, 53))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 11, 19, 16, 28, 36))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 19, 16, 32, 51))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 19, 16, 38, 36))
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 12, timestamp: date(2025, 11, 19, 16, 42, 22))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2025, 11, 19, 16, 45, 10))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 9, timestamp: date(2025, 11, 19, 16, 48, 14))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 19, 16, 51, 2))
        // Rope Face Pulls: 3 sets
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 12, timestamp: date(2025, 11, 19, 16, 52, 50))
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 12, timestamp: date(2025, 11, 19, 16, 55, 13))
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 9, timestamp: date(2025, 11, 19, 16, 57, 57))
        // Straight arm cable pulldown: 3 sets
        addSet(exercise: "Straight arm cable pulldown", weight: 50.5, reps: 12, timestamp: date(2025, 11, 19, 16, 59, 41))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.5, reps: 14, timestamp: date(2025, 11, 19, 17, 2, 26))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.5, reps: 10, timestamp: date(2025, 11, 19, 17, 4, 40))
        // Seated Incline Dumbell Curls: 3 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 19, 17, 6, 8))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 13, timestamp: date(2025, 11, 19, 17, 8, 53))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 19, 17, 12, 23))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 15, timestamp: date(2025, 11, 19, 17, 15, 18), isPB: true)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2025, 11, 19, 17, 17, 44))
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 19, 17, 20, 39))
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 13, timestamp: date(2025, 11, 19, 17, 34, 34), isPB: true)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 19, 17, 36, 22))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 19, 17, 38, 44))

        // SESSION 42: 2025-11-20 16:11:38
        // Barbell squat: 4 sets
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 20, 16, 11, 38))
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 11, timestamp: date(2025, 11, 20, 16, 17, 26), isPB: true)
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 11, timestamp: date(2025, 11, 20, 16, 21, 30))
        addSet(exercise: "Barbell squat", weight: 60.0, reps: 6, timestamp: date(2025, 11, 20, 16, 25, 1))
        // Deadlifts: 3 sets
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 12, timestamp: date(2025, 11, 20, 16, 26, 24), isPB: true)
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 12, timestamp: date(2025, 11, 20, 16, 29, 19))
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 10, timestamp: date(2025, 11, 20, 16, 33, 10))
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 12, timestamp: date(2025, 11, 20, 16, 34, 28))
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 8, timestamp: date(2025, 11, 20, 16, 36, 55))
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 8, timestamp: date(2025, 11, 20, 16, 39, 16))
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 11, 20, 16, 41, 53))
        // Leg Raises: 2 sets
        addSet(exercise: "Leg Raises", weight: 65.0, reps: 8, timestamp: date(2025, 11, 20, 16, 43, 47))
        addSet(exercise: "Leg Raises", weight: 65.0, reps: 9, timestamp: date(2025, 11, 20, 16, 45, 45), isPB: true)
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 16, timestamp: date(2025, 11, 20, 16, 50, 18), isPauseAtTop: true)
        addSet(exercise: "Calf Raises", weight: 60.0, reps: 15, timestamp: date(2025, 11, 20, 16, 52, 10), isPB: true)
        addSet(exercise: "Calf Raises", weight: 60.0, reps: 14, timestamp: date(2025, 11, 20, 16, 54, 40))
        addSet(exercise: "Calf Raises", weight: 60.0, reps: 14, timestamp: date(2025, 11, 20, 16, 58, 2))
        // Dumbbell lunges: 3 sets
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 8, timestamp: date(2025, 11, 20, 16, 59, 18))
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 6, timestamp: date(2025, 11, 20, 17, 1, 44))
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 7, timestamp: date(2025, 11, 20, 17, 5, 0))

        // SESSION 43: 2025-11-21 23:50:50
        // Dumbbell lunges: 2 sets
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 7, timestamp: date(2025, 11, 21, 23, 50, 50))
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 9, timestamp: date(2025, 11, 21, 23, 51, 8), isPB: true)

        // SESSION 44: 2025-11-22 15:30:25
        // Straight arm cable pulldown: 2 sets
        addSet(exercise: "Straight arm cable pulldown", weight: 50.5, reps: 10, timestamp: date(2025, 11, 22, 15, 30, 25))
        addSet(exercise: "Straight arm cable pulldown", weight: 60.0, reps: 10, timestamp: date(2025, 11, 22, 15, 30, 32), isPauseAtTop: true, isTimedSet: true, tempoSeconds: 0, isPB: true)

        // SESSION 45: 2025-11-23 15:38:02
        // Chest Press: 3 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 11, 23, 15, 38, 2))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 11, 23, 15, 40, 42))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 11, 23, 15, 43, 21))
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 11, timestamp: date(2025, 11, 23, 15, 45, 27))
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 11, 23, 15, 48, 11))
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 10, timestamp: date(2025, 11, 23, 15, 51, 2))
        addSet(exercise: "Incline chest press machine", weight: 45.0, reps: 8, timestamp: date(2025, 11, 23, 15, 55, 13), isPB: true)
        // Tricep Dips: 4 sets
        addSet(exercise: "Tricep Dips", weight: 0.0, reps: 10, timestamp: date(2025, 11, 23, 15, 58, 6))
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 9, timestamp: date(2025, 11, 23, 16, 2, 5), isPB: true)
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 9, timestamp: date(2025, 11, 23, 16, 4, 28))
        addSet(exercise: "Tricep Dips", weight: 7.5, reps: 8, timestamp: date(2025, 11, 23, 16, 9, 52))
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 12, timestamp: date(2025, 11, 23, 16, 11, 6), isPB: true)
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 8, timestamp: date(2025, 11, 23, 16, 13, 10))
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 11, timestamp: date(2025, 11, 23, 16, 16, 9))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 11, timestamp: date(2025, 11, 23, 16, 19, 31))
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 23, 16, 21, 43))
        // Dumbbell shoulder press: 2 sets
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 12, timestamp: date(2025, 11, 23, 16, 23, 19))
        addSet(exercise: "Dumbbell shoulder press", weight: 15.0, reps: 15, timestamp: date(2025, 11, 23, 16, 27, 10))
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 11, timestamp: date(2025, 11, 23, 16, 31, 49))
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 9, timestamp: date(2025, 11, 23, 16, 33, 20))
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 12, timestamp: date(2025, 11, 23, 16, 35, 35))

        // SESSION 46: 2025-11-24 17:27:36
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 24, 17, 27, 36))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 24, 17, 31, 44))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 24, 17, 33, 19))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 11, 24, 17, 35, 36))
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2025, 11, 24, 17, 38, 21))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 24, 17, 41, 0))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 24, 17, 43, 13))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 11, 24, 17, 45, 0))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 24, 17, 46, 55))
        addDropSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 11, 24, 17, 49, 37))
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 16, timestamp: date(2025, 11, 24, 17, 51, 10), isPB: true)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 14, timestamp: date(2025, 11, 24, 17, 53, 10))
        addDropSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 11, 24, 17, 55, 57))
        // Rope Face Pulls: 3 sets
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 10, timestamp: date(2025, 11, 24, 17, 57, 25))
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 14, timestamp: date(2025, 11, 24, 17, 59, 38), isPB: true)
        addSet(exercise: "Rope Face Pulls", weight: 56.0, reps: 11, timestamp: date(2025, 11, 24, 18, 1, 15))
        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 11, 24, 18, 2, 53))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 24, 18, 5, 10))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 14, timestamp: date(2025, 11, 24, 18, 8, 43))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 9, timestamp: date(2025, 11, 24, 18, 12, 9), isPB: true)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 13, timestamp: date(2025, 11, 24, 18, 13, 53))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 24, 18, 15, 39))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 9, timestamp: date(2025, 11, 24, 18, 19, 20))

        // SESSION 47: 2025-11-25 16:43:47
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 15, timestamp: date(2025, 11, 25, 16, 43, 47))
        addSet(exercise: "Leg press", weight: 100.0, reps: 12, timestamp: date(2025, 11, 25, 16, 45, 34))
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2025, 11, 25, 16, 49, 31))
        addSet(exercise: "Leg press", weight: 130.0, reps: 13, timestamp: date(2025, 11, 25, 16, 52, 41))
        addSet(exercise: "Leg press", weight: 140.0, reps: 11, timestamp: date(2025, 11, 25, 16, 56, 41), isPB: true)
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 17, timestamp: date(2025, 11, 25, 17, 0, 41))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 15, timestamp: date(2025, 11, 25, 17, 1, 45))
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 12, timestamp: date(2025, 11, 25, 17, 4, 14), isPB: true)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 11, timestamp: date(2025, 11, 25, 17, 7, 13))
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 7, timestamp: date(2025, 11, 25, 17, 8, 57))
        // Dumbbell Romanian deadlift: 3 sets
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 12, 34))
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 14, 0))
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 12, timestamp: date(2025, 11, 25, 17, 15, 30), isPB: true)
        // Dumbbell split squats: 3 sets
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 18, 21), isPB: true)
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 20, 28))
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 23, 28))
        // Calf Raises: 4 sets
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 20, timestamp: date(2025, 11, 25, 17, 25, 8))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 19, timestamp: date(2025, 11, 25, 17, 27, 7))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 11, 25, 17, 29, 3))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 16, timestamp: date(2025, 11, 25, 17, 31, 9))
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 25, 17, 32, 47))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 25, 17, 34, 37))
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 11, 25, 17, 36, 49))
        // Box jumps: 3 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 40, 26), isPB: true)
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 43, 19))
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 47, 13))
        // T Bar Row: 2 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 25, 20, 32, 23))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 25, 20, 32, 32))

        // Save all changes
        do {
            try modelContext.save()

            // Recalculate PB flags for all exercises (safety net to ensure correctness)
            for (_, exercise) in exercises {
                // Get all sets for this exercise and recalculate PBs
                for set in exercise.sets where !set.isWarmUp {
                    try ExerciseSetService.detectAndMarkPB(for: set, exercise: exercise, context: modelContext)
                }
            }
            try modelContext.save()
        } catch {
            print("Error saving test data: \(error)")
        }
    }

    // MARK: - Cleanup

    private static func clearAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Exercise.self)
            try modelContext.delete(model: ExerciseSet.self)
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

#endif

// COPY TO HERE ==========================================================
