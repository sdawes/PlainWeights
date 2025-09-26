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

// The separate test data generators are part of the same module

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
        logger.info("// EXPORT DATE: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium))")
        logger.info("")
        logger.info("// Exercise definitions with notes")
        logger.info("let exerciseData: [(name: String, category: String, note: String?)] = [")
        for exercise in exercises {
            if let note = exercise.note, !note.isEmpty {
                // Escape quotes in note text
                let escapedNote = note.replacingOccurrences(of: "\"", with: "\\\"")
                logger.info("    (name: \"\(exercise.name)\", category: \"\(exercise.category)\", note: \"\(escapedNote)\"),")
            } else {
                logger.info("    (name: \"\(exercise.name)\", category: \"\(exercise.category)\", note: nil),")
            }
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
                            let fullDateTime = DateFormatter()
                            fullDateTime.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let warmupFlag = item.set.isWarmUp ? " (warm-up)" : ""
                            logger.info("//   \(fullDateTime.string(from: item.set.timestamp)) - \(item.set.weight)kg x \(item.set.reps) reps\(warmupFlag)")
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
        TestData1_OneMonth.generate(modelContext: modelContext)
    }
    
    static func generateTestDataSet2(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 2 (1 year performance test data)...")
        clearAllData(modelContext: modelContext)
        TestData3_OneYear.generate(modelContext: modelContext)
    }
    
    static func generateTestDataSet3(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 3 (2 weeks simple data)...")
        clearAllData(modelContext: modelContext)
        TestData2_TwoWeeks.generate(modelContext: modelContext)
    }
    
    static func generateTestDataSet4(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating Test Data Set 4 (Live gym data)...")
        clearAllData(modelContext: modelContext)
        TestData4_GymData.generate(modelContext: modelContext)
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
    
    
    
    
}
#endif
