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
        print("\n================================================================================")
        print("COMPLETE SWIFT FILE EXPORT - READY TO PASTE")
        print("================================================================================")

        // Fetch all exercises
        let exerciseDescriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.createdDate)]
        )

        guard let exercises = try? modelContext.fetch(exerciseDescriptor) else {
            print("Failed to fetch exercises")
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

        // Count sessions
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
                    workoutSessions.append(currentSession)
                    currentSession = [item]
                }
            }
            if index == allSets.count - 1 && !currentSession.isEmpty {
                workoutSessions.append(currentSession)
            }
        }

        print("SUMMARY:")
        print("- Total Exercises: \(exercises.count)")
        print("- Total Sets: \(allSets.count)")
        print("- Total Sessions: \(workoutSessions.count)")
        if let firstSet = allSets.first, let lastSet = allSets.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            print("- Date Range: \(dateFormatter.string(from: firstSet.set.timestamp)) - \(dateFormatter.string(from: lastSet.set.timestamp))")
        }
        print("")
        print("// COPY FROM HERE ========================================================")
        print("")

        // Print complete Swift file
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let startDate = allSets.first?.set.timestamp ?? Date()
        let endDate = allSets.last?.set.timestamp ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateRange = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"

        print("//")
        print("//  TestData.swift")
        print("//  PlainWeights")
        print("//")
        print("//  Created by Claude on 25/09/2025.")
        print("//  Last Updated: \(today)")
        print("//")
        print("//  Real Gym Data")
        print("//  \(exercises.count) exercises, \(workoutSessions.count) workout sessions (\(dateRange))")
        print("")
        print("#if DEBUG")
        print("import Foundation")
        print("import SwiftData")
        print("import os.log")
        print("")
        print("class TestData {")
        print("")
        print("    // MARK: - Public Interface")
        print("")
        print("    static func generate(modelContext: ModelContext) {")
        print("        let logger = Logger(subsystem: \"com.stephendawes.PlainWeights\", category: \"TestData\")")
        print("        logger.info(\"Generating test data (Real gym data - \(exercises.count) exercises, \(workoutSessions.count) sessions)...\")")
        print("")
        print("        // Clear existing data")
        print("        clearAllData(modelContext: modelContext)")
        print("")
        print("        generateGymData(modelContext: modelContext)")
        print("        logger.info(\"Test Data Set 4 generation completed\")")
        print("    }")
        print("")
        print("    // MARK: - Data Generation")
        print("")
        print("    private static func generateGymData(modelContext: ModelContext) {")
        print("        // EXPORT DATE: \(today)")
        print("")
        print("        // Exercise definitions with notes")
        print("        let exerciseData: [(name: String, category: String, note: String?)] = [")
        for exercise in exercises {
            if let note = exercise.note, !note.isEmpty {
                // Escape quotes in note text
                let escapedNote = note.replacingOccurrences(of: "\"", with: "\\\"")
                print("    (name: \"\(exercise.name)\", category: \"\(exercise.category)\", note: \"\(escapedNote)\"),")
            } else {
                print("    (name: \"\(exercise.name)\", category: \"\(exercise.category)\", note: nil),")
            }
        }
        print("        ]")
        print("")
        print("        // Create exercises")
        print("        var exercises: [String: Exercise] = [:]")
        print("        for data in exerciseData {")
        print("            let exercise = Exercise(name: data.name, category: data.category, note: data.note)")
        print("            exercises[data.name] = exercise")
        print("            modelContext.insert(exercise)")
        print("        }")
        print("")
        print("        // Helper function to create timestamps")
        print("        func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {")
        print("            var components = DateComponents()")
        print("            components.year = year")
        print("            components.month = month")
        print("            components.day = day")
        print("            components.hour = hour")
        print("            components.minute = minute")
        print("            components.second = second")
        print("            return Calendar.current.date(from: components)!")
        print("        }")
        print("")
        print("        // Helper function to add a working set")
        print("        func addSet(exercise: String, weight: Double, reps: Int, timestamp: Date) {")
        print("            guard let ex = exercises[exercise] else { return }")
        print("            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, exercise: ex)")
        print("            modelContext.insert(set)")
        print("        }")
        print("")
        print("        // Helper function to add a warm-up set")
        print("        func addWarmUpSet(exercise: String, weight: Double, reps: Int, timestamp: Date) {")
        print("            guard let ex = exercises[exercise] else { return }")
        print("            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: true, exercise: ex)")
        print("            modelContext.insert(set)")
        print("        }")
        print("")

        let sessionDateFormatter = DateFormatter()
        sessionDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for (sessionIndex, session) in workoutSessions.enumerated() {
            if let firstSet = session.first {
                print("        // SESSION \(sessionIndex + 1): \(sessionDateFormatter.string(from: firstSet.set.timestamp))")

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
                        print("        // \(first.exercise.name): \(group.count) sets")
                        for item in group {
                            let calendar = Calendar.current
                            let y = calendar.component(.year, from: item.set.timestamp)
                            let m = calendar.component(.month, from: item.set.timestamp)
                            let d = calendar.component(.day, from: item.set.timestamp)
                            let h = calendar.component(.hour, from: item.set.timestamp)
                            let min = calendar.component(.minute, from: item.set.timestamp)
                            let s = calendar.component(.second, from: item.set.timestamp)

                            if item.set.isWarmUp {
                                print("        addWarmUpSet(exercise: \"\(item.exercise.name)\", weight: \(item.set.weight), reps: \(item.set.reps), timestamp: date(\(y), \(m), \(d), \(h), \(min), \(s)))")
                            } else {
                                print("        addSet(exercise: \"\(item.exercise.name)\", weight: \(item.set.weight), reps: \(item.set.reps), timestamp: date(\(y), \(m), \(d), \(h), \(min), \(s)))")
                            }
                        }
                    }
                }
                print("")
            }
        }

        print("        // Save all changes")
        print("        do {")
        print("            try modelContext.save()")
        print("        } catch {")
        print("            print(\"Error saving test data: \\(error)\")")
        print("        }")
        print("    }")
        print("")
        print("    // MARK: - Cleanup")
        print("")
        print("    private static func clearAllData(modelContext: ModelContext) {")
        print("        do {")
        print("            try modelContext.delete(model: Exercise.self)")
        print("            try modelContext.delete(model: ExerciseSet.self)")
        print("            try modelContext.save()")
        print("        } catch {")
        print("            print(\"Error clearing data: \\(error)\")")
        print("        }")
        print("    }")
        print("}")
        print("")
        print("#endif")
        print("")
        print("// COPY TO HERE ==========================================================")
        print("")
        print("================================================================================")
        print("EXPORT COMPLETE - Paste entire output above into TestData.swift")
        print("================================================================================")
    }
    
    static func generateTestData(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestDataGenerator")
        logger.info("Generating test data (Real gym data)...")
        clearAllData(modelContext: modelContext)
        TestData.generate(modelContext: modelContext)
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
