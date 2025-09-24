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
        logger.info("EXPORTING CURRENT GYM DATA")
        logger.info("================================================================================")
        
        // Fetch all exercises
        let exerciseDescriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.createdDate)]
        )
        
        guard let exercises = try? modelContext.fetch(exerciseDescriptor) else {
            logger.error("Failed to fetch exercises")
            return
        }
        
        logger.info("Total Exercises: \(exercises.count)")
        logger.info("Exercise Data:")
        
        for (index, exercise) in exercises.enumerated() {
            logger.info("Exercise \(index + 1):")
            logger.info("Name: \(exercise.name)")
            logger.info("Category: \(exercise.category)")
            logger.info("Created: \(exercise.createdDate)")
            
            // Sort sets by timestamp
            let sets = exercise.sets.sorted { $0.timestamp < $1.timestamp }
            logger.info("Sets: \(sets.count)")
            
            if !sets.isEmpty {
                logger.info("Set Data:")
                for set in sets {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let dateStr = dateFormatter.string(from: set.timestamp)
                    logger.info("  \(dateStr): \(set.weight)kg x \(set.reps) reps")
                }
            }
            logger.info("---")
        }
        
        // Also print as Swift code that could be pasted
        logger.info("================================================================================")
        logger.info("SWIFT CODE FORMAT (can be pasted into TestDataGenerator):")
        logger.info("================================================================================")
        logger.info("Exercise definitions:")
        logger.info("let exerciseData: [(String, String)] = [")
        for exercise in exercises {
            logger.info("    (\"\(exercise.name)\", \"\(exercise.category)\"),")
        }
        logger.info("]")
        
        logger.info("Sample workout sessions from your data:")
        // Group sets by day
        var workoutsByDay: [Date: [(Exercise, ExerciseSet)]] = [:]
        
        for exercise in exercises {
            for set in exercise.sets {
                let calendar = Calendar.current
                let dayStart = calendar.startOfDay(for: set.timestamp)
                if workoutsByDay[dayStart] == nil {
                    workoutsByDay[dayStart] = []
                }
                workoutsByDay[dayStart]?.append((exercise, set))
            }
        }
        
        let sortedDays = workoutsByDay.keys.sorted()
        for day in sortedDays.prefix(5) { // Show first 5 workout days as examples
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            logger.info("Workout on \(dateFormatter.string(from: day)):")
            
            if let dayWorkouts = workoutsByDay[day] {
                // Group by exercise
                var exerciseSets: [String: [(weight: Double, reps: Int)]] = [:]
                for (exercise, set) in dayWorkouts {
                    if exerciseSets[exercise.name] == nil {
                        exerciseSets[exercise.name] = []
                    }
                    exerciseSets[exercise.name]?.append((weight: set.weight, reps: set.reps))
                }
                
                logger.info("Exercises: \(exerciseSets.keys.joined(separator: ", "))")
                for (exerciseName, sets) in exerciseSets {
                    logger.info("\(exerciseName):")
                    for set in sets {
                        logger.info("  \(set.weight)kg x \(set.reps)")
                    }
                }
            }
        }
        
        logger.info("================================================================================")
        logger.info("END OF DATA EXPORT")
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
        // Base date for live data - Aug 17, 2025
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 8, day: 17, hour: 14, minute: 0)) ?? Date()
        
        // Create exercises with exact names and categories from live data (Updated September 2025)
        let exerciseData: [(String, String)] = [
            ("Leg press machine", "Legs"),
            ("Incline dumbbell chest press", "Chest"),
            ("Lateral raises (single cable)", "Shoulder"),
            ("Duel cable lat pulldown", "Back"),
            ("Cable chest flys", "Chest"),
            ("Cable face pulls", "Back"),
            ("Incline chest press (machine)", "Chest"),
            ("Ring pull ups (45 ground)", "Back"),
            ("Cable rope bicep curls", "Bicep"),
            ("Sled push", "Legs"),
            ("Lateral raises (cross cables)", "Shoulder"),
            ("Split squat (barbell)", "Legs"),
            ("Dumbbell seated curls", "Biceps"),
            ("Calf raises (rear machine)", "Legs"),
            ("Tricep push downs (bar)", "Triceps"),
            ("Press ups", "Chest"),
            ("Tricep dips", "Triceps"),
            ("Shoulder press (dumbbells)", "Shoulders"),
            ("Pull ups (proper)", "Back"),
            ("Reverse cable fly", "Back"),
            ("Hyper extension 45", "Back"),
            ("Calf raises (standing)", "Legs"),
            ("Tricep pulls (rope)", "Triceps"),
            ("Cable lat pulldown", "Back"),
            ("Dumbbell hammer curls", "Bicep"),
            ("Leg raises", "Legs"),
            ("Front rack squat", "Legs"),
            ("T bar row", "Back"),
            ("Deadlifts (trap bar)", "Back"),
            ("Chest press machine", "Chest"),
            ("Squat", "Legs"),
            ("Chest press", "Chest"),
            ("Shoulder press (machine)", "Shoulder")
        ]

        var exercises: [Exercise] = []
        for i in 0..<exerciseData.count {
            let (name, category) = exerciseData[i]
            // Set creation date: Sep 22 for last two exercises, Aug 17 for all others
            let createdDate = (i >= 31) ?
                Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 22, hour: 14, minute: 12)) ?? startDate :
                startDate
            let exercise = Exercise(name: name, category: category, createdDate: createdDate)
            modelContext.insert(exercise)
            exercises.append(exercise)
        }

        // Generate the actual workout sessions from live data
        generateLiveWorkoutSessions(exercises: exercises, baseDate: startDate, modelContext: modelContext)
        
        try? modelContext.save()
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Live Data generated: 33 exercises, 197 sets from real gym sessions (Aug 17 - Sep 22, 2025)")
    }
    
    private static func generateLiveWorkoutSessions(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        // Aug 17, 2025 - Back-focused session
        generateLiveWorkout1(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 18, 2025 - Legs session  
        generateLiveWorkout2(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 19, 2025 - Upper body session
        generateLiveWorkout3(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 20, 2025 - Back-focused session (repeat)
        generateLiveWorkout4(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 21, 2025 - Legs-focused session
        generateLiveWorkout5(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 22, 2025 - Mixed bodyweight session
        generateLiveWorkout6(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 27, 2025 - Chest-focused session
        generateLiveWorkout7(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
        
        // Aug 28, 2025 - Back and biceps session
        generateLiveWorkout8(exercises: exercises, baseDate: baseDate, modelContext: modelContext)

        // Sep 22, 2025 - Chest, shoulders, and triceps session
        generateLiveWorkout9(exercises: exercises, baseDate: baseDate, modelContext: modelContext)
    }
    
    // Aug 17, 2025 - Back-focused session
    private static func generateLiveWorkout1(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        // Deadlifts (trap bar) - exercises[0]
        generateLiveSet(exercise: exercises[0], date: dateFrom(baseDate, hour: 15, minute: 13, seconds: 14), weight: 40.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[0], date: dateFrom(baseDate, hour: 15, minute: 13, seconds: 14), weight: 40.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[0], date: dateFrom(baseDate, hour: 15, minute: 13, seconds: 14), weight: 50.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[0], date: dateFrom(baseDate, hour: 15, minute: 13, seconds: 14), weight: 50.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[0], date: dateFrom(baseDate, hour: 15, minute: 13, seconds: 14), weight: 55.0, reps: 8, modelContext: modelContext)
        
        // Duel cable lat pulldown - exercises[1]
        generateLiveSet(exercise: exercises[1], date: dateFrom(baseDate, hour: 15, minute: 18, seconds: 36), weight: 35.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[1], date: dateFrom(baseDate, hour: 15, minute: 19, seconds: 36), weight: 35.0, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[1], date: dateFrom(baseDate, hour: 15, minute: 21, seconds: 36), weight: 39.5, reps: 10, modelContext: modelContext)
        
        // Cable lat pulldown - exercises[2]
        generateLiveSet(exercise: exercises[2], date: dateFrom(baseDate, hour: 15, minute: 23, seconds: 31), weight: 39.5, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(baseDate, hour: 15, minute: 25, seconds: 31), weight: 39.5, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(baseDate, hour: 15, minute: 27, seconds: 31), weight: 39.5, reps: 10, modelContext: modelContext)
        
        // T bar row - exercises[3]
        generateLiveSet(exercise: exercises[3], date: dateFrom(baseDate, hour: 15, minute: 29, seconds: 51), weight: 20.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(baseDate, hour: 15, minute: 30, seconds: 51), weight: 25.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(baseDate, hour: 15, minute: 32, seconds: 51), weight: 25.0, reps: 9, modelContext: modelContext)
        
        // Reverse cable fly - exercises[4]
        generateLiveSet(exercise: exercises[4], date: dateFrom(baseDate, hour: 15, minute: 35, seconds: 30), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(baseDate, hour: 15, minute: 37, seconds: 30), weight: 15.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(baseDate, hour: 15, minute: 39, seconds: 30), weight: 15.0, reps: 11, modelContext: modelContext)
        
        // Dumbbell seated curls - exercises[5]
        generateLiveSet(exercise: exercises[5], date: dateFrom(baseDate, hour: 15, minute: 41, seconds: 34), weight: 10.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(baseDate, hour: 15, minute: 43, seconds: 34), weight: 10.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(baseDate, hour: 15, minute: 45, seconds: 34), weight: 10.0, reps: 9, modelContext: modelContext)
        
        // Cable face pulls - exercises[6]
        generateLiveSet(exercise: exercises[6], date: dateFrom(baseDate, hour: 15, minute: 49, seconds: 1), weight: 45.0, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(baseDate, hour: 15, minute: 50, seconds: 1), weight: 45.0, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(baseDate, hour: 15, minute: 51, seconds: 1), weight: 45.0, reps: 12, modelContext: modelContext)
        
        // Cable rope bicep curls - exercises[7]
        generateLiveSet(exercise: exercises[7], date: dateFrom(baseDate, hour: 15, minute: 53, seconds: 32), weight: 45.0, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[7], date: dateFrom(baseDate, hour: 15, minute: 55, seconds: 32), weight: 45.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[7], date: dateFrom(baseDate, hour: 15, minute: 57, seconds: 32), weight: 45.0, reps: 19, modelContext: modelContext)
    }
    
    // Aug 18, 2025 - Legs session
    private static func generateLiveWorkout2(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 1, to: baseDate) ?? baseDate
        
        // Leg press machine - exercises[8]
        generateLiveSet(exercise: exercises[8], date: dateFrom(workoutDate, hour: 19, minute: 18, seconds: 2), weight: 100.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[8], date: dateFrom(workoutDate, hour: 19, minute: 19, seconds: 2), weight: 100.0, reps: 9, modelContext: modelContext)
        
        // Sled push - exercises[9]
        generateLiveSet(exercise: exercises[9], date: dateFrom(workoutDate, hour: 19, minute: 40, seconds: 43), weight: 50.0, reps: 20, modelContext: modelContext)
        generateLiveSet(exercise: exercises[9], date: dateFrom(workoutDate, hour: 19, minute: 41, seconds: 43), weight: 50.0, reps: 46, modelContext: modelContext)
    }
    
    // Aug 19, 2025 - Upper body session
    private static func generateLiveWorkout3(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 2, to: baseDate) ?? baseDate
        
        // Plate loaded incline chest press - exercises[10]
        generateLiveSet(exercise: exercises[10], date: dateFrom(workoutDate, hour: 19, minute: 16, seconds: 5), weight: 10.0, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[10], date: dateFrom(workoutDate, hour: 19, minute: 18, seconds: 5), weight: 30.0, reps: 6, modelContext: modelContext)
        generateLiveSet(exercise: exercises[10], date: dateFrom(workoutDate, hour: 19, minute: 21, seconds: 5), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[10], date: dateFrom(workoutDate, hour: 19, minute: 23, seconds: 5), weight: 30.0, reps: 10, modelContext: modelContext)
        
        // Plate loaded chest press - exercises[11]
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 19, minute: 26, seconds: 38), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 19, minute: 29, seconds: 38), weight: 20.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 19, minute: 32, seconds: 38), weight: 20.0, reps: 8, modelContext: modelContext)
        
        // Shoulder press (dumbbells) - exercises[12]
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 19, minute: 34, seconds: 53), weight: 17.5, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 19, minute: 36, seconds: 53), weight: 17.5, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 19, minute: 41, seconds: 53), weight: 17.5, reps: 11, modelContext: modelContext)
        
        // Lateral raises (cross cables) - exercises[13]
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 19, minute: 43, seconds: 47), weight: 15.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 19, minute: 44, seconds: 47), weight: 15.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 19, minute: 46, seconds: 47), weight: 15.0, reps: 6, modelContext: modelContext)
        
        // Lateral raises (single cable) - exercises[14]
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 19, minute: 46, seconds: 35), weight: 15.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 19, minute: 48, seconds: 35), weight: 15.0, reps: 10, modelContext: modelContext)
        
        // Tricep dips - exercises[15]
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 19, minute: 53, seconds: 3), weight: 5.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 19, minute: 56, seconds: 3), weight: 5.0, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 19, minute: 59, seconds: 3), weight: 5.0, reps: 8, modelContext: modelContext)
        
        // T bar row - exercises[3] (additional set)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 18, minute: 56, seconds: 51), weight: 25.0, reps: 9, modelContext: modelContext)
        
        // Tricep push downs (bar) - exercises[16]
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 20, minute: 2, seconds: 1), weight: 34.0, reps: 20, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 20, minute: 4, seconds: 1), weight: 39.5, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 20, minute: 6, seconds: 1), weight: 45.0, reps: 13, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 20, minute: 8, seconds: 1), weight: 45.0, reps: 10, modelContext: modelContext)
    }
    
    // Aug 20, 2025 - Back-focused session (repeat)
    private static func generateLiveWorkout4(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 3, to: baseDate) ?? baseDate
        
        // Duel cable lat pulldown - exercises[1]
        generateLiveSet(exercise: exercises[1], date: dateFrom(workoutDate, hour: 19, minute: 24, seconds: 36), weight: 43.0, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[1], date: dateFrom(workoutDate, hour: 19, minute: 26, seconds: 36), weight: 54.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[1], date: dateFrom(workoutDate, hour: 19, minute: 28, seconds: 36), weight: 54.0, reps: 12, modelContext: modelContext)
        
        // Cable lat pulldown - exercises[2]
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 19, minute: 32, seconds: 31), weight: 54.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 19, minute: 34, seconds: 31), weight: 54.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 19, minute: 36, seconds: 31), weight: 54.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 19, minute: 41, seconds: 31), weight: 54.0, reps: 8, modelContext: modelContext)
        
        // T bar row - exercises[3]
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 19, minute: 41, seconds: 51), weight: 25.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 19, minute: 43, seconds: 51), weight: 25.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 19, minute: 46, seconds: 51), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 19, minute: 49, seconds: 51), weight: 30.0, reps: 10, modelContext: modelContext)
        
        // Reverse cable fly - exercises[4]
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 19, minute: 52, seconds: 30), weight: 15.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 19, minute: 54, seconds: 30), weight: 15.0, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 19, minute: 56, seconds: 30), weight: 15.0, reps: 15, modelContext: modelContext)
        
        // Cable face pulls - exercises[6]
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 19, minute: 58, seconds: 1), weight: 50.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 20, minute: 0, seconds: 1), weight: 50.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 20, minute: 1, seconds: 1), weight: 50.5, reps: 8, modelContext: modelContext)
        
        // Dumbbell seated curls - exercises[5]
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 20, minute: 3, seconds: 34), weight: 10.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 20, minute: 5, seconds: 34), weight: 10.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 20, minute: 7, seconds: 34), weight: 10.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 20, minute: 10, seconds: 34), weight: 10.0, reps: 9, modelContext: modelContext)
        
        // Cable rope bicep curls - exercises[7]
        generateLiveSet(exercise: exercises[7], date: dateFrom(workoutDate, hour: 20, minute: 13, seconds: 32), weight: 39.5, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[7], date: dateFrom(workoutDate, hour: 20, minute: 14, seconds: 32), weight: 39.5, reps: 13, modelContext: modelContext)
        generateLiveSet(exercise: exercises[7], date: dateFrom(workoutDate, hour: 20, minute: 15, seconds: 32), weight: 39.5, reps: 13, modelContext: modelContext)
    }
    
    // Aug 21, 2025 - Legs-focused session
    private static func generateLiveWorkout5(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 4, to: baseDate) ?? baseDate
        
        // Squat - exercises[17]
        generateLiveSet(exercise: exercises[17], date: dateFrom(workoutDate, hour: 19, minute: 10, seconds: 21), weight: 40.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[17], date: dateFrom(workoutDate, hour: 19, minute: 16, seconds: 21), weight: 50.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[17], date: dateFrom(workoutDate, hour: 19, minute: 16, seconds: 21), weight: 50.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[17], date: dateFrom(workoutDate, hour: 19, minute: 26, seconds: 21), weight: 50.0, reps: 10, modelContext: modelContext)
        
        // Front rack squat - exercises[18]
        generateLiveSet(exercise: exercises[18], date: dateFrom(workoutDate, hour: 19, minute: 26, seconds: 12), weight: 40.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[18], date: dateFrom(workoutDate, hour: 19, minute: 26, seconds: 12), weight: 40.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[18], date: dateFrom(workoutDate, hour: 19, minute: 29, seconds: 12), weight: 40.0, reps: 3, modelContext: modelContext)
        
        // Split squat (barbell) - exercises[19]
        generateLiveSet(exercise: exercises[19], date: dateFrom(workoutDate, hour: 19, minute: 34, seconds: 25), weight: 20.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[19], date: dateFrom(workoutDate, hour: 19, minute: 34, seconds: 25), weight: 20.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[19], date: dateFrom(workoutDate, hour: 19, minute: 37, seconds: 25), weight: 20.0, reps: 10, modelContext: modelContext)
        
        // Leg raises - exercises[20]
        generateLiveSet(exercise: exercises[20], date: dateFrom(workoutDate, hour: 19, minute: 39, seconds: 3), weight: 54.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[20], date: dateFrom(workoutDate, hour: 19, minute: 40, seconds: 3), weight: 54.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[20], date: dateFrom(workoutDate, hour: 19, minute: 43, seconds: 3), weight: 54.0, reps: 11, modelContext: modelContext)
        
        // Calf raises (rear machine) - exercises[21]
        generateLiveSet(exercise: exercises[21], date: dateFrom(workoutDate, hour: 19, minute: 45, seconds: 43), weight: 37.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[21], date: dateFrom(workoutDate, hour: 19, minute: 48, seconds: 43), weight: 43.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[21], date: dateFrom(workoutDate, hour: 19, minute: 50, seconds: 43), weight: 43.0, reps: 9, modelContext: modelContext)
        
        // Calf raises (standing) - exercises[22]
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 19, minute: 52, seconds: 57), weight: 40.0, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 19, minute: 53, seconds: 57), weight: 40.0, reps: 18, modelContext: modelContext)
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 19, minute: 55, seconds: 57), weight: 40.0, reps: 16, modelContext: modelContext)
        
        // Hyper extension 45 - exercises[23]
        generateLiveSet(exercise: exercises[23], date: dateFrom(workoutDate, hour: 19, minute: 57, seconds: 16), weight: 0.1, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[23], date: dateFrom(workoutDate, hour: 19, minute: 58, seconds: 16), weight: 0.1, reps: 14, modelContext: modelContext)
        generateLiveSet(exercise: exercises[23], date: dateFrom(workoutDate, hour: 20, minute: 0, seconds: 16), weight: 0.1, reps: 14, modelContext: modelContext)
        
        // Leg press machine - exercises[8] (additional sets)
        generateLiveSet(exercise: exercises[8], date: dateFrom(workoutDate, hour: 20, minute: 3, seconds: 2), weight: 100.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[8], date: dateFrom(workoutDate, hour: 20, minute: 3, seconds: 2), weight: 100.0, reps: 6, modelContext: modelContext)
        generateLiveSet(exercise: exercises[8], date: dateFrom(workoutDate, hour: 20, minute: 4, seconds: 2), weight: 100.0, reps: 10, modelContext: modelContext)
    }
    
    // Aug 22, 2025 - Mixed bodyweight session
    private static func generateLiveWorkout6(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 5, to: baseDate) ?? baseDate
        
        // Ring pull ups (45 ground) - exercises[24]
        generateLiveSet(exercise: exercises[24], date: dateFrom(workoutDate, hour: 16, minute: 24, seconds: 49), weight: 1.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[24], date: dateFrom(workoutDate, hour: 16, minute: 24, seconds: 49), weight: 1.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[24], date: dateFrom(workoutDate, hour: 16, minute: 24, seconds: 49), weight: 1.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[24], date: dateFrom(workoutDate, hour: 16, minute: 24, seconds: 49), weight: 1.0, reps: 9, modelContext: modelContext)
        
        // Press ups - exercises[25]
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 16, minute: 25, seconds: 56), weight: 1.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 16, minute: 26, seconds: 56), weight: 1.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 16, minute: 28, seconds: 56), weight: 1.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 16, minute: 30, seconds: 56), weight: 1.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 16, minute: 31, seconds: 56), weight: 1.0, reps: 9, modelContext: modelContext)
        
        // Pull ups (proper) - exercises[26]
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 16, minute: 33, seconds: 21), weight: 1.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 16, minute: 35, seconds: 21), weight: 1.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 16, minute: 37, seconds: 21), weight: 1.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 16, minute: 39, seconds: 21), weight: 1.0, reps: 3, modelContext: modelContext)
        
        // Tricep dips - exercises[15] (additional sets)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 41, seconds: 3), weight: 5.0, reps: 6, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 44, seconds: 3), weight: 5.0, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 46, seconds: 3), weight: 5.0, reps: 5, modelContext: modelContext)
        
        // Tricep pulls (rope) - exercises[27]
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 16, minute: 56, seconds: 7), weight: 39.5, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 16, minute: 57, seconds: 7), weight: 39.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 17, minute: 0, seconds: 7), weight: 39.5, reps: 8, modelContext: modelContext)
        
        // Lateral raises (cross cables) - exercises[13] (additional sets)
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 17, minute: 2, seconds: 47), weight: 15.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 17, minute: 3, seconds: 47), weight: 15.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[13], date: dateFrom(workoutDate, hour: 17, minute: 5, seconds: 47), weight: 15.0, reps: 8, modelContext: modelContext)
        
        // Cable rope bicep curls - exercises[7] (additional sets)
        generateLiveSet(exercise: exercises[7], date: dateFrom(workoutDate, hour: 17, minute: 7, seconds: 32), weight: 39.5, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[7], date: dateFrom(workoutDate, hour: 17, minute: 9, seconds: 32), weight: 39.5, reps: 14, modelContext: modelContext)
    }
    
    // Aug 27, 2025 - Chest-focused session
    private static func generateLiveWorkout7(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 10, to: baseDate) ?? baseDate
        
        // Incline dumbbell chest press - exercises[28]
        generateLiveSet(exercise: exercises[28], date: dateFrom(workoutDate, hour: 16, minute: 6, seconds: 0), weight: 20.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[28], date: dateFrom(workoutDate, hour: 16, minute: 8, seconds: 0), weight: 20.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[28], date: dateFrom(workoutDate, hour: 16, minute: 10, seconds: 0), weight: 20.0, reps: 12, modelContext: modelContext)
        
        // Chest press machine - exercises[11]
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 16, minute: 13, seconds: 0), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 16, minute: 14, seconds: 0), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[11], date: dateFrom(workoutDate, hour: 16, minute: 17, seconds: 0), weight: 30.0, reps: 12, modelContext: modelContext)
        
        // Shoulder press (dumbbells) - exercises[12]
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 16, minute: 21, seconds: 0), weight: 17.5, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 16, minute: 23, seconds: 0), weight: 17.5, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 16, minute: 25, seconds: 0), weight: 17.5, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[12], date: dateFrom(workoutDate, hour: 16, minute: 27, seconds: 0), weight: 17.5, reps: 4, modelContext: modelContext)
        
        // Cable chest flys - exercises[29]
        generateLiveSet(exercise: exercises[29], date: dateFrom(workoutDate, hour: 16, minute: 29, seconds: 0), weight: 15.0, reps: 20, modelContext: modelContext)
        generateLiveSet(exercise: exercises[29], date: dateFrom(workoutDate, hour: 16, minute: 31, seconds: 0), weight: 17.5, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[29], date: dateFrom(workoutDate, hour: 16, minute: 36, seconds: 0), weight: 19.5, reps: 10, modelContext: modelContext)
        
        // Lateral raises (single cable) - exercises[14]
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 16, minute: 38, seconds: 0), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 16, minute: 41, seconds: 0), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 16, minute: 44, seconds: 0), weight: 15.0, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[14], date: dateFrom(workoutDate, hour: 16, minute: 46, seconds: 0), weight: 15.0, reps: 10, modelContext: modelContext)
        
        // Tricep dips - exercises[15] (bodyweight to weighted progression)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 46, seconds: 0), weight: 0.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 48, seconds: 0), weight: 0.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 50, seconds: 0), weight: 5.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 53, seconds: 0), weight: 5.0, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[15], date: dateFrom(workoutDate, hour: 16, minute: 56, seconds: 0), weight: 5.0, reps: 6, modelContext: modelContext)
        
        // Tricep pulls (rope) - exercises[27]
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 16, minute: 58, seconds: 0), weight: 39.5, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 17, minute: 1, seconds: 0), weight: 39.5, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 17, minute: 3, seconds: 0), weight: 39.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[27], date: dateFrom(workoutDate, hour: 17, minute: 14, seconds: 0), weight: 39.5, reps: 10, modelContext: modelContext)
    }
    
    // Aug 28, 2025 - Back and biceps session
    private static func generateLiveWorkout8(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 11, to: baseDate) ?? baseDate
        
        // Pull ups (proper) - exercises[26] (bodyweight)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 50, seconds: 0), weight: 0.0, reps: 5, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 52, seconds: 0), weight: 0.0, reps: 4, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 54, seconds: 0), weight: 0.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 52, seconds: 0), weight: 1.0, reps: 4, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 54, seconds: 0), weight: 1.0, reps: 3, modelContext: modelContext)
        generateLiveSet(exercise: exercises[26], date: dateFrom(workoutDate, hour: 14, minute: 55, seconds: 0), weight: 1.0, reps: 4, modelContext: modelContext)
        
        // Reverse cable fly - exercises[4]
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 15, minute: 0, seconds: 0), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 15, minute: 2, seconds: 0), weight: 15.0, reps: 13, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 15, minute: 5, seconds: 0), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[4], date: dateFrom(workoutDate, hour: 15, minute: 7, seconds: 0), weight: 15.0, reps: 9, modelContext: modelContext)
        
        // T bar row - exercises[3]
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 15, minute: 9, seconds: 0), weight: 25.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 15, minute: 12, seconds: 0), weight: 30.0, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 15, minute: 15, seconds: 0), weight: 30.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[3], date: dateFrom(workoutDate, hour: 15, minute: 18, seconds: 0), weight: 30.0, reps: 7, modelContext: modelContext)
        
        // Cable face pulls - exercises[6]
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 22, seconds: 0), weight: 50.5, reps: 13, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 24, seconds: 0), weight: 50.5, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 25, seconds: 0), weight: 50.5, reps: 10, modelContext: modelContext)
        
        // Dumbbell seated curls - exercises[5]
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 15, minute: 27, seconds: 0), weight: 10.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 15, minute: 31, seconds: 0), weight: 10.0, reps: 11, modelContext: modelContext)
        generateLiveSet(exercise: exercises[5], date: dateFrom(workoutDate, hour: 15, minute: 37, seconds: 0), weight: 10.0, reps: 11, modelContext: modelContext)
        
        // Dumbbell hammer curls - exercises[30]
        generateLiveSet(exercise: exercises[30], date: dateFrom(workoutDate, hour: 15, minute: 39, seconds: 0), weight: 10.0, reps: 15, modelContext: modelContext)
        generateLiveSet(exercise: exercises[30], date: dateFrom(workoutDate, hour: 15, minute: 41, seconds: 0), weight: 10.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[30], date: dateFrom(workoutDate, hour: 15, minute: 44, seconds: 0), weight: 10.0, reps: 11, modelContext: modelContext)

        // Press ups - exercises[25] (bodyweight progression)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 15, minute: 46, seconds: 0), weight: 0.0, reps: 20, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 15, minute: 48, seconds: 0), weight: 0.0, reps: 18, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 15, minute: 50, seconds: 0), weight: 2.5, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[25], date: dateFrom(workoutDate, hour: 15, minute: 52, seconds: 0), weight: 2.5, reps: 10, modelContext: modelContext)
    }

    // Sep 22, 2025 - Chest, shoulders, and triceps session
    private static func generateLiveWorkout9(exercises: [Exercise], baseDate: Date, modelContext: ModelContext) {
        let workoutDate = Calendar.current.date(byAdding: .day, value: 36, to: baseDate) ?? baseDate

        // Chest press - exercises[31] (new exercise added Sep 22)
        generateLiveSet(exercise: exercises[31], date: dateFrom(workoutDate, hour: 15, minute: 12, seconds: 0), weight: 20.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[31], date: dateFrom(workoutDate, hour: 15, minute: 13, seconds: 0), weight: 40.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[31], date: dateFrom(workoutDate, hour: 15, minute: 16, seconds: 0), weight: 50.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[31], date: dateFrom(workoutDate, hour: 15, minute: 17, seconds: 0), weight: 50.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[31], date: dateFrom(workoutDate, hour: 15, minute: 21, seconds: 0), weight: 50.0, reps: 9, modelContext: modelContext)

        // Incline chest press (machine) - exercises[6]
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 23, seconds: 0), weight: 10.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 25, seconds: 0), weight: 30.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 27, seconds: 0), weight: 30.0, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 30, seconds: 0), weight: 30.0, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[6], date: dateFrom(workoutDate, hour: 15, minute: 33, seconds: 0), weight: 30.0, reps: 7, modelContext: modelContext)

        // Lateral raises (single cable) - exercises[2]
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 15, minute: 37, seconds: 0), weight: 15.0, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 15, minute: 40, seconds: 0), weight: 17.5, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 15, minute: 42, seconds: 0), weight: 17.5, reps: 9, modelContext: modelContext)
        generateLiveSet(exercise: exercises[2], date: dateFrom(workoutDate, hour: 15, minute: 44, seconds: 0), weight: 17.5, reps: 10, modelContext: modelContext)

        // Shoulder press (machine) - exercises[32] (new exercise added Sep 22)
        generateLiveSet(exercise: exercises[32], date: dateFrom(workoutDate, hour: 15, minute: 47, seconds: 0), weight: 26.5, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[32], date: dateFrom(workoutDate, hour: 15, minute: 48, seconds: 0), weight: 32.0, reps: 7, modelContext: modelContext)
        generateLiveSet(exercise: exercises[32], date: dateFrom(workoutDate, hour: 15, minute: 50, seconds: 0), weight: 32.0, reps: 8, modelContext: modelContext)
        generateLiveSet(exercise: exercises[32], date: dateFrom(workoutDate, hour: 15, minute: 52, seconds: 0), weight: 32.0, reps: 8, modelContext: modelContext)

        // Tricep dips - exercises[16]
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 15, minute: 55, seconds: 0), weight: 0.0, reps: 6, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 15, minute: 56, seconds: 0), weight: 5.0, reps: 6, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 15, minute: 58, seconds: 0), weight: 5.0, reps: 10, modelContext: modelContext)
        generateLiveSet(exercise: exercises[16], date: dateFrom(workoutDate, hour: 16, minute: 0, seconds: 0), weight: 5.0, reps: 6, modelContext: modelContext)

        // Tricep pulls (rope) - exercises[22]
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 16, minute: 3, seconds: 0), weight: 39.5, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 16, minute: 5, seconds: 0), weight: 39.5, reps: 12, modelContext: modelContext)
        generateLiveSet(exercise: exercises[22], date: dateFrom(workoutDate, hour: 16, minute: 6, seconds: 0), weight: 39.5, reps: 10, modelContext: modelContext)
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
    
    // MARK: - Helper Methods
    
    private static func dateFrom(_ baseDate: Date, daysOffset: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var date = calendar.date(byAdding: .day, value: daysOffset, to: baseDate) ?? baseDate
        date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
        return date
    }
    
    private static func generateWorkoutSession(date: Date, exercises: [Exercise], weights: [Double], reps: [[Int]], modelContext: ModelContext) {
        for (index, exercise) in exercises.enumerated() {
            guard index < weights.count && index < reps.count else { continue }
            
            let weight = weights[index]
            let exerciseReps = reps[index]
            
            for (setIndex, repCount) in exerciseReps.enumerated() {
                // Add 2-3 minutes between sets
                let setDate = date.addingTimeInterval(Double(setIndex * 150))
                let set = ExerciseSet(timestamp: setDate, weight: weight, reps: repCount, exercise: exercise)
                modelContext.insert(set)
            }
        }
    }
    
}
#endif