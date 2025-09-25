//
//  TestData4_GymData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//
//  Test Data Set 4: Real Gym Data
//  14 exercises, 69 sets from actual gym sessions (Sep 22, 24, 25, 2025)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData4_GymData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData4_GymData")
        logger.info("Generating Test Data Set 4 (Real gym data)...")
        generateGymData(modelContext: modelContext)
    }

    // MARK: - Test Data Set 4: Real Gym Data
    // Real workout data from actual gym sessions

    private static func generateGymData(modelContext: ModelContext) {
        // Base date for gym data - Today's workout (Sep 24, 2025) at 17:00
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 17, minute: 0)) ?? Date()

        // Exercise definitions from gym data export
        let exerciseData: [(String, String)] = [
            ("Seated Incline Dumbell Curls", "Bicep"),
            ("Barbell squat", "Legs"),
            ("Knees to toe", "Core"),
            ("Barbell Lunges", "Legs"),
            ("Hamstring Curls", "Legs"),
            ("Sled Push", "Legs"),
            ("T Bar Row", "Back"),
            ("Rope Bicep Curls", "Bicep"),
            ("Leg Raises", "Legs"),
            ("Reverse Cable Flys", "Back"),
            ("Pull Up (Strict)", "Back"),
            ("Rope Face Pulls", "Back"),
            ("Calf Raises", "Legs"),
            ("Deadlifts (Trapbar)", "Back")
        ]

        var exercises: [Exercise] = []
        for (name, category) in exerciseData {
            let exercise = Exercise(name: name, category: category, createdDate: startDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Create dates for all workout sessions
        let sep22Date = calendar.date(from: DateComponents(year: 2025, month: 9, day: 22, hour: 18, minute: 0)) ?? Date()
        let sep25Date = calendar.date(from: DateComponents(year: 2025, month: 9, day: 25, hour: 16, minute: 57, second: 5)) ?? Date()

        // Generate all workout sessions
        generateGymWorkouts(exercises: exercises, sep22Date: sep22Date, sep24Date: startDate, sep25Date: sep25Date, modelContext: modelContext)

        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData4_GymData")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        logger.info("Gym Data generated: 14 exercises, 69 sets from 3 workout sessions (Sep 22, 24, 25, 2025)")
    }

    private static func generateGymWorkouts(exercises: [Exercise], sep22Date: Date, sep24Date: Date, sep25Date: Date, modelContext: ModelContext) {

        // SESSION 1: 2025-09-22 18:00:00 - Leg Day
        // Barbell squat: 3 sets (exercises[1])
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep22Date, time: "18:00:00"), weight: 50.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep22Date, time: "18:03:00"), weight: 50.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep22Date, time: "18:05:00"), weight: 50.0, reps: 10, modelContext: modelContext)

        // Barbell Lunges: 3 sets (exercises[3])
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep22Date, time: "18:06:00"), weight: 30.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep22Date, time: "18:09:00"), weight: 30.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep22Date, time: "18:12:00"), weight: 30.0, reps: 12, modelContext: modelContext)

        // Sled Push: 3 sets (exercises[5])
        generateGymSet(exercise: exercises[5], date: timestampFrom(sep22Date, time: "18:15:00"), weight: 50.0, reps: 20, modelContext: modelContext)
        generateGymSet(exercise: exercises[5], date: timestampFrom(sep22Date, time: "18:17:00"), weight: 50.0, reps: 20, modelContext: modelContext)
        generateGymSet(exercise: exercises[5], date: timestampFrom(sep22Date, time: "18:20:00"), weight: 50.0, reps: 20, modelContext: modelContext)

        // Hamstring Curls: 3 sets (exercises[4])
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep22Date, time: "18:24:00"), weight: 34.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep22Date, time: "18:26:00"), weight: 34.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep22Date, time: "18:30:00"), weight: 34.0, reps: 10, modelContext: modelContext)

        // Leg Raises: 3 sets (exercises[8])
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep22Date, time: "18:32:00"), weight: 39.5, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep22Date, time: "18:35:00"), weight: 39.5, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep22Date, time: "18:38:00"), weight: 39.5, reps: 10, modelContext: modelContext)

        // Calf Raises: 3 sets (exercises[12])
        generateGymSet(exercise: exercises[12], date: timestampFrom(sep22Date, time: "18:40:00"), weight: 40.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[12], date: timestampFrom(sep22Date, time: "18:43:00"), weight: 40.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[12], date: timestampFrom(sep22Date, time: "18:45:00"), weight: 40.0, reps: 12, modelContext: modelContext)

        // SESSION 2: 2025-09-24 17:00:00 - Back/Bicep Day
        // Pull Up (Strict): 2 sets (exercises[10])
        generateGymSet(exercise: exercises[10], date: timestampFrom(sep24Date, time: "17:00:00"), weight: 0.0, reps: 5, modelContext: modelContext)
        generateGymSet(exercise: exercises[10], date: timestampFrom(sep24Date, time: "17:02:00"), weight: 0.0, reps: 5, modelContext: modelContext)

        // T Bar Row: 4 sets (exercises[6])
        generateGymSet(exercise: exercises[6], date: timestampFrom(sep24Date, time: "17:03:30"), weight: 25.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[6], date: timestampFrom(sep24Date, time: "17:07:00"), weight: 25.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[6], date: timestampFrom(sep24Date, time: "17:09:00"), weight: 25.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[6], date: timestampFrom(sep24Date, time: "17:11:00"), weight: 25.0, reps: 10, modelContext: modelContext)

        // Seated Incline Dumbell Curls: 4 sets (exercises[0])
        generateGymSet(exercise: exercises[0], date: timestampFrom(sep24Date, time: "17:14:00"), weight: 10.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[0], date: timestampFrom(sep24Date, time: "17:16:00"), weight: 10.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[0], date: timestampFrom(sep24Date, time: "17:18:00"), weight: 10.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[0], date: timestampFrom(sep24Date, time: "17:20:00"), weight: 10.0, reps: 10, modelContext: modelContext)

        // Deadlifts (Trapbar): 4 sets (exercises[13])
        generateGymSet(exercise: exercises[13], date: timestampFrom(sep24Date, time: "17:22:30"), weight: 60.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[13], date: timestampFrom(sep24Date, time: "17:25:00"), weight: 60.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[13], date: timestampFrom(sep24Date, time: "17:27:30"), weight: 60.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[13], date: timestampFrom(sep24Date, time: "17:30:00"), weight: 60.0, reps: 10, modelContext: modelContext)

        // Rope Face Pulls: 3 sets (exercises[11])
        generateGymSet(exercise: exercises[11], date: timestampFrom(sep24Date, time: "17:32:30"), weight: 45.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[11], date: timestampFrom(sep24Date, time: "17:34:30"), weight: 45.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[11], date: timestampFrom(sep24Date, time: "17:36:30"), weight: 45.0, reps: 10, modelContext: modelContext)

        // Rope Bicep Curls: 4 sets (exercises[7])
        generateGymSet(exercise: exercises[7], date: timestampFrom(sep24Date, time: "17:39:00"), weight: 39.5, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[7], date: timestampFrom(sep24Date, time: "17:41:30"), weight: 39.5, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[7], date: timestampFrom(sep24Date, time: "17:44:00"), weight: 39.5, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[7], date: timestampFrom(sep24Date, time: "17:46:30"), weight: 39.5, reps: 12, modelContext: modelContext)

        // Reverse Cable Flys: 3 sets (exercises[9])
        generateGymSet(exercise: exercises[9], date: timestampFrom(sep24Date, time: "17:49:00"), weight: 15.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[9], date: timestampFrom(sep24Date, time: "17:51:30"), weight: 15.0, reps: 12, modelContext: modelContext)
        generateGymSet(exercise: exercises[9], date: timestampFrom(sep24Date, time: "17:54:00"), weight: 15.0, reps: 12, modelContext: modelContext)

        // Pull Up (Strict): 2 more sets later (exercises[10])
        generateGymSet(exercise: exercises[10], date: timestampFrom(sep24Date, time: "20:45:30"), weight: 0.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[10], date: timestampFrom(sep24Date, time: "20:46:30"), weight: 0.0, reps: 10, modelContext: modelContext)

        // Knees to toe: 3 sets (exercises[2])
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep24Date, time: "20:47:30"), weight: 0.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep24Date, time: "20:48:30"), weight: 0.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep24Date, time: "20:49:30"), weight: 0.0, reps: 10, modelContext: modelContext)

        // SESSION 3: 2025-09-25 16:57:05 - Mixed Leg Day
        // Leg Raises: 4 sets (exercises[8])
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep25Date, time: "16:57:05"), weight: 48.5, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep25Date, time: "16:58:02"), weight: 48.5, reps: 13, modelContext: modelContext)
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep25Date, time: "17:00:09"), weight: 54.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[8], date: timestampFrom(sep25Date, time: "17:01:32"), weight: 54.0, reps: 10, modelContext: modelContext)

        // Hamstring Curls: 1 warm-up set (exercises[4])
        generateGymSetWithWarmUp(exercise: exercises[4], date: timestampFrom(sep25Date, time: "17:04:30"), weight: 32.0, reps: 14, isWarmUp: true, modelContext: modelContext)

        // Calf Raises: 2 sets (exercises[12])
        generateGymSet(exercise: exercises[12], date: timestampFrom(sep25Date, time: "17:07:26"), weight: 40.0, reps: 15, modelContext: modelContext)
        generateGymSet(exercise: exercises[12], date: timestampFrom(sep25Date, time: "17:08:47"), weight: 40.0, reps: 15, modelContext: modelContext)

        // Barbell squat: 5 sets (exercises[1])
        generateGymSetWithWarmUp(exercise: exercises[1], date: timestampFrom(sep25Date, time: "17:13:04"), weight: 20.0, reps: 15, isWarmUp: true, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep25Date, time: "17:15:31"), weight: 40.0, reps: 8, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep25Date, time: "17:19:39"), weight: 50.0, reps: 8, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep25Date, time: "17:19:44"), weight: 50.0, reps: 8, modelContext: modelContext)
        generateGymSet(exercise: exercises[1], date: timestampFrom(sep25Date, time: "17:21:54"), weight: 50.0, reps: 8, modelContext: modelContext)

        // Barbell Lunges: 3 sets (exercises[3])
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep25Date, time: "17:25:36"), weight: 30.0, reps: 9, modelContext: modelContext)
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep25Date, time: "17:28:06"), weight: 30.0, reps: 9, modelContext: modelContext)
        generateGymSet(exercise: exercises[3], date: timestampFrom(sep25Date, time: "17:32:50"), weight: 30.0, reps: 9, modelContext: modelContext)

        // Sled Push: 2 sets (exercises[5])
        generateGymSet(exercise: exercises[5], date: timestampFrom(sep25Date, time: "17:33:03"), weight: 50.0, reps: 1, modelContext: modelContext)
        generateGymSet(exercise: exercises[5], date: timestampFrom(sep25Date, time: "17:34:33"), weight: 50.0, reps: 1, modelContext: modelContext)

        // Hamstring Curls: 3 more sets (exercises[4])
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep25Date, time: "17:41:22"), weight: 37.5, reps: 11, modelContext: modelContext)
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep25Date, time: "17:42:28"), weight: 37.5, reps: 14, modelContext: modelContext)
        generateGymSet(exercise: exercises[4], date: timestampFrom(sep25Date, time: "17:46:16"), weight: 37.5, reps: 12, modelContext: modelContext)

        // Knees to toe: 3 sets (exercises[2])
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep25Date, time: "17:48:31"), weight: 0.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep25Date, time: "17:49:56"), weight: 0.0, reps: 10, modelContext: modelContext)
        generateGymSet(exercise: exercises[2], date: timestampFrom(sep25Date, time: "17:52:08"), weight: 0.0, reps: 9, modelContext: modelContext)
    }

    // MARK: - Helper Functions

    private static func generateGymSet(exercise: Exercise, date: Date, weight: Double, reps: Int, modelContext: ModelContext) {
        let set = ExerciseSet(timestamp: date, weight: weight, reps: reps, exercise: exercise)
        modelContext.insert(set)
    }

    private static func generateGymSetWithWarmUp(exercise: Exercise, date: Date, weight: Double, reps: Int, isWarmUp: Bool, modelContext: ModelContext) {
        let set = ExerciseSet(timestamp: date, weight: weight, reps: reps, isWarmUp: isWarmUp, exercise: exercise)
        modelContext.insert(set)
    }

    private static func timestampFrom(_ baseDate: Date, time: String) -> Date {
        let components = time.split(separator: ":")
        guard components.count == 3,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              let second = Int(components[2]) else {
            return baseDate
        }

        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: second, of: baseDate) ?? baseDate
    }
}
#endif