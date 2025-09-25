//
//  TestData2_TwoWeeks.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//
//  Test Data Set 2: 2 Weeks Simple Data
//  5 basic exercises for quick testing with 18 sets over 2 weeks

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData2_TwoWeeks {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData2_TwoWeeks")
        logger.info("Generating Test Data Set 2 (2 weeks simple data)...")
        generateSet3Data(modelContext: modelContext)
    }

    // MARK: - Test Data Set 2: 2 Weeks Simple Data
    // 5 basic exercises for quick testing

    private static func generateSet3Data(modelContext: ModelContext) {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date()

        // Create 7 basic exercises (including bodyweight)
        let exerciseData: [(String, String)] = [
            ("Bench Press", "Chest"),
            ("Squat", "Legs"),
            ("Deadlift", "Back"),
            ("Overhead Press", "Shoulders"),
            ("Pull-ups", "Back"),
            ("Push-ups", "Chest"),
            ("Tricep Dips", "Arms")
        ]

        var exercises: [Exercise] = []
        for (name, category) in exerciseData {
            let exercise = Exercise(name: name, category: category, createdDate: startDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Week 1 - Monday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 0, hour: 8, minute: 0),
                              exercises: [exercises[0], exercises[3], exercises[5]],
                              weights: [60, 40, 0],
                              reps: [[10,10,10], [10,10,10], [20,15,12]],
                              modelContext: modelContext)

        // Week 1 - Wednesday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 2, hour: 8, minute: 0),
                              exercises: [exercises[1], exercises[2], exercises[6]],
                              weights: [80, 100, 0],
                              reps: [[8,8,8], [5,5,5], [12,10,8]],
                              modelContext: modelContext)

        // Week 1 - Friday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 4, hour: 8, minute: 0),
                              exercises: [exercises[4], exercises[0]],
                              weights: [0, 65],
                              reps: [[8,6,5], [8,8,8]],
                              modelContext: modelContext)

        // Week 2 - Monday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 7, hour: 8, minute: 0),
                              exercises: [exercises[1], exercises[3], exercises[5]],
                              weights: [85, 42.5, 2.5],
                              reps: [[8,8,8], [10,10,10], [15,12,10]],
                              modelContext: modelContext)

        // Week 2 - Wednesday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 9, hour: 8, minute: 0),
                              exercises: [exercises[2], exercises[4], exercises[6]],
                              weights: [105, 2.5, 5],
                              reps: [[5,5,5], [7,6,5], [10,8,6]],
                              modelContext: modelContext)

        // Week 2 - Friday
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 11, hour: 8, minute: 0),
                              exercises: [exercises[0], exercises[1]],
                              weights: [67.5, 87.5],
                              reps: [[8,8,8], [8,8,8]],
                              modelContext: modelContext)

        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData2_TwoWeeks")
        logger.info("Test Data Set 2 generated: 5 exercises, 18 sets over 2 weeks")
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