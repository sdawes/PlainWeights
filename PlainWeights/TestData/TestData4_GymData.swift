//
//  TestData4_GymData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//  Last Updated: 9 Oct 2025 at 18:15:28
//
//  Test Data Set 4: Real Gym Data
//  35 exercises, 15 workout sessions (Sep 22 - Oct 8, 2025)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData4_GymData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData4_GymData")
        logger.info("Generating Test Data Set 4 (Real gym data - 35 exercises, 15 sessions)...")

        // Clear existing data
        clearAllData(modelContext: modelContext)

        generateGymData(modelContext: modelContext)
        logger.info("Test Data Set 4 generation completed")
    }

    // MARK: - Data Generation

    private static func generateGymData(modelContext: ModelContext) {
        // EXPORT DATE: 9 Oct 2025 at 18:15:28

        // Exercise definitions with notes
        let exerciseData: [(name: String, category: String, note: String?)] = [
            (name: "Seated Incline Dumbell Curls", category: "Bicep", note: "Bench number 5"),
            (name: "Barbell squat", category: "Legs", note: nil),
            (name: "Knees to toe", category: "Core", note: nil),
            (name: "Barbell Lunges", category: "Legs", note: nil),
            (name: "Hamstring Curls", category: "Legs", note: "5 is 37.5 and 6 is 43kg"),
            (name: "Sled Push", category: "Legs", note: nil),
            (name: "T Bar Row", category: "Back", note: nil),
            (name: "Rope Bicep Curls", category: "Bicep", note: "7 is 39.5kg, 8 is 45kg"),
            (name: "Leg Raises", category: "Legs", note: "5 is 37.5, 7 is 48.5, 8 is 54"),
            (name: "Reverse Cable Flys", category: "Back", note: nil),
            (name: "Rope Face Pulls", category: "Back", note: nil),
            (name: "Calf Raises", category: "Legs", note: nil),
            (name: "Deadlifts (Trapbar)", category: "Back", note: nil),
            (name: "Dumbbell lateral raises", category: "Shoulders", note: nil),
            (name: "Single cable lateral raise", category: "Shoulders", note: "2 is 15kg and 3 is 17.5"),
            (name: "Front lateral cable raise", category: "Shoulders", note: "3 is 17.5, 4 23 and 5 28.5"),
            (name: "Seated dumbbell Arnold press", category: "Shoulders", note: nil),
            (name: "Upright cable row", category: "Shoulders", note: nil),
            (name: "Butterfly sit up", category: "Core", note: nil),
            (name: "Chest Press", category: "Chest", note: nil),
            (name: "Incline Dumbbell Chest Press", category: "Chest", note: nil),
            (name: "Chest Cable Flys", category: "Chest", note: nil),
            (name: "Tricep Dips", category: "Triceps", note: nil),
            (name: "Overhead Tricep Rope Pulls", category: "Triceps", note: "7 is 39.5 and 8 is 45"),
            (name: "Dumbbell flys", category: "Chest ", note: nil),
            (name: "Straight arm cable pulldown", category: "Back", note: "8 is 45kg 9 is 50.5"),
            (name: "Reverse dumbbell flys", category: "Back", note: nil),
            (name: "Dumbbell shoulder press", category: "Shoulders", note: nil),
            (name: "Dumbbell shoulder shrugs", category: "Shoulders", note: nil),
            (name: "Hyper extensions", category: "Back", note: nil),
            (name: "Incline machine chest press", category: "Chest", note: nil),
            (name: "Seated cable row", category: "Back", note: "8 is 54kg"),
            (name: "Leg press", category: "Legs", note: nil),
            (name: "Dumbbell chest press", category: "Chest", note: nil),
            (name: "Pull ups", category: "Back", note: nil),
        ]

        // Create exercises
        var exercises: [String: Exercise] = [:]
        for data in exerciseData {
            let exercise = Exercise(name: data.name, category: data.category, note: data.note)
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
        func addSet(exercise: String, weight: Double, reps: Int, timestamp: Date) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, exercise: ex)
            modelContext.insert(set)
        }

        // Helper function to add a warm-up set
        func addWarmUpSet(exercise: String, weight: Double, reps: Int, timestamp: Date) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: true, exercise: ex)
            modelContext.insert(set)
        }

        // SESSION 1: 2025-09-22 17:00:00
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 0, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 3, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0))
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 10, 0))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 13, 0))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 15, 0))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 17, 0))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 20, 0))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 23, 0))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 25, 0))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 30, 0))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 33, 0))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 35, 0))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 37, 0))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 40, 0))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 0, 0))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 3, 0))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 5, 0))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 6, 0))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 9, 0))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 12, 0))
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 24, 0))
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 26, 0))
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 30, 0))
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 32, 0))
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 35, 0))
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 38, 0))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 40, 0))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 43, 0))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 12, timestamp: date(2025, 9, 22, 18, 45, 0))

        // SESSION 2: 2025-09-24 17:03:30
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 3, 30))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 7, 0))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 9, 0))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 11, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 14, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 16, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 18, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 20, 0))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 22, 30))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 25, 0))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 27, 30))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 30, 0))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 32, 30))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 34, 30))
        addSet(exercise: "Rope Face Pulls", weight: 45.0, reps: 10, timestamp: date(2025, 9, 24, 17, 36, 30))
        addSet(exercise: "Rope Bicep Curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 39, 0))
        addSet(exercise: "Rope Bicep Curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 41, 30))
        addSet(exercise: "Rope Bicep Curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 44, 0))
        addSet(exercise: "Rope Bicep Curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 46, 30))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 49, 0))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 51, 30))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 54, 0))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 47, 30))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 48, 30))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 49, 30))

        // SESSION 3: 2025-09-25 16:57:05
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 25, 16, 57, 5))
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 13, timestamp: date(2025, 9, 25, 16, 58, 2))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 0, 9))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 1, 32))
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 25, 17, 4, 30))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 9, 25, 17, 7, 26))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 9, 25, 17, 8, 47))
        addWarmUpSet(exercise: "Barbell squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 25, 17, 13, 4))
        addSet(exercise: "Barbell squat", weight: 40.0, reps: 8, timestamp: date(2025, 9, 25, 17, 15, 31))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 39))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 44))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 21, 54))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 25, 36))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 28, 6))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 32, 50))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 11, timestamp: date(2025, 9, 25, 17, 41, 22))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 25, 17, 42, 28))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 12, timestamp: date(2025, 9, 25, 17, 46, 16))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 48, 31))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 49, 56))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 9, timestamp: date(2025, 9, 25, 17, 52, 8))

        // SESSION 4: 2025-09-26 16:16:57
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 12, timestamp: date(2025, 9, 26, 16, 16, 57))
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 13, timestamp: date(2025, 9, 26, 16, 19, 9))
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 15, timestamp: date(2025, 9, 26, 16, 22, 17))
        addSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 9, 26, 16, 25, 12))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 27, 22))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 30, 22))
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 12, timestamp: date(2025, 9, 26, 16, 34, 9))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 35, 47))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 37, 55))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 7.5, reps: 10, timestamp: date(2025, 9, 26, 16, 39, 59))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 41, 25))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 43, 45))
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 12, timestamp: date(2025, 9, 26, 16, 47, 38))
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 51, 18))
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 53, 44))
        addSet(exercise: "Upright cable row", weight: 34.0, reps: 15, timestamp: date(2025, 9, 26, 16, 55, 28))
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 57, 33))
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 59, 27))

        // SESSION 5: 2025-09-27 16:41:23
        addWarmUpSet(exercise: "Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 41, 23))
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 8, timestamp: date(2025, 9, 27, 16, 41, 36))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 5, timestamp: date(2025, 9, 27, 16, 44, 32))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 9, 27, 16, 46, 53))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 9, 27, 16, 49, 41))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 9, 27, 16, 52, 45))
        addWarmUpSet(exercise: "Incline Dumbbell Chest Press", weight: 17.5, reps: 8, timestamp: date(2025, 9, 27, 16, 55, 12))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 56, 47))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 0, 12))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 3, 31))
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 7, timestamp: date(2025, 9, 27, 17, 5, 27))
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 14, timestamp: date(2025, 9, 27, 17, 8, 59))
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 10, timestamp: date(2025, 9, 27, 17, 12, 57))
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 8, timestamp: date(2025, 9, 27, 17, 15, 10))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 17, 1))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 19, 23))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 21, 59))
        addWarmUpSet(exercise: "Overhead Tricep Rope Pulls", weight: 28.5, reps: 10, timestamp: date(2025, 9, 27, 17, 24, 57))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 12, timestamp: date(2025, 9, 27, 17, 27, 11))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 29, 38))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 6, timestamp: date(2025, 9, 27, 17, 31, 31))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 34, 3))

        // SESSION 6: 2025-09-29 17:06:07
        addSet(exercise: "Straight arm cable pulldown", weight: 45.0, reps: 13, timestamp: date(2025, 9, 29, 17, 6, 7))
        addSet(exercise: "Straight arm cable pulldown", weight: 47.5, reps: 12, timestamp: date(2025, 9, 29, 17, 8, 3))
        addSet(exercise: "Straight arm cable pulldown", weight: 47.5, reps: 10, timestamp: date(2025, 9, 29, 17, 10, 0))
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 9, timestamp: date(2025, 9, 29, 17, 11, 39))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 9, timestamp: date(2025, 9, 29, 17, 13, 40))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 15, 59))
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 18, 59))
        addSet(exercise: "Reverse dumbbell flys", weight: 10.0, reps: 12, timestamp: date(2025, 9, 29, 17, 23, 8))
        addSet(exercise: "Reverse dumbbell flys", weight: 12.0, reps: 12, timestamp: date(2025, 9, 29, 17, 24, 57))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 30, 21))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 29, 17, 32, 0))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 35, 9))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 38, 39))
        addWarmUpSet(exercise: "Rope Bicep Curls", weight: 42.0, reps: 14, timestamp: date(2025, 9, 29, 17, 40, 14))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 41, 54))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 43, 4))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 45, 12))

        // SESSION 7: 2025-09-29 20:51:28
        addSet(exercise: "Reverse dumbbell flys", weight: 10.0, reps: 15, timestamp: date(2025, 9, 29, 20, 51, 28))

        // SESSION 8: 2025-09-30 16:48:49
        addWarmUpSet(exercise: "Barbell squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 30, 16, 48, 49))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 51, 24))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 54, 4))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 56, 13))
        addSet(exercise: "Barbell squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 58, 25))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 0, 30))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 4, 10))
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 7, 30))
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 30, 17, 11, 9))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 30, 17, 12, 28))
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 16, timestamp: date(2025, 9, 30, 17, 14, 0))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 15, 31))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 17, 23))
        addSet(exercise: "Leg Raises", weight: 37.5, reps: 11, timestamp: date(2025, 9, 30, 17, 19, 5))
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 30, 17, 20, 2))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 8, timestamp: date(2025, 9, 30, 17, 21, 33))
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 30, 17, 23, 15))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 25, 5))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 26, 46))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 9, 30, 17, 28, 16))

        // SESSION 9: 2025-10-01 20:19:17
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 19, 17))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 1, 20, 21, 22))
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 25, 30))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 27, 20))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 30, 46))
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 1, 20, 37, 12))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 38, 10))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 40, 23))
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 10, 1, 20, 46, 1))
        addSet(exercise: "Dumbbell shoulder shrugs", weight: 22.5, reps: 12, timestamp: date(2025, 10, 1, 20, 50, 58))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 56, 5))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 58, 31))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 0, 55))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 9, 45))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 11, 10))
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 13, 8))

        // SESSION 10: 2025-10-02 16:12:52
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 9, timestamp: date(2025, 10, 2, 16, 12, 52))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 14, 54))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 17, 30))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 10, 2, 16, 19, 59))
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 22, 51))
        addWarmUpSet(exercise: "Incline machine chest press", weight: 20.0, reps: 10, timestamp: date(2025, 10, 2, 16, 25, 59))
        addSet(exercise: "Incline machine chest press", weight: 30.0, reps: 8, timestamp: date(2025, 10, 2, 16, 28, 18))
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 2, 16, 35, 43))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 37, 38))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 39, 24))
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 40, 55))
        addSet(exercise: "Incline machine chest press", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 8))
        addSet(exercise: "Incline machine chest press", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 13))
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 8, timestamp: date(2025, 10, 2, 16, 45, 5))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 46, 50))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 50, 5))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 7, timestamp: date(2025, 10, 2, 16, 52, 55))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 2, 16, 57, 27))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 16, 59, 14))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 1, 16))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 3, 41))

        // SESSION 11: 2025-10-02 20:28:56
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 20, 28, 56))

        // SESSION 12: 2025-10-04 10:08:18
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 9, timestamp: date(2025, 10, 4, 10, 8, 18))
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 10, 4, 10, 11, 10))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 8, timestamp: date(2025, 10, 4, 10, 14, 34))
        addSet(exercise: "Seated cable row", weight: 54.0, reps: 10, timestamp: date(2025, 10, 4, 10, 21, 42))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 4, 10, 26, 16))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 28, 3))
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 31, 47))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 10, 4, 10, 32, 58))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 35, 38))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 38, 16))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 6, timestamp: date(2025, 10, 4, 10, 39, 52))

        // SESSION 13: 2025-10-06 16:36:26
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2025, 10, 6, 16, 36, 26))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 38, 42))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 40, 44))
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 43, 20))
        addWarmUpSet(exercise: "Hamstring Curls", weight: 37.5, reps: 15, timestamp: date(2025, 10, 6, 16, 48, 45))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 6, 16, 49, 49))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 6, 16, 52, 3))
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 6, 16, 54, 52))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 16, 58, 9))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 0, 11))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 2, 56))
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 6, 21))
        addSet(exercise: "Calf Raises", weight: 40.0, reps: 15, timestamp: date(2025, 10, 6, 17, 8, 17))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 14, timestamp: date(2025, 10, 6, 17, 10, 46))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 14, timestamp: date(2025, 10, 6, 17, 13, 9))
        addSet(exercise: "Calf Raises", weight: 45.0, reps: 15, timestamp: date(2025, 10, 6, 17, 15, 49))

        // SESSION 14: 2025-10-07 16:46:03
        addWarmUpSet(exercise: "Dumbbell chest press", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 16, 46, 3))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 47, 4))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 51, 9))
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 53, 43))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 8, timestamp: date(2025, 10, 7, 16, 55, 28))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 7, 16, 58, 34))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 10, 7, 17, 1, 58))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 4, 44))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 6, 31))
        addSet(exercise: "Dumbbell shoulder press", weight: 17.5, reps: 9, timestamp: date(2025, 10, 7, 17, 11, 32))
        addWarmUpSet(exercise: "Tricep Dips", weight: 0.0, reps: 7, timestamp: date(2025, 10, 7, 17, 11, 44))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 9, timestamp: date(2025, 10, 7, 17, 13, 12))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 15, 43))
        addSet(exercise: "Tricep Dips", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 19, 19))
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 17, 22, 27))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 25, 36))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 26, 29))
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 28, 51))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 30, 18))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 32, 26))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 34, 27))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2025, 10, 7, 17, 38, 31))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 11, timestamp: date(2025, 10, 7, 17, 39, 39))
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 7, 17, 42, 29))

        // SESSION 15: 2025-10-08 16:03:05
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 8, 16, 3, 5))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 25, 55))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 26, 15))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 28, 7))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 31, 5))
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 10, timestamp: date(2025, 10, 8, 16, 34, 47))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 8, timestamp: date(2025, 10, 8, 16, 36, 23))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 10, timestamp: date(2025, 10, 8, 16, 39, 27))
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 9, timestamp: date(2025, 10, 8, 16, 42, 42))
        addWarmUpSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 13, timestamp: date(2025, 10, 8, 16, 45, 7))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 47, 50))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 50, 10))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 10, 8, 16, 52, 20))
        addSet(exercise: "Straight arm cable pulldown", weight: 45.0, reps: 14, timestamp: date(2025, 10, 8, 16, 54, 55))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 56, 31))
        addSet(exercise: "Straight arm cable pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 58, 2))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 8, 16, 59, 49))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 1, 55))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 3, 54))
        addSet(exercise: "Seated Incline Dumbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 7, 19))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 8, 50))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 10, 5))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 8, 17, 11, 33))
        addSet(exercise: "Rope Bicep Curls", weight: 45.0, reps: 5, timestamp: date(2025, 10, 8, 18, 5, 41))

        // Save all changes
        do {
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
