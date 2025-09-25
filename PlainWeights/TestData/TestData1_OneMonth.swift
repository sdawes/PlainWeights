//
//  TestData1_OneMonth.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//
//  Test Data Set 1: 1 Month Realistic Workout Data
//  20 exercises, typical gym routine with progressive overload

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData1_OneMonth {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData1_OneMonth")
        logger.info("Generating Test Data Set 1 (1 month realistic workout data)...")
        generateSet1Data(modelContext: modelContext)
    }

    // MARK: - Test Data Set 1: 1 Month Realistic Workout Data
    // 20 exercises, typical gym routine, progressive overload

    private static func generateSet1Data(modelContext: ModelContext) {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()

        // Create exercises with categories
        let exerciseData: [(String, String)] = [
            // Chest exercises
            ("Bench Press", "Chest"),
            ("Incline Dumbbell Press", "Chest"),
            ("Cable Flyes", "Chest"),
            ("Push-ups", "Chest"),

            // Back exercises
            ("Deadlift", "Back"),
            ("Pull-ups", "Back"),
            ("Barbell Row", "Back"),
            ("Lat Pulldown", "Back"),

            // Legs exercises
            ("Squat", "Legs"),
            ("Romanian Deadlift", "Legs"),
            ("Leg Press", "Legs"),
            ("Calf Raises", "Legs"),

            // Shoulders exercises
            ("Overhead Press", "Shoulders"),
            ("Lateral Raises", "Shoulders"),
            ("Face Pulls", "Shoulders"),

            // Arms exercises
            ("Barbell Curl", "Arms"),
            ("Hammer Curl", "Arms"),
            ("Tricep Dips", "Arms"),
            ("Cable Tricep Extension", "Arms"),

            // Core
            ("Plank", "Core")
        ]

        var exercises: [Exercise] = []
        for (name, category) in exerciseData {
            let exercise = Exercise(name: name, category: category, createdDate: startDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Generate workout sessions - Push/Pull/Legs split, 2x per week
        // Week 1
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 1, hour: 7, minute: 30),
                              exercises: [exercises[0], exercises[1], exercises[2], exercises[12], exercises[13], exercises[17], exercises[18]],
                              weights: [80, 35, 20, 50, 12, 0, 30],
                              reps: [[8,8,8,7], [10,10,9,8], [12,12,12], [8,8,6,6], [12,12,10], [8,8,8], [12,12,12]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 2, hour: 8, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [100, 0, 60, 80, 30, 15],
                              reps: [[5,5,4,3], [6,5,4], [8,8,7,6], [10,10,9,8], [10,10,8], [12,12,12]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 4, hour: 7, minute: 45),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11], exercises[19]],
                              weights: [90, 80, 200, 0, 60],
                              reps: [[10,8,8,6], [10,10,8,8], [12,12,12,10], [15,15,12], [20,20,20,15]],
                              modelContext: modelContext)

        // Week 1 - Second round
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 5, hour: 8, minute: 15),
                              exercises: [exercises[0], exercises[1], exercises[2], exercises[3], exercises[12], exercises[17]],
                              weights: [82, 37, 20, 0, 52, 32],
                              reps: [[8,8,8,8], [10,10,10,9], [12,12,12], [10,8,6], [8,8,7,6], [12,12,12]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 6, hour: 7, minute: 30),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[14], exercises[15]],
                              weights: [105, 0, 62, 15, 32],
                              reps: [[5,5,5,4], [7,6,5], [8,8,8,7], [12,12,10], [10,10,9]],
                              modelContext: modelContext)

        // Week 2
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 8, hour: 8, minute: 0),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11]],
                              weights: [95, 85, 210, 0],
                              reps: [[10,9,8,7], [10,10,9,8], [12,12,12,12], [16,15,14]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 10, hour: 7, minute: 45),
                              exercises: [exercises[0], exercises[1], exercises[13], exercises[18], exercises[19]],
                              weights: [85, 40, 15, 32, 62],
                              reps: [[8,8,8,8], [10,10,10,9], [12,12,12], [12,12,10], [20,20,18]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 12, hour: 8, minute: 30),
                              exercises: [exercises[4], exercises[5], exercises[7], exercises[15], exercises[16]],
                              weights: [110, 0, 85, 35, 17],
                              reps: [[5,5,5,5], [8,7,6], [10,10,10,9], [10,10,10], [12,12,12]],
                              modelContext: modelContext)

        // Week 3
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 15, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11], exercises[19]],
                              weights: [100, 90, 220, 0, 65],
                              reps: [[10,9,9,8], [10,10,10,9], [12,12,12,11], [17,16,15], [20,20,20]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 17, hour: 8, minute: 0),
                              exercises: [exercises[0], exercises[2], exercises[12], exercises[13], exercises[17]],
                              weights: [87, 22, 55, 17, 35],
                              reps: [[8,8,8,8], [12,12,12], [8,8,8,7], [12,12,12], [12,12,12]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 19, hour: 8, minute: 15),
                              exercises: [exercises[4], exercises[6], exercises[7], exercises[14], exercises[15]],
                              weights: [115, 65, 90, 17, 37],
                              reps: [[5,5,5,5], [8,8,8,8], [10,10,10,10], [12,12,11], [10,10,10]],
                              modelContext: modelContext)

        // Week 4 - Final week with PRs
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 22, hour: 7, minute: 45),
                              exercises: [exercises[8], exercises[9], exercises[10]],
                              weights: [105, 95, 240],
                              reps: [[10,10,9,8], [10,10,10,10], [12,12,12,12]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 24, hour: 8, minute: 0),
                              exercises: [exercises[0], exercises[1], exercises[12]],
                              weights: [90, 45, 60],
                              reps: [[8,8,8,8], [10,10,10,10], [8,8,8,8]],
                              modelContext: modelContext)

        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 26, hour: 8, minute: 30),
                              exercises: [exercises[4], exercises[5]],
                              weights: [120, 0],
                              reps: [[5,5,5,5], [10,9,8]],
                              modelContext: modelContext)

        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData1_OneMonth")
        logger.info("Test Data Set 1 generated: 20 exercises, ~76 sets over 4 weeks")
    }

    // MARK: - Helper Functions

    private static func generateWorkoutSession(date: Date, exercises: [Exercise], weights: [Double], reps: [[Int]], modelContext: ModelContext) {
        var currentTime = date

        for (index, exercise) in exercises.enumerated() {
            let weight = weights[index]
            let exerciseReps = reps[index]

            for repCount in exerciseReps {
                let set = ExerciseSet(timestamp: currentTime, weight: weight, reps: repCount, exercise: exercise)
                modelContext.insert(set)
                currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
            }
            // Rest between exercises
            currentTime = Calendar.current.date(byAdding: .minute, value: 3, to: currentTime) ?? currentTime
        }
    }

    private static func dateFrom(_ baseDate: Date, daysOffset: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysOffset, to: baseDate) ?? baseDate
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}
#endif