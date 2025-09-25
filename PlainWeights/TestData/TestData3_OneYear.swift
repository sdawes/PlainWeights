//
//  TestData3_OneYear.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//
//  Test Data Set 3: 1 Year Performance Test Data
//  50 exercises across all categories with 60-100 sets each for performance testing

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData3_OneYear {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData3_OneYear")
        logger.info("Generating Test Data Set 3 (1 year performance test data)...")
        generateSet2Data(modelContext: modelContext)
    }

    // MARK: - Test Data Set 3: 1 Year Performance Test Data
    // 50 exercises, 60-100 sets per exercise for performance testing

    private static func generateSet2Data(modelContext: ModelContext) {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()

        // Create 50 exercises across all categories
        let exerciseData: [(String, String)] = [
            // Chest (8 exercises)
            ("Barbell Bench Press", "Chest"),
            ("Dumbbell Bench Press", "Chest"),
            ("Incline Barbell Press", "Chest"),
            ("Incline Dumbbell Press", "Chest"),
            ("Decline Bench Press", "Chest"),
            ("Cable Flyes", "Chest"),
            ("Pec Deck", "Chest"),
            ("Push-ups", "Chest"),

            // Back (10 exercises)
            ("Deadlift", "Back"),
            ("Sumo Deadlift", "Back"),
            ("Pull-ups", "Back"),
            ("Chin-ups", "Back"),
            ("Barbell Row", "Back"),
            ("T-Bar Row", "Back"),
            ("Cable Row", "Back"),
            ("Lat Pulldown", "Back"),
            ("Close-Grip Pulldown", "Back"),
            ("Shrugs", "Back"),

            // Legs (10 exercises)
            ("Back Squat", "Legs"),
            ("Front Squat", "Legs"),
            ("Bulgarian Split Squat", "Legs"),
            ("Romanian Deadlift", "Legs"),
            ("Leg Press", "Legs"),
            ("Leg Curl", "Legs"),
            ("Leg Extension", "Legs"),
            ("Walking Lunges", "Legs"),
            ("Calf Raises", "Legs"),
            ("Box Jumps", "Legs"),

            // Shoulders (7 exercises)
            ("Military Press", "Shoulders"),
            ("Dumbbell Shoulder Press", "Shoulders"),
            ("Arnold Press", "Shoulders"),
            ("Lateral Raises", "Shoulders"),
            ("Front Raises", "Shoulders"),
            ("Rear Delt Flyes", "Shoulders"),
            ("Face Pulls", "Shoulders"),

            // Arms (10 exercises)
            ("Barbell Curl", "Arms"),
            ("Dumbbell Curl", "Arms"),
            ("Hammer Curl", "Arms"),
            ("Preacher Curl", "Arms"),
            ("Cable Curl", "Arms"),
            ("Close-Grip Bench Press", "Arms"),
            ("Tricep Dips", "Arms"),
            ("Overhead Tricep Extension", "Arms"),
            ("Cable Tricep Extension", "Arms"),
            ("Diamond Push-ups", "Arms"),

            // Core (5 exercises)
            ("Plank", "Core"),
            ("Russian Twists", "Core"),
            ("Hanging Leg Raises", "Core"),
            ("Ab Wheel", "Core"),
            ("Cable Crunches", "Core")
        ]

        var exercises: [Exercise] = []
        for (name, category) in exerciseData {
            let exercise = Exercise(name: name, category: category, createdDate: startDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Hardcoded performance test data - 60-100 sets per exercise
        var sets: [ExerciseSet] = []

        // Generate sets for each exercise with realistic weights and reps
        for (index, exercise) in exercises.enumerated() {
            let setsCount = Int.random(in: 60...100)
            let baseWeight = getBaseWeight(for: exercise.category, index: index)

            for _ in 0..<setsCount {
                let variation = Double.random(in: 0.8...1.2)
                let weight = baseWeight * variation
                let reps = Int.random(in: 6...15)

                // Spread timestamps across past year
                let daysBack = Int.random(in: 1...365)
                let hoursBack = Int.random(in: 0...23)
                let minutesBack = Int.random(in: 0...59)
                let timestamp = calendar.date(byAdding: .day, value: -daysBack, to: Date())?
                    .addingTimeInterval(TimeInterval(-hoursBack * 3600 - minutesBack * 60)) ?? Date()

                let set = ExerciseSet(
                    timestamp: timestamp,
                    weight: weight,
                    reps: reps,
                    exercise: exercise
                )
                sets.append(set)
            }
        }

        // Insert all sets
        for set in sets {
            modelContext.insert(set)
        }

        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData3_OneYear")
        logger.info("Test Data Set 3 generated: 50 exercises, \(sets.count) total sets for performance testing")
    }

    // MARK: - Helper Functions

    private static func getBaseWeight(for category: String, index: Int) -> Double {
        switch category {
        case "Chest":
            return [80.0, 40.0, 85.0, 45.0, 75.0, 25.0, 30.0, 0.0][index % 8]
        case "Back":
            return [140.0, 120.0, 0.0, 0.0, 80.0, 70.0, 60.0, 55.0, 50.0, 90.0][index % 10]
        case "Legs":
            return [120.0, 100.0, 30.0, 90.0, 200.0, 50.0, 60.0, 25.0, 100.0, 0.0][index % 10]
        case "Shoulders":
            return [60.0, 35.0, 30.0, 15.0, 12.0, 20.0, 70.0][index % 7]
        case "Arms":
            return [65.0, 25.0, 40.0, 15.0, 35.0, 15.0, 80.0, 45.0][index % 8]
        case "Core":
            return [0.0, 0.0, 0.0, 20.0, 50.0][index % 5]
        case "Cardio":
            return [0.0, 0.0][index % 2]
        default:
            return 50.0 + Double(index) * 5.0
        }
    }
}
#endif