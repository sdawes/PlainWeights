//
//  TestData4_GymData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//
//  Test Data Set 4: Real Gym Data
//  24 exercises, 4 workout sessions (Sep 22, 24, 25, 26, 2025)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData4_GymData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData4_GymData")
        logger.info("Generating Test Data Set 4 (Real gym data - 24 exercises, 4 sessions)...")

        // Clear existing data
        clearAllData(modelContext: modelContext)

        generateGymData(modelContext: modelContext)
        logger.info("Test Data Set 4 generation completed")
    }

    // MARK: - Data Generation

    private static func generateGymData(modelContext: ModelContext) {
        // Exercise definitions with notes
        let exerciseData: [(name: String, category: String, note: String?)] = [
            (name: "Seated Incline Dumbell Curls", category: "Bicep", note: nil),
            (name: "Barbell squat", category: "Legs", note: nil),
            (name: "Knees to toe", category: "Core", note: nil),
            (name: "Barbell Lunges", category: "Legs", note: nil),
            (name: "Hamstring Curls", category: "Legs", note: nil),
            (name: "Sled Push", category: "Legs", note: nil),
            (name: "T Bar Row", category: "Back", note: nil),
            (name: "Rope Bicep Curls", category: "Bicep", note: nil),
            (name: "Leg Raises", category: "Legs", note: nil),
            (name: "Reverse Cable Flys", category: "Back", note: nil),
            (name: "Pull Up (Strict)", category: "Back", note: nil),
            (name: "Rope Face Pulls", category: "Back", note: nil),
            (name: "Calf Raises", category: "Legs", note: nil),
            (name: "Deadlifts (Trapbar)", category: "Back", note: nil),
            (name: "Dumbbell lateral raises", category: "Shoulders", note: nil),
            (name: "Single cable lateral raise", category: "Shoulders", note: nil),
            (name: "Front lateral cable raise", category: "Shoulders", note: nil),
            (name: "Seated dumbbell Arnold press", category: "Shoulders", note: nil),
            (name: "Upright cable row", category: "Shoulders", note: nil),
            (name: "Butterfly sit up", category: "Core", note: nil),
            (name: "Chest Press", category: "Chest", note: nil),
            (name: "Incline Dumbbell Chest Press", category: "Chest", note: nil),
            (name: "Chest Cable Flys", category: "Chest", note: nil),
            (name: "Tricep Dips", category: "Triceps", note: nil),
            (name: "Tricep Rope Pulls", category: "Triceps", note: nil),
        ]

        // Create exercises
        var exercises: [String: Exercise] = [:]
        for (name, category, note) in exerciseData {
            let exercise = Exercise(name: name, category: category, note: note)
            exercises[name] = exercise
            modelContext.insert(exercise)
        }

        // SESSION 1: 2025-09-22 18:00:00 (Leg Day)
        generateSession1(exercises: exercises, modelContext: modelContext)

        // SESSION 2: 2025-09-24 17:00:00 (Back & Biceps)
        generateSession2(exercises: exercises, modelContext: modelContext)

        // SESSION 3: 2025-09-25 16:57:05 (Legs)
        generateSession3(exercises: exercises, modelContext: modelContext)

        // SESSION 4: 2025-09-26 16:16:57 (Shoulders & Core)
        generateSession4(exercises: exercises, modelContext: modelContext)

        // Save all data
        do {
            try modelContext.save()
        } catch {
            print("Error saving test data: \(error)")
        }
    }

    // MARK: - Session 1: 2025-09-22 17:00:00 - 18:35:00 (Chest, Triceps, then Legs)

    private static func generateSession1(exercises: [String: Exercise], modelContext: ModelContext) {
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 22, hour: 18, minute: 0, second: 0))!

        // CHEST & TRICEPS WORKOUT (17:00 - 17:40)

        // Chest Press: 4 sets @ 17:00, 17:03, 17:05, 17:05
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-60*60), context: modelContext)  // 17:00
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-57*60), context: modelContext)  // 17:03
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-55*60), context: modelContext)  // 17:05
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-55*60), context: modelContext)  // 17:05 (4th set)

        // Incline Dumbbell Chest Press: 3 sets @ 17:10, 17:13, 17:15
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-50*60), context: modelContext)  // 17:10
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-47*60), context: modelContext)  // 17:13
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(-45*60), context: modelContext)  // 17:15

        // Chest Cable Flys: 3 sets @ 17:17, 17:20, 17:23
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(-43*60), context: modelContext)  // 17:17
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(-40*60), context: modelContext)  // 17:20
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(-37*60), context: modelContext)  // 17:23

        // Tricep Dips: 3 sets @ 17:25, 17:30, 17:33
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(-35*60), context: modelContext)  // 17:25
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(-30*60), context: modelContext)  // 17:30
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(-27*60), context: modelContext)  // 17:33

        // Tricep Rope Pulls: 3 sets @ 17:35, 17:37, 17:40
        addSet(exercise: exercises["Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(-25*60), context: modelContext)  // 17:35
        addSet(exercise: exercises["Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(-23*60), context: modelContext)  // 17:37
        addSet(exercise: exercises["Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(-20*60), context: modelContext)  // 17:40

        // LEG DAY WORKOUT (18:00 - 18:35) - Original exercises

        // Barbell squat: 3 sets
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(0), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(3*60), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(5*60), context: modelContext)

        // Barbell Lunges: 3 sets
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(6*60), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(9*60), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(12*60), context: modelContext)

        // Sled Push: 3 sets
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: baseDate.addingTimeInterval(15*60), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: baseDate.addingTimeInterval(17*60), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: baseDate.addingTimeInterval(20*60), context: modelContext)

        // Hamstring Curls: 3 sets
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(24*60), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(26*60), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(30*60), context: modelContext)

        // Leg Raises: 3 sets
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(32*60), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(35*60), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(38*60), context: modelContext)

        // Calf Raises: 3 sets
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(40*60), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(43*60), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(45*60), context: modelContext)
    }

    // MARK: - Session 2: 2025-09-24 17:00:00 (Back & Biceps)

    private static func generateSession2(exercises: [String: Exercise], modelContext: ModelContext) {
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 17, minute: 0, second: 0))!

        // Pull Up (Strict): 2 sets
        addSet(exercise: exercises["Pull Up (Strict)"]!, weight: 0.0, reps: 5,
               timestamp: baseDate.addingTimeInterval(0), context: modelContext)
        addSet(exercise: exercises["Pull Up (Strict)"]!, weight: 0.0, reps: 5,
               timestamp: baseDate.addingTimeInterval(2*60), context: modelContext)

        // T Bar Row: 4 sets
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(3*60 + 30), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(7*60), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(9*60), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(11*60), context: modelContext)

        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(14*60), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(16*60), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(18*60), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(20*60), context: modelContext)

        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(22*60 + 30), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(25*60), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(27*60 + 30), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(30*60), context: modelContext)

        // Rope Face Pulls: 3 sets
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(32*60 + 30), context: modelContext)
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(34*60 + 30), context: modelContext)
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(36*60 + 30), context: modelContext)

        // Rope Bicep Curls: 4 sets
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(39*60), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(41*60 + 30), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(44*60), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(46*60 + 30), context: modelContext)

        // Reverse Cable Flys: 3 sets
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(49*60), context: modelContext)
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(51*60 + 30), context: modelContext)
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(54*60), context: modelContext)

        // Later in the day - Pull Up (Strict): 2 sets
        let laterTime = baseDate.addingTimeInterval(3*60*60 + 45*60 + 30) // 20:45:30
        addSet(exercise: exercises["Pull Up (Strict)"]!, weight: 0.0, reps: 10,
               timestamp: laterTime, context: modelContext)
        addSet(exercise: exercises["Pull Up (Strict)"]!, weight: 0.0, reps: 10,
               timestamp: laterTime.addingTimeInterval(60), context: modelContext)

        // Knees to toe: 3 sets
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: laterTime.addingTimeInterval(2*60), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: laterTime.addingTimeInterval(3*60), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: laterTime.addingTimeInterval(4*60), context: modelContext)
    }

    // MARK: - Session 3: 2025-09-25 16:57:05 (Legs)

    private static func generateSession3(exercises: [String: Exercise], modelContext: ModelContext) {
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 25, hour: 16, minute: 57, second: 5))!

        // Leg Raises: 4 sets
        addSet(exercise: exercises["Leg Raises"]!, weight: 48.5, reps: 10,
               timestamp: baseDate, context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 48.5, reps: 13,
               timestamp: baseDate.addingTimeInterval(57), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(3*60 + 4), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(4*60 + 27), context: modelContext)

        // Hamstring Curls: 1 set (warm-up)
        addWarmUpSet(exercise: exercises["Hamstring Curls"]!, weight: 32.0, reps: 14,
                     timestamp: baseDate.addingTimeInterval(7*60 + 25), context: modelContext)

        // Calf Raises: 2 sets
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(10*60 + 21), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(11*60 + 42), context: modelContext)

        // Barbell squat: 5 sets (1 warm-up + 4 working)
        addWarmUpSet(exercise: exercises["Barbell squat"]!, weight: 20.0, reps: 15,
                     timestamp: baseDate.addingTimeInterval(15*60 + 59), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 40.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(18*60 + 26), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(22*60 + 34), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(22*60 + 39), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: baseDate.addingTimeInterval(24*60 + 49), context: modelContext)

        // Barbell Lunges: 3 sets
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: baseDate.addingTimeInterval(28*60 + 31), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: baseDate.addingTimeInterval(31*60 + 1), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: baseDate.addingTimeInterval(35*60 + 45), context: modelContext)

        // Sled Push: 2 sets
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 1,
               timestamp: baseDate.addingTimeInterval(35*60 + 58), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 1,
               timestamp: baseDate.addingTimeInterval(37*60 + 28), context: modelContext)

        // Hamstring Curls: 3 sets (working sets)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 11,
               timestamp: baseDate.addingTimeInterval(44*60 + 17), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 14,
               timestamp: baseDate.addingTimeInterval(45*60 + 23), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(49*60 + 11), context: modelContext)

        // Knees to toe: 3 sets
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(51*60 + 26), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(52*60 + 51), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 9,
               timestamp: baseDate.addingTimeInterval(55*60 + 3), context: modelContext)
    }

    // MARK: - Session 4: 2025-09-26 16:16:57 (Shoulders & Core)

    private static func generateSession4(exercises: [String: Exercise], modelContext: ModelContext) {
        let baseDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 26, hour: 16, minute: 16, second: 57))!

        // Dumbbell lateral raises: 3 sets
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 12,
               timestamp: baseDate, context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 13,
               timestamp: baseDate.addingTimeInterval(2*60 + 12), context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 15,
               timestamp: baseDate.addingTimeInterval(5*60 + 20), context: modelContext)

        // Single cable lateral raise: 3 sets
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 15.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(8*60 + 15), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(10*60 + 25), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(13*60 + 25), context: modelContext)

        // Front lateral cable raise: 3 sets
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 17.5, reps: 12,
               timestamp: baseDate.addingTimeInterval(17*60 + 12), context: modelContext)
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 23.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(18*60 + 50), context: modelContext)
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 23.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(20*60 + 58), context: modelContext)

        // Seated dumbbell Arnold press: 4 sets
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 7.5, reps: 10,
               timestamp: baseDate.addingTimeInterval(23*60 + 2), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(24*60 + 28), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 10,
               timestamp: baseDate.addingTimeInterval(26*60 + 48), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 12,
               timestamp: baseDate.addingTimeInterval(30*60 + 41), context: modelContext)

        // Upright cable row: 3 sets
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(34*60 + 21), context: modelContext)
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(36*60 + 47), context: modelContext)
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(38*60 + 31), context: modelContext)

        // Butterfly sit up: 2 sets
        addSet(exercise: exercises["Butterfly sit up"]!, weight: 0.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(40*60 + 36), context: modelContext)
        addSet(exercise: exercises["Butterfly sit up"]!, weight: 0.0, reps: 15,
               timestamp: baseDate.addingTimeInterval(42*60 + 30), context: modelContext)
    }

    // MARK: - Helper Methods

    private static func addSet(exercise: Exercise, weight: Double, reps: Int, timestamp: Date, context: ModelContext) {
        let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, exercise: exercise)
        context.insert(set)
    }

    private static func addWarmUpSet(exercise: Exercise, weight: Double, reps: Int, timestamp: Date, context: ModelContext) {
        let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, exercise: exercise)
        set.isWarmUp = true
        context.insert(set)
    }

    private static func clearAllData(modelContext: ModelContext) {
        do {
            // Delete all sets first (to avoid constraint issues)
            try modelContext.delete(model: ExerciseSet.self)
            // Then delete all exercises
            try modelContext.delete(model: Exercise.self)
            try modelContext.save()
        } catch {
            print("Error clearing existing data: \(error)")
        }
    }
}

#endif