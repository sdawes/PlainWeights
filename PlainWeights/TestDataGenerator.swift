//
//  TestDataGenerator.swift
//  PlainWeights
//
//  Created for generating test workout data sets
//

#if DEBUG
import SwiftData
import Foundation
import os

class TestDataGenerator {
    
    // MARK: - Public Interface
    
    static func printCurrentData(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")

        logger.info("\n================================================================================")
        logger.info("LIVE DATA EXPORT FOR TESTDATAGENERATOR")
        logger.info("================================================================================")

        // Fetch all exercises
        let exerciseDescriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.createdDate)]
        )

        guard let exercises = try? modelContext.fetch(exerciseDescriptor) else {
            logger.error("Failed to fetch exercises")
            return
        }

        // Collect all sets from all exercises
        var allSets: [(exercise: Exercise, set: ExerciseSet)] = []
        for exercise in exercises {
            for set in exercise.sets {
                allSets.append((exercise: exercise, set: set))
            }
        }

        // Sort all sets by timestamp
        allSets.sort { $0.set.timestamp < $1.set.timestamp }

        logger.info("SUMMARY:")
        logger.info("- Total Exercises: \(exercises.count)")
        logger.info("- Total Sets: \(allSets.count)")
        if let firstSet = allSets.first, let lastSet = allSets.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            logger.info("- Date Range: \(dateFormatter.string(from: firstSet.set.timestamp)) to \(dateFormatter.string(from: lastSet.set.timestamp))")
        }
        logger.info("")

        // Print exercise definitions
        logger.info("// COPY FROM HERE FOR generateLiveData() ================================")
        logger.info("")
        logger.info("// Exercise definitions")
        logger.info("let exerciseData: [(String, String)] = [")
        for exercise in exercises {
            logger.info("    (\"\(exercise.name)\", \"\(exercise.category)\"),")
        }
        logger.info("]")
        logger.info("")

        // Group sets into workout sessions (sets within 3 hours of each other)
        var workoutSessions: [[(exercise: Exercise, set: ExerciseSet)]] = []
        var currentSession: [(exercise: Exercise, set: ExerciseSet)] = []

        for (index, item) in allSets.enumerated() {
            if currentSession.isEmpty {
                currentSession.append(item)
            } else if let lastTime = currentSession.last?.set.timestamp {
                let timeDiff = item.set.timestamp.timeIntervalSince(lastTime)
                if timeDiff < 10800 { // Within 3 hours
                    currentSession.append(item)
                } else {
                    // Start new session
                    workoutSessions.append(currentSession)
                    currentSession = [item]
                }
            }

            // Add last session
            if index == allSets.count - 1 && !currentSession.isEmpty {
                workoutSessions.append(currentSession)
            }
        }

        logger.info("// Workout Sessions (\(workoutSessions.count) total)")
        logger.info("// Format: Exercise | Weight | Reps | Time")
        logger.info("")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for (sessionIndex, session) in workoutSessions.enumerated() {
            if let firstSet = session.first {
                logger.info("// SESSION \(sessionIndex + 1): \(dateFormatter.string(from: firstSet.set.timestamp))")

                // Group by consecutive exercises
                var exerciseGroups: [[(exercise: Exercise, set: ExerciseSet)]] = []
                var currentExercise: [(exercise: Exercise, set: ExerciseSet)] = []
                var lastExerciseName = ""

                for item in session {
                    if item.exercise.name == lastExerciseName || lastExerciseName.isEmpty {
                        currentExercise.append(item)
                        lastExerciseName = item.exercise.name
                    } else {
                        if !currentExercise.isEmpty {
                            exerciseGroups.append(currentExercise)
                        }
                        currentExercise = [item]
                        lastExerciseName = item.exercise.name
                    }
                }
                if !currentExercise.isEmpty {
                    exerciseGroups.append(currentExercise)
                }

                // Print each exercise group
                for group in exerciseGroups {
                    if let first = group.first {
                        logger.info("// \(first.exercise.name): \(group.count) sets")
                        for item in group {
                            let timeOnly = DateFormatter()
                            timeOnly.dateFormat = "HH:mm:ss"
                            let warmupFlag = item.set.isWarmUp ? " (warm-up)" : ""
                            logger.info("//   \(timeOnly.string(from: item.set.timestamp)) - \(item.set.weight)kg x \(item.set.reps) reps\(warmupFlag)")
                        }
                    }
                }
                logger.info("")
            }
        }

        logger.info("// COPY TO HERE ============================================")
        logger.info("")
        logger.info("// To use this data:")
        logger.info("// 1. Copy everything between the COPY markers above")
        logger.info("// 2. Share with Claude to update generateLiveData()")
        logger.info("// 3. The data will be converted to proper Swift code")
        logger.info("================================================================================")
    }
    
    static func generateTestDataSet1(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 1 (1 month realistic workout data)...")
        clearAllData(modelContext: modelContext)
        generateSet1Data(modelContext: modelContext)
    }
    
    static func generateTestDataSet2(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 2 (1 year performance test data)...")
        clearAllData(modelContext: modelContext)
        generateSet2Data(modelContext: modelContext)
    }
    
    static func generateTestDataSet3(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 3 (2 weeks simple data)...")
        clearAllData(modelContext: modelContext)
        generateSet3Data(modelContext: modelContext)
    }
    
    static func generateTestDataSet4(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 4 (Live gym data)...")
        clearAllData(modelContext: modelContext)
        generateLiveData(modelContext: modelContext)
    }
    
    static func clearAllData(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        // Fetch and delete all exercises (sets will cascade delete)
        let exerciseDescriptor = FetchDescriptor<Exercise>()
        if let exercises = try? modelContext.fetch(exerciseDescriptor) {
            for exercise in exercises {
                modelContext.delete(exercise)
            }
        }
        
        try? modelContext.save()
        logger.info("All data cleared")
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
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 2, hour: 18, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [140, 0, 70, 60, 20, 15],
                              reps: [[5,5,5,5], [8,7,6,5], [10,10,8], [12,12,10], [10,10,10], [10,10,8]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 3, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11], exercises[19]],
                              weights: [100, 80, 150, 80, 0],
                              reps: [[8,8,8,6], [10,10,10], [12,12,10,10], [15,15,15], [60,45,30]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 5, hour: 7, minute: 30),
                              exercises: [exercises[0], exercises[1], exercises[3], exercises[12], exercises[14], exercises[17]],
                              weights: [82.5, 35, 0, 52.5, 20, 0],
                              reps: [[8,8,7,7], [10,10,10,9], [20,15,12], [8,8,7,6], [12,12,12], [8,8,7]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 6, hour: 10, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [142.5, 0, 72.5, 60, 22, 17],
                              reps: [[5,5,5,4], [8,8,7,6], [10,10,10], [12,12,12], [10,10,10], [10,10,10]],
                              modelContext: modelContext)
        
        // Week 2
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 8, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11]],
                              weights: [102.5, 82.5, 155, 85],
                              reps: [[8,8,8,7], [10,10,10], [12,12,12,10], [15,15,15]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 10, hour: 18, minute: 30),
                              exercises: [exercises[0], exercises[1], exercises[2], exercises[3], exercises[12], exercises[13], exercises[17], exercises[18]],
                              weights: [82.5, 37.5, 22, 0, 52.5, 12, 2.5, 32],
                              reps: [[8,8,8,8], [10,10,10,9], [12,12,12], [15,12,10], [8,8,7,7], [12,12,12], [8,7,6], [12,12,12]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 12, hour: 7, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [145, 5, 72.5, 62.5, 22, 17],
                              reps: [[5,5,5,5], [8,8,7,7], [10,10,10], [12,12,12], [10,10,10], [10,10,10]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 13, hour: 11, minute: 0),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11], exercises[19]],
                              weights: [105, 82.5, 160, 85],
                              reps: [[8,8,8,8], [10,10,10], [12,12,12,12], [15,15,15], [70,60,45]],
                              modelContext: modelContext)
        
        // Week 3
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 15, hour: 7, minute: 30),
                              exercises: [exercises[0], exercises[1], exercises[3], exercises[12], exercises[14], exercises[17]],
                              weights: [85, 37.5, 0, 55, 22, 0],
                              reps: [[8,8,8,7], [10,10,10,10], [25,20,15], [8,8,8,6], [12,12,12], [9,9,8]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 17, hour: 18, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [147.5, 5, 75, 62.5, 24, 19],
                              reps: [[5,5,5,5], [9,8,8,7], [10,10,10], [12,12,12], [10,10,10], [10,10,10]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 19, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11]],
                              weights: [107.5, 85, 165, 90],
                              reps: [[8,8,8,8], [10,10,10], [12,12,12,11], [15,15,15]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 20, hour: 10, minute: 0),
                              exercises: [exercises[0], exercises[1], exercises[2], exercises[3], exercises[12], exercises[13], exercises[17], exercises[18]],
                              weights: [85, 40, 24, 2.5, 55, 14, 5, 34],
                              reps: [[8,8,8,8], [10,10,10,10], [12,12,12], [12,10,8], [8,8,8,7], [12,12,12], [6,6,5], [12,12,12]],
                              modelContext: modelContext)
        
        // Week 4
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 22, hour: 7, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [150, 7.5, 75, 65, 24, 19],
                              reps: [[5,5,5,5], [9,9,8,8], [10,10,10], [12,12,12], [10,10,10], [10,10,10]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 24, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11], exercises[19]],
                              weights: [110, 85, 170, 90],
                              reps: [[8,8,8,8], [10,10,10], [12,12,12,12], [15,15,15], [75,60,50]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 26, hour: 18, minute: 30),
                              exercises: [exercises[0], exercises[1], exercises[3], exercises[12], exercises[14], exercises[17]],
                              weights: [87.5, 40, 0, 57.5, 24, 0],
                              reps: [[8,8,8,8], [10,10,10,10], [30,25,20], [8,8,8,7], [12,12,12], [10,10,9]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 27, hour: 10, minute: 0),
                              exercises: [exercises[4], exercises[5], exercises[6], exercises[7], exercises[15], exercises[16]],
                              weights: [152.5, 7.5, 77.5, 65, 26, 21],
                              reps: [[5,5,5,5], [10,9,9,8], [10,10,10], [12,12,12], [10,10,10], [10,10,10]],
                              modelContext: modelContext)
        
        generateWorkoutSession(date: dateFrom(startDate, daysOffset: 29, hour: 7, minute: 30),
                              exercises: [exercises[8], exercises[9], exercises[10], exercises[11]],
                              weights: [112.5, 87.5, 175, 95],
                              reps: [[8,8,8,8], [10,10,10], [12,12,12,12], [15,15,15]],
                              modelContext: modelContext)
        
        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Test Data Set 1 generated: 20 exercises, ~76 sets over 1 month")
    }
    
    // MARK: - Test Data Set 2: 1 Year Performance Test Data
    // 50 exercises, full year of training data
    
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
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Test Data Set 2 generated: 50 exercises, \(sets.count) total sets for performance testing")
    }
    
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
            return [65.0, 25.0, 40.0, 20.0, 35.0, 15.0, 80.0, 45.0][index % 8]
        case "Core":
            return [0.0, 0.0, 0.0, 20.0, 50.0][index % 5]
        case "Cardio":
            return [0.0, 0.0][index % 2]
        default:
            return 50.0 + Double(index) * 5.0
        }
    }
    
    // MARK: - Test Data Set 3: 2 Weeks Simple Data
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
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Test Data Set 3 generated: 5 exercises, 18 sets over 2 weeks")
    }
    
    // MARK: - Test Data Set 4: Live Gym Data
    // Real workout data from actual gym sessions
    
    private static func generateLiveData(modelContext: ModelContext) {
        // Base date for live data - Today's workout (Sep 24, 2025) at 17:00
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 17, minute: 0)) ?? Date()

        // Create exercises from today's workout
        let exerciseData: [(String, String)] = [
            ("Pull Up (Strict)", "Back"),
            ("T Bar Row", "Back"),
            ("Deadlifts (Trapbar)", "Back"),
            ("Reverse Cable Flys", "Back"),
            ("Seated Incline Dumbell Curls", "Bicep"),
            ("Rope Bicep Curls", "Bicep"),
            ("Rope Face Pulls", "Back")
        ]

        var exercises: [Exercise] = []
        for (name, category) in exerciseData {
            let exercise = Exercise(name: name, category: category, createdDate: startDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Generate today's workout session
        generateTodayWorkout(exercises: exercises, baseDate: startDate, modelContext: modelContext)

        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        logger.info("Live Data generated: 7 exercises, 26 sets from today's workout (\(dateFormatter.string(from: startDate)))")
    }
    
    private static func generateTodayWorkout(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        // Start at 17:00 (5:00 PM)
        var currentTime = baseDate

        // Pull Up (Strict) - 4 sets x 0kg x 5 reps
        for i in 0..<4 {
            generateLiveSet(exercise: exercises[0], date: currentTime, weight: 0.0, reps: 5, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // T Bar Row - 4 sets x 25kg x 10 reps
        for i in 0..<4 {
            generateLiveSet(exercise: exercises[1], date: currentTime, weight: 25.0, reps: 10, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // Deadlifts (Trapbar) - 4 sets x 60kg x 10 reps
        for i in 0..<4 {
            generateLiveSet(exercise: exercises[2], date: currentTime, weight: 60.0, reps: 10, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 3, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // Reverse Cable Flys - 3 sets x 15kg x 12 reps
        for i in 0..<3 {
            generateLiveSet(exercise: exercises[3], date: currentTime, weight: 15.0, reps: 12, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // Seated Incline Dumbell Curls - 4 sets x 10kg x 10 reps
        for i in 0..<4 {
            generateLiveSet(exercise: exercises[4], date: currentTime, weight: 10.0, reps: 10, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // Rope Bicep Curls - 4 sets x 39.5kg x 12 reps
        for i in 0..<4 {
            generateLiveSet(exercise: exercises[5], date: currentTime, weight: 39.5, reps: 12, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }

        // Rest between exercises
        currentTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentTime) ?? currentTime

        // Rope Face Pulls - 3 sets x 45kg x 10 reps
        for i in 0..<3 {
            generateLiveSet(exercise: exercises[6], date: currentTime, weight: 45.0, reps: 10, modelContext: modelContext)
            currentTime = Calendar.current.date(byAdding: .minute, value: 2, to: currentTime) ?? currentTime
        }
    }

    private static func generateLiveSet(exercise: Exercise, date: Date, weight: Double, reps: Int, modelContext: ModelContext) {
        let set = ExerciseSet(timestamp: date, weight: weight, reps: reps, exercise: exercise)
        modelContext.insert(set)
    }

    private static func dateFrom(_ baseDate: Date, hour: Int, minute: Int, seconds: Int) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: minute, second: seconds, of: baseDate) ?? baseDate
        return date
    }

    // Helper function for old test data sets (1, 2, and 3)
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

    // Legacy dateFrom with daysOffset for old test data sets
    private static func dateFrom(_ baseDate: Date, daysOffset: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysOffset, to: baseDate) ?? baseDate
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}
#endif
