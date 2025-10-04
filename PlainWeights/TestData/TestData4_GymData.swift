//
//  TestData4_GymData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//  Last Updated: 4 Oct 2025 at 13:14:03
//
//  Test Data Set 4: Real Gym Data
//  33 exercises, 12 workout sessions (Sep 22 - Oct 4, 2025)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData4_GymData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData4_GymData")
        logger.info("Generating Test Data Set 4 (Real gym data - 33 exercises, 12 sessions)...")

        // Clear existing data
        clearAllData(modelContext: modelContext)

        generateGymData(modelContext: modelContext)
        logger.info("Test Data Set 4 generation completed")
    }

    // MARK: - Data Generation

    private static func generateGymData(modelContext: ModelContext) {
        // Exercise definitions with notes (Updated: 4 Oct 2025)
        let exerciseData: [(name: String, category: String, note: String?)] = [
            (name: "Seated Incline Dumbell Curls", category: "Bicep", note: nil),
            (name: "Barbell squat", category: "Legs", note: nil),
            (name: "Knees to toe", category: "Core", note: nil),
            (name: "Barbell Lunges", category: "Legs", note: nil),
            (name: "Hamstring Curls", category: "Legs", note: "5 is 37.5 and 6 is 43kg"),
            (name: "Sled Push", category: "Legs", note: nil),
            (name: "T Bar Row", category: "Back", note: nil),
            (name: "Rope Bicep Curls", category: "Bicep", note: "7 is 39.5kg, 8 is 45kg"),
            (name: "Leg Raises", category: "Legs", note: "5 is 37.5, 7 is 48.5, 8 is 54"),
            (name: "Reverse Cable Flys", category: "Back", note: nil),
            (name: "Pull Ups", category: "Back", note: nil),
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
            (name: "Straight arm cable pulldown", category: "Back", note: nil),
            (name: "Reverse dumbbell flys", category: "Back", note: nil),
            (name: "Dumbbell shoulder press", category: "Shoulders", note: nil),
            (name: "Dumbbell shoulder shrugs", category: "Shoulders", note: nil),
            (name: "Hyper extensions", category: "Back", note: nil),
            (name: "Incline machine chest press", category: "Chest", note: nil),
            (name: "Seated cable row", category: "Back", note: "8 is 54kg"),
        ]

        // Create exercises
        var exercises: [String: Exercise] = [:]
        for (name, category, note) in exerciseData {
            let exercise = Exercise(name: name, category: category, note: note)
            exercises[name] = exercise
            modelContext.insert(exercise)
        }

        // Generate all 12 sessions
        generateSession1(exercises: exercises, modelContext: modelContext)
        generateSession2(exercises: exercises, modelContext: modelContext)
        generateSession3(exercises: exercises, modelContext: modelContext)
        generateSession4(exercises: exercises, modelContext: modelContext)
        generateSession5(exercises: exercises, modelContext: modelContext)
        generateSession6(exercises: exercises, modelContext: modelContext)
        generateSession7(exercises: exercises, modelContext: modelContext)
        generateSession8(exercises: exercises, modelContext: modelContext)
        generateSession9(exercises: exercises, modelContext: modelContext)
        generateSession10(exercises: exercises, modelContext: modelContext)
        generateSession11(exercises: exercises, modelContext: modelContext)
        generateSession12(exercises: exercises, modelContext: modelContext)

        // Save all data
        do {
            try modelContext.save()
        } catch {
            print("Error saving test data: \(error)")
        }
    }

    // MARK: - SESSION 1: 2025-09-22 17:00:00 (Chest, Triceps, Legs)

    private static func generateSession1(exercises: [String: Exercise], modelContext: ModelContext) {
        // Chest Press: 4 sets
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 0, 0), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 3, 0), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 5, 0), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 5, 0), context: modelContext)

        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 10, 0), context: modelContext)
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 13, 0), context: modelContext)
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: date(2025, 9, 22, 17, 15, 0), context: modelContext)

        // Chest Cable Flys: 3 sets
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 9, 22, 17, 17, 0), context: modelContext)
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 9, 22, 17, 20, 0), context: modelContext)
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 9, 22, 17, 23, 0), context: modelContext)

        // Tricep Dips: 3 sets
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: date(2025, 9, 22, 17, 25, 0), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: date(2025, 9, 22, 17, 30, 0), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: date(2025, 9, 22, 17, 33, 0), context: modelContext)

        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 22, 17, 35, 0), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 22, 17, 37, 0), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 22, 17, 40, 0), context: modelContext)

        // Barbell squat: 3 sets
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 0, 0), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 3, 0), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 5, 0), context: modelContext)

        // Barbell Lunges: 3 sets
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 6, 0), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 9, 0), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 12, 0), context: modelContext)

        // Sled Push: 3 sets
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: date(2025, 9, 22, 18, 15, 0), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: date(2025, 9, 22, 18, 17, 0), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 20,
               timestamp: date(2025, 9, 22, 18, 20, 0), context: modelContext)

        // Hamstring Curls: 3 sets
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 24, 0), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 26, 0), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 34.0, reps: 10,
               timestamp: date(2025, 9, 22, 18, 30, 0), context: modelContext)

        // Leg Raises: 3 sets
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: date(2025, 9, 22, 18, 32, 0), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: date(2025, 9, 22, 18, 35, 0), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 39.5, reps: 10,
               timestamp: date(2025, 9, 22, 18, 38, 0), context: modelContext)

        // Calf Raises: 3 sets
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 40, 0), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 43, 0), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 12,
               timestamp: date(2025, 9, 22, 18, 45, 0), context: modelContext)
    }

    // MARK: - SESSION 2: 2025-09-24 17:00:00 (Back & Biceps)

    private static func generateSession2(exercises: [String: Exercise], modelContext: ModelContext) {
        // Pull Ups: 2 sets
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 5,
               timestamp: date(2025, 9, 24, 17, 0, 0), context: modelContext)
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 5,
               timestamp: date(2025, 9, 24, 17, 2, 0), context: modelContext)

        // T Bar Row: 4 sets
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 3, 30), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 7, 0), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 9, 0), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 11, 0), context: modelContext)

        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 14, 0), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 16, 0), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 18, 0), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 20, 0), context: modelContext)

        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 22, 30), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 25, 0), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 27, 30), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 30, 0), context: modelContext)

        // Rope Face Pulls: 3 sets
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 32, 30), context: modelContext)
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 34, 30), context: modelContext)
        addSet(exercise: exercises["Rope Face Pulls"]!, weight: 45.0, reps: 10,
               timestamp: date(2025, 9, 24, 17, 36, 30), context: modelContext)

        // Rope Bicep Curls: 4 sets
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 24, 17, 39, 0), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 24, 17, 41, 30), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 24, 17, 44, 0), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 39.5, reps: 12,
               timestamp: date(2025, 9, 24, 17, 46, 30), context: modelContext)

        // Reverse Cable Flys: 3 sets
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: date(2025, 9, 24, 17, 49, 0), context: modelContext)
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: date(2025, 9, 24, 17, 51, 30), context: modelContext)
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: date(2025, 9, 24, 17, 54, 0), context: modelContext)

        // Knees to toe: 3 sets
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: date(2025, 9, 24, 20, 47, 30), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: date(2025, 9, 24, 20, 48, 30), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: date(2025, 9, 24, 20, 49, 30), context: modelContext)
    }

    // MARK: - SESSION 3: 2025-09-25 16:57:05 (Legs)

    private static func generateSession3(exercises: [String: Exercise], modelContext: ModelContext) {
        // Leg Raises: 4 sets
        addSet(exercise: exercises["Leg Raises"]!, weight: 48.5, reps: 10,
               timestamp: date(2025, 9, 25, 16, 57, 5), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 48.5, reps: 13,
               timestamp: date(2025, 9, 25, 16, 58, 2), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 10,
               timestamp: date(2025, 9, 25, 17, 0, 9), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 10,
               timestamp: date(2025, 9, 25, 17, 1, 32), context: modelContext)

        // Hamstring Curls: 1 set (warm-up)
        addWarmUpSet(exercise: exercises["Hamstring Curls"]!, weight: 32.0, reps: 14,
                     timestamp: date(2025, 9, 25, 17, 4, 30), context: modelContext)

        // Calf Raises: 2 sets
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 15,
               timestamp: date(2025, 9, 25, 17, 7, 26), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 40.0, reps: 15,
               timestamp: date(2025, 9, 25, 17, 8, 47), context: modelContext)

        // Barbell squat: 5 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Barbell squat"]!, weight: 20.0, reps: 15,
                     timestamp: date(2025, 9, 25, 17, 13, 4), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 40.0, reps: 8,
               timestamp: date(2025, 9, 25, 17, 15, 31), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: date(2025, 9, 25, 17, 19, 39), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: date(2025, 9, 25, 17, 19, 44), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 8,
               timestamp: date(2025, 9, 25, 17, 21, 54), context: modelContext)

        // Barbell Lunges: 3 sets
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: date(2025, 9, 25, 17, 25, 36), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: date(2025, 9, 25, 17, 28, 6), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 9,
               timestamp: date(2025, 9, 25, 17, 32, 50), context: modelContext)

        // Sled Push: 2 sets
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 1,
               timestamp: date(2025, 9, 25, 17, 33, 3), context: modelContext)
        addSet(exercise: exercises["Sled Push"]!, weight: 50.0, reps: 1,
               timestamp: date(2025, 9, 25, 17, 34, 33), context: modelContext)

        // Hamstring Curls: 3 sets (working)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 11,
               timestamp: date(2025, 9, 25, 17, 41, 22), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 14,
               timestamp: date(2025, 9, 25, 17, 42, 28), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 12,
               timestamp: date(2025, 9, 25, 17, 46, 16), context: modelContext)

        // Knees to toe: 3 sets
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: date(2025, 9, 25, 17, 48, 31), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 10,
               timestamp: date(2025, 9, 25, 17, 49, 56), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 9,
               timestamp: date(2025, 9, 25, 17, 52, 8), context: modelContext)
    }

    // MARK: - SESSION 4: 2025-09-26 16:16:57 (Shoulders & Core)

    private static func generateSession4(exercises: [String: Exercise], modelContext: ModelContext) {
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 12,
               timestamp: date(2025, 9, 26, 16, 16, 57), context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 13,
               timestamp: date(2025, 9, 26, 16, 19, 9), context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 7.5, reps: 15,
               timestamp: date(2025, 9, 26, 16, 22, 17), context: modelContext)

        // Single cable lateral raise: 3 sets
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 15.0, reps: 12,
               timestamp: date(2025, 9, 26, 16, 25, 12), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 9, 26, 16, 27, 22), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 9, 26, 16, 30, 22), context: modelContext)

        // Front lateral cable raise: 3 sets
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 17.5, reps: 12,
               timestamp: date(2025, 9, 26, 16, 34, 9), context: modelContext)
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 23.0, reps: 10,
               timestamp: date(2025, 9, 26, 16, 35, 47), context: modelContext)
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 23.0, reps: 10,
               timestamp: date(2025, 9, 26, 16, 37, 55), context: modelContext)

        // Seated dumbbell Arnold press: 4 sets
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 7.5, reps: 10,
               timestamp: date(2025, 9, 26, 16, 39, 59), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 26, 16, 41, 25), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 26, 16, 43, 45), context: modelContext)
        addSet(exercise: exercises["Seated dumbbell Arnold press"]!, weight: 10.0, reps: 12,
               timestamp: date(2025, 9, 26, 16, 47, 38), context: modelContext)

        // Upright cable row: 3 sets
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: date(2025, 9, 26, 16, 51, 18), context: modelContext)
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: date(2025, 9, 26, 16, 53, 44), context: modelContext)
        addSet(exercise: exercises["Upright cable row"]!, weight: 34.0, reps: 15,
               timestamp: date(2025, 9, 26, 16, 55, 28), context: modelContext)

        // Butterfly sit up: 2 sets
        addSet(exercise: exercises["Butterfly sit up"]!, weight: 0.0, reps: 15,
               timestamp: date(2025, 9, 26, 16, 57, 33), context: modelContext)
        addSet(exercise: exercises["Butterfly sit up"]!, weight: 0.0, reps: 15,
               timestamp: date(2025, 9, 26, 16, 59, 27), context: modelContext)
    }

    // MARK: - SESSION 5: 2025-09-27 16:41:23 (Chest & Triceps)

    private static func generateSession5(exercises: [String: Exercise], modelContext: ModelContext) {
        // Chest Press: 6 sets (2 warm-up)
        addWarmUpSet(exercise: exercises["Chest Press"]!, weight: 20.0, reps: 10,
                     timestamp: date(2025, 9, 27, 16, 41, 23), context: modelContext)
        addWarmUpSet(exercise: exercises["Chest Press"]!, weight: 40.0, reps: 8,
                     timestamp: date(2025, 9, 27, 16, 41, 36), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 5,
               timestamp: date(2025, 9, 27, 16, 44, 32), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 6,
               timestamp: date(2025, 9, 27, 16, 46, 53), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 8,
               timestamp: date(2025, 9, 27, 16, 49, 41), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 7,
               timestamp: date(2025, 9, 27, 16, 52, 45), context: modelContext)

        // Incline Dumbbell Chest Press: 4 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 17.5, reps: 8,
                     timestamp: date(2025, 9, 27, 16, 55, 12), context: modelContext)
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 10,
               timestamp: date(2025, 9, 27, 16, 56, 47), context: modelContext)
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 11,
               timestamp: date(2025, 9, 27, 17, 0, 12), context: modelContext)
        addSet(exercise: exercises["Incline Dumbbell Chest Press"]!, weight: 20.0, reps: 11,
               timestamp: date(2025, 9, 27, 17, 3, 31), context: modelContext)

        // Dumbbell flys: 3 sets
        addSet(exercise: exercises["Dumbbell flys"]!, weight: 12.5, reps: 7,
               timestamp: date(2025, 9, 27, 17, 5, 27), context: modelContext)
        addSet(exercise: exercises["Dumbbell flys"]!, weight: 12.5, reps: 14,
               timestamp: date(2025, 9, 27, 17, 8, 59), context: modelContext)
        addSet(exercise: exercises["Dumbbell flys"]!, weight: 12.5, reps: 10,
               timestamp: date(2025, 9, 27, 17, 12, 57), context: modelContext)

        // Tricep Dips: 4 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Tricep Dips"]!, weight: 0.0, reps: 8,
                     timestamp: date(2025, 9, 27, 17, 15, 10), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 7,
               timestamp: date(2025, 9, 27, 17, 17, 1), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 7,
               timestamp: date(2025, 9, 27, 17, 19, 23), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 7,
               timestamp: date(2025, 9, 27, 17, 21, 59), context: modelContext)

        // Overhead Tricep Rope Pulls: 5 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 28.5, reps: 10,
                     timestamp: date(2025, 9, 27, 17, 24, 57), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 34.0, reps: 12,
               timestamp: date(2025, 9, 27, 17, 27, 11), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 8,
               timestamp: date(2025, 9, 27, 17, 29, 38), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 6,
               timestamp: date(2025, 9, 27, 17, 31, 31), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 8,
               timestamp: date(2025, 9, 27, 17, 34, 3), context: modelContext)
    }

    // MARK: - SESSION 6: 2025-09-29 16:56:48 (Back & Biceps)

    private static func generateSession6(exercises: [String: Exercise], modelContext: ModelContext) {
        // Pull Ups: 4 sets
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 4,
               timestamp: date(2025, 9, 29, 16, 56, 48), context: modelContext)
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 4,
               timestamp: date(2025, 9, 29, 16, 58, 28), context: modelContext)
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 5,
               timestamp: date(2025, 9, 29, 17, 1, 0), context: modelContext)
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 6,
               timestamp: date(2025, 9, 29, 17, 4, 1), context: modelContext)

        // Straight arm cable pulldown: 3 sets
        addSet(exercise: exercises["Straight arm cable pulldown"]!, weight: 45.0, reps: 13,
               timestamp: date(2025, 9, 29, 17, 6, 7), context: modelContext)
        addSet(exercise: exercises["Straight arm cable pulldown"]!, weight: 47.5, reps: 12,
               timestamp: date(2025, 9, 29, 17, 8, 3), context: modelContext)
        addSet(exercise: exercises["Straight arm cable pulldown"]!, weight: 47.5, reps: 10,
               timestamp: date(2025, 9, 29, 17, 10, 0), context: modelContext)

        // T Bar Row: 4 sets
        addSet(exercise: exercises["T Bar Row"]!, weight: 25.0, reps: 9,
               timestamp: date(2025, 9, 29, 17, 11, 39), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 30.0, reps: 9,
               timestamp: date(2025, 9, 29, 17, 13, 40), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 30.0, reps: 10,
               timestamp: date(2025, 9, 29, 17, 15, 59), context: modelContext)
        addSet(exercise: exercises["T Bar Row"]!, weight: 30.0, reps: 10,
               timestamp: date(2025, 9, 29, 17, 18, 59), context: modelContext)

        // Reverse dumbbell flys: 2 sets
        addSet(exercise: exercises["Reverse dumbbell flys"]!, weight: 10.0, reps: 12,
               timestamp: date(2025, 9, 29, 17, 23, 8), context: modelContext)
        addSet(exercise: exercises["Reverse dumbbell flys"]!, weight: 12.0, reps: 12,
               timestamp: date(2025, 9, 29, 17, 24, 57), context: modelContext)

        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 11,
               timestamp: date(2025, 9, 29, 17, 30, 21), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 9, 29, 17, 32, 0), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 11,
               timestamp: date(2025, 9, 29, 17, 35, 9), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 11,
               timestamp: date(2025, 9, 29, 17, 38, 39), context: modelContext)

        // Rope Bicep Curls: 4 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Rope Bicep Curls"]!, weight: 42.0, reps: 14,
                     timestamp: date(2025, 9, 29, 17, 40, 14), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 45.0, reps: 9,
               timestamp: date(2025, 9, 29, 17, 41, 54), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 45.0, reps: 9,
               timestamp: date(2025, 9, 29, 17, 43, 4), context: modelContext)
        addSet(exercise: exercises["Rope Bicep Curls"]!, weight: 45.0, reps: 9,
               timestamp: date(2025, 9, 29, 17, 45, 12), context: modelContext)
    }

    // MARK: - SESSION 7: 2025-09-29 20:51:28 (Back - Single Exercise)

    private static func generateSession7(exercises: [String: Exercise], modelContext: ModelContext) {
        // Reverse dumbbell flys: 1 set
        addSet(exercise: exercises["Reverse dumbbell flys"]!, weight: 10.0, reps: 15,
               timestamp: date(2025, 9, 29, 20, 51, 28), context: modelContext)
    }

    // MARK: - SESSION 8: 2025-09-30 16:48:49 (Legs)

    private static func generateSession8(exercises: [String: Exercise], modelContext: ModelContext) {
        // Barbell squat: 5 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Barbell squat"]!, weight: 20.0, reps: 15,
                     timestamp: date(2025, 9, 30, 16, 48, 49), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 30, 16, 51, 24), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 30, 16, 54, 4), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 30, 16, 56, 13), context: modelContext)
        addSet(exercise: exercises["Barbell squat"]!, weight: 50.0, reps: 10,
               timestamp: date(2025, 9, 30, 16, 58, 25), context: modelContext)

        // Barbell Lunges: 3 sets
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 30, 17, 0, 30), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 30, 17, 4, 10), context: modelContext)
        addSet(exercise: exercises["Barbell Lunges"]!, weight: 30.0, reps: 12,
               timestamp: date(2025, 9, 30, 17, 7, 30), context: modelContext)

        // Hamstring Curls: 5 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Hamstring Curls"]!, weight: 32.0, reps: 14,
                     timestamp: date(2025, 9, 30, 17, 11, 9), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 14,
               timestamp: date(2025, 9, 30, 17, 12, 28), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 37.5, reps: 16,
               timestamp: date(2025, 9, 30, 17, 14, 0), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 43.0, reps: 13,
               timestamp: date(2025, 9, 30, 17, 15, 31), context: modelContext)
        addSet(exercise: exercises["Hamstring Curls"]!, weight: 43.0, reps: 13,
               timestamp: date(2025, 9, 30, 17, 17, 23), context: modelContext)

        // Leg Raises: 4 sets
        addSet(exercise: exercises["Leg Raises"]!, weight: 37.5, reps: 11,
               timestamp: date(2025, 9, 30, 17, 19, 5), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 48.5, reps: 10,
               timestamp: date(2025, 9, 30, 17, 20, 2), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 8,
               timestamp: date(2025, 9, 30, 17, 21, 33), context: modelContext)
        addSet(exercise: exercises["Leg Raises"]!, weight: 54.0, reps: 10,
               timestamp: date(2025, 9, 30, 17, 23, 15), context: modelContext)

        // Calf Raises: 3 sets
        addSet(exercise: exercises["Calf Raises"]!, weight: 45.0, reps: 15,
               timestamp: date(2025, 9, 30, 17, 25, 5), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 45.0, reps: 15,
               timestamp: date(2025, 9, 30, 17, 26, 46), context: modelContext)
        addSet(exercise: exercises["Calf Raises"]!, weight: 45.0, reps: 15,
               timestamp: date(2025, 9, 30, 17, 28, 16), context: modelContext)
    }

    // MARK: - SESSION 9: 2025-10-01 20:19:17 (Shoulders & Core)

    private static func generateSession9(exercises: [String: Exercise], modelContext: ModelContext) {
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 10, 1, 20, 19, 17), context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 10.0, reps: 12,
               timestamp: date(2025, 10, 1, 20, 21, 22), context: modelContext)
        addSet(exercise: exercises["Dumbbell lateral raises"]!, weight: 10.0, reps: 10,
               timestamp: date(2025, 10, 1, 20, 25, 30), context: modelContext)

        // Dumbbell shoulder press: 2 sets
        addSet(exercise: exercises["Dumbbell shoulder press"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 10, 1, 20, 27, 20), context: modelContext)
        addSet(exercise: exercises["Dumbbell shoulder press"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 10, 1, 20, 30, 46), context: modelContext)

        // Single cable lateral raise: 3 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Single cable lateral raise"]!, weight: 15.0, reps: 10,
                     timestamp: date(2025, 10, 1, 20, 37, 12), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 10, 1, 20, 38, 10), context: modelContext)
        addSet(exercise: exercises["Single cable lateral raise"]!, weight: 17.5, reps: 10,
               timestamp: date(2025, 10, 1, 20, 40, 23), context: modelContext)

        // Front lateral cable raise: 1 set
        addSet(exercise: exercises["Front lateral cable raise"]!, weight: 23.0, reps: 10,
               timestamp: date(2025, 10, 1, 20, 46, 1), context: modelContext)

        // Dumbbell shoulder shrugs: 1 set
        addSet(exercise: exercises["Dumbbell shoulder shrugs"]!, weight: 22.5, reps: 12,
               timestamp: date(2025, 10, 1, 20, 50, 58), context: modelContext)

        // Knees to toe: 3 sets
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 11,
               timestamp: date(2025, 10, 1, 20, 56, 5), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 11,
               timestamp: date(2025, 10, 1, 20, 58, 31), context: modelContext)
        addSet(exercise: exercises["Knees to toe"]!, weight: 0.0, reps: 11,
               timestamp: date(2025, 10, 1, 21, 0, 55), context: modelContext)

        // Hyper extensions: 3 sets
        addSet(exercise: exercises["Hyper extensions"]!, weight: 0.0, reps: 11,
               timestamp: date(2025, 10, 1, 21, 9, 45), context: modelContext)
        addSet(exercise: exercises["Hyper extensions"]!, weight: 0.0, reps: 12,
               timestamp: date(2025, 10, 1, 21, 11, 10), context: modelContext)
        addSet(exercise: exercises["Hyper extensions"]!, weight: 0.0, reps: 12,
               timestamp: date(2025, 10, 1, 21, 13, 8), context: modelContext)
    }

    // MARK: - SESSION 10: 2025-10-02 16:12:52 (Chest & Triceps)

    private static func generateSession10(exercises: [String: Exercise], modelContext: ModelContext) {
        // Chest Press: 5 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Chest Press"]!, weight: 40.0, reps: 9,
                     timestamp: date(2025, 10, 2, 16, 12, 52), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 7,
               timestamp: date(2025, 10, 2, 16, 14, 54), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 7,
               timestamp: date(2025, 10, 2, 16, 17, 30), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 6,
               timestamp: date(2025, 10, 2, 16, 19, 59), context: modelContext)
        addSet(exercise: exercises["Chest Press"]!, weight: 55.0, reps: 7,
               timestamp: date(2025, 10, 2, 16, 22, 51), context: modelContext)

        // Incline machine chest press: 2 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Incline machine chest press"]!, weight: 20.0, reps: 10,
                     timestamp: date(2025, 10, 2, 16, 25, 59), context: modelContext)
        addSet(exercise: exercises["Incline machine chest press"]!, weight: 30.0, reps: 8,
               timestamp: date(2025, 10, 2, 16, 28, 18), context: modelContext)

        // Chest Cable Flys: 4 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Chest Cable Flys"]!, weight: 15.0, reps: 15,
                     timestamp: date(2025, 10, 2, 16, 35, 43), context: modelContext)
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 15,
               timestamp: date(2025, 10, 2, 16, 37, 38), context: modelContext)
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 15,
               timestamp: date(2025, 10, 2, 16, 39, 24), context: modelContext)
        addSet(exercise: exercises["Chest Cable Flys"]!, weight: 17.5, reps: 15,
               timestamp: date(2025, 10, 2, 16, 40, 55), context: modelContext)

        // Incline machine chest press: 2 sets (more working sets)
        addSet(exercise: exercises["Incline machine chest press"]!, weight: 30.0, reps: 10,
               timestamp: date(2025, 10, 2, 16, 44, 8), context: modelContext)
        addSet(exercise: exercises["Incline machine chest press"]!, weight: 30.0, reps: 10,
               timestamp: date(2025, 10, 2, 16, 44, 13), context: modelContext)

        // Tricep Dips: 4 sets (1 warm-up)
        addWarmUpSet(exercise: exercises["Tricep Dips"]!, weight: 0.0, reps: 8,
                     timestamp: date(2025, 10, 2, 16, 45, 5), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: date(2025, 10, 2, 16, 46, 50), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 8,
               timestamp: date(2025, 10, 2, 16, 50, 5), context: modelContext)
        addSet(exercise: exercises["Tricep Dips"]!, weight: 5.0, reps: 7,
               timestamp: date(2025, 10, 2, 16, 52, 55), context: modelContext)

        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 39.5, reps: 10,
               timestamp: date(2025, 10, 2, 16, 57, 27), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 9,
               timestamp: date(2025, 10, 2, 16, 59, 14), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 9,
               timestamp: date(2025, 10, 2, 17, 1, 16), context: modelContext)
        addSet(exercise: exercises["Overhead Tricep Rope Pulls"]!, weight: 42.0, reps: 9,
               timestamp: date(2025, 10, 2, 17, 3, 41), context: modelContext)
    }

    // MARK: - SESSION 11: 2025-10-02 20:28:56 (Back - Single Exercise)

    private static func generateSession11(exercises: [String: Exercise], modelContext: ModelContext) {
        // T Bar Row: 1 set
        addSet(exercise: exercises["T Bar Row"]!, weight: 30.0, reps: 10,
               timestamp: date(2025, 10, 2, 20, 28, 56), context: modelContext)
    }

    // MARK: - SESSION 12: 2025-10-04 10:08:18 (Back & Biceps)

    private static func generateSession12(exercises: [String: Exercise], modelContext: ModelContext) {
        // Reverse Cable Flys: 1 set
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 9,
               timestamp: date(2025, 10, 4, 10, 8, 18), context: modelContext)

        // Pull Ups: 1 set
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 5,
               timestamp: date(2025, 10, 4, 10, 9, 57), context: modelContext)

        // Reverse Cable Flys: 1 set
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 15.0, reps: 12,
               timestamp: date(2025, 10, 4, 10, 11, 10), context: modelContext)

        // Pull Ups: 1 set
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 6,
               timestamp: date(2025, 10, 4, 10, 12, 43), context: modelContext)

        // Reverse Cable Flys: 1 set
        addSet(exercise: exercises["Reverse Cable Flys"]!, weight: 17.5, reps: 8,
               timestamp: date(2025, 10, 4, 10, 14, 34), context: modelContext)

        // Pull Ups: 2 sets
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 6,
               timestamp: date(2025, 10, 4, 10, 15, 59), context: modelContext)
        addSet(exercise: exercises["Pull Ups"]!, weight: 0.0, reps: 6,
               timestamp: date(2025, 10, 4, 10, 17, 39), context: modelContext)

        // Seated cable row: 1 set
        addSet(exercise: exercises["Seated cable row"]!, weight: 54.0, reps: 10,
               timestamp: date(2025, 10, 4, 10, 21, 42), context: modelContext)

        // Deadlifts (Trapbar): 3 sets
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 60.0, reps: 10,
               timestamp: date(2025, 10, 4, 10, 26, 16), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 65.0, reps: 10,
               timestamp: date(2025, 10, 4, 10, 28, 3), context: modelContext)
        addSet(exercise: exercises["Deadlifts (Trapbar)"]!, weight: 65.0, reps: 10,
               timestamp: date(2025, 10, 4, 10, 31, 47), context: modelContext)

        // Seated Incline Dumbell Curls: 4 sets
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 11,
               timestamp: date(2025, 10, 4, 10, 32, 58), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 12,
               timestamp: date(2025, 10, 4, 10, 35, 38), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 10.0, reps: 12,
               timestamp: date(2025, 10, 4, 10, 38, 16), context: modelContext)
        addSet(exercise: exercises["Seated Incline Dumbell Curls"]!, weight: 12.5, reps: 6,
               timestamp: date(2025, 10, 4, 10, 39, 52), context: modelContext)
    }

    // MARK: - Helper Methods

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second))!
    }

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
