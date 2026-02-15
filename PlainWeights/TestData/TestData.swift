//
//  TestData.swift
//  PlainWeights
//
//  Created by Claude on 25/09/2025.
//  Last Updated: 15 Feb 2026 at 16:31:18
//
//  Real Gym Data
//  67 exercises, 75 workout sessions (22 Sep 2025 - 15 Feb 2026)

#if DEBUG
import Foundation
import SwiftData
import os.log

class TestData {

    // MARK: - Public Interface

    static func generate(modelContext: ModelContext) {
        let logger = Logger(subsystem: "com.stephendawes.PlainWeights", category: "TestData")
        logger.info("Generating test data (Real gym data - 67 exercises, 75 sessions)...")

        // Clear existing data
        clearAllData(modelContext: modelContext)

        generateGymData(modelContext: modelContext)
        logger.info("Test Data Set 4 generation completed")
    }

    // MARK: - Data Generation

    private static func generateGymData(modelContext: ModelContext) {
        // EXPORT DATE: 15 Feb 2026 at 16:31:18

        // Helper function to create timestamps
        func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = hour
            components.minute = minute
            components.second = second
            return Calendar.current.date(from: components)!
        }

        // Exercise definitions with notes and timestamps
        let exerciseData: [(name: String, tags: [String], secondaryTags: [String], note: String?, createdDate: Date, lastUpdated: Date)] = [
    (name: "Shoulder press machine ", tags: ["front delts"], secondaryTags: [], note: "4 - 32kg, 5 - 37.5, 6 - 43kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 7, 17, 55, 31)),
    (name: "Seated dumbbell curl (on knee)", tags: ["biceps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 5, 17, 0, 54)),
    (name: "Leg press", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 6, 16, 28, 48)),
    (name: "Reverse Cable Flys", tags: ["rear delts"], secondaryTags: ["rhomboids", "traps"], note: "2 15 and 3 17.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 14, 57, 15)),
    (name: "Standing dumbbell hammer curls", tags: ["biceps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 21, 17, 53, 6)),
    (name: "Seated cable row", tags: ["lats"], secondaryTags: [], note: "8 is 54kg, 9 is 59.5kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 8, 10, 58, 4)),
    (name: "Incline Dumbbell Chest Press", tags: ["upper chest", "front delts"], secondaryTags: ["triceps", "boxers"], note: "Include the raise as one", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 27, 46)),
    (name: "Cable chest flys mid", tags: ["chest"], secondaryTags: [], note: "6 holes from the top", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 1, 9, 17, 4)),
    (name: "Incline chest press machine", tags: ["chest"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 7, 17, 26, 16)),
    (name: "Overhead Tricep Rope Pulls", tags: ["triceps", "forearms"], secondaryTags: ["rear delts", "core"], note: "7 is 39.5, 8 is 45", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 25, 13)),
    (name: "Bicep rope curls", tags: ["biceps"], secondaryTags: ["forearms"], note: "8 is 45kg, , 9 is 50.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 15, 4, 16)),
    (name: "Seated tricep dips", tags: ["triceps"], secondaryTags: [], note: "With bench level box full out", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 5, 17, 58, 47)),
    (name: "Landmine Row", tags: ["lats"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 23, 19, 26, 42)),
    (name: "Dumbbell lateral raises", tags: ["side delts"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 27, 17, 26, 28)),
    (name: "Front lateral cable raise", tags: ["front delts"], secondaryTags: [], note: "3 is 17.5, 4 23 and 5 28.5, 2 handed pull", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 28, 16, 15, 36)),
    (name: "EZ bar curl", tags: ["biceps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 3, 17, 38, 25)),
    (name: "Ball tricep pushdown", tags: ["triceps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 8, 11, 29, 24)),
    (name: "Sled Push", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 6, 17, 6, 21)),
    (name: "Butterfly sit up", tags: ["abs"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 9, 26, 16, 59, 27)),
    (name: "Dumbbell hammer curls ", tags: ["biceps"], secondaryTags: [], note: "Single arm raises each count as one rep.", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 15, 22, 56)),
    (name: "Seated Incline dumbbell Curls", tags: ["biceps"], secondaryTags: [], note: "Bench number 5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 8, 11, 13, 2)),
    (name: "Dumbbell lunges", tags: ["quads", "glutes"], secondaryTags: [], note: "Recorded as single side reps", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 9, 17, 11, 47)),
    (name: "Romanian deadlift ", tags: ["hamstrings", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 6, 16, 45, 7)),
    (name: "Single cable lateral raise", tags: ["side delts", "rotator cuff"], secondaryTags: ["front delts", "upper traps"], note: "2 - 15kg, 3 - 17.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 25, 58)),
    (name: "Reverse dumbbell lateral flys", tags: ["rear delts"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 4, 15, 27, 8)),
    (name: "Hyper extensions", tags: ["glutes", "hamstrings"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 28, 17, 47, 19)),
    (name: "Knees to toe", tags: ["abs"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 14, 17, 19, 25)),
    (name: "Back squat", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 9, 16, 25, 30)),
    (name: "Lat pull down", tags: ["lats"], secondaryTags: [], note: "6- 47.5, 7- 48.5, 8 - 54, 9 - 59.5kg, 10 - 65kg", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 29, 17, 4, 5)),
    (name: "Dumbbell flys", tags: ["chest"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 7, 17, 7, 34)),
    (name: "Dumbbell chest press", tags: ["chest"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 18, 17, 15, 24)),
    (name: "Box jumps", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 15, 23, 4)),
    (name: "Tricep rope pushdown", tags: ["triceps"], secondaryTags: [], note: "7 - 39.5, 7 plus weight - 42, 8 - 45", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 3, 17, 14, 24)),
    (name: "Hamstring Curls", tags: ["hamstrings"], secondaryTags: [], note: "4 is 32kg, 5 is 37.5, 6 is 43kg, 7 is 48.5kg, , Front is right in middle , Back is 5 from back, Seat is far back", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 9, 16, 52, 32)),
    (name: "Straight Arm Lat Pulldown", tags: ["lats"], secondaryTags: ["rear delts", "triceps", "lower chest"], note: "8 is 45kg 9 is 50.5, 10 is 56kg, 11 is 61.5", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 15, 13, 11)),
    (name: "Chest press machine", tags: ["chest"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 7, 17, 36, 37)),
    (name: "Seated dumbbell Arnold press", tags: ["shoulders"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 29, 17, 25, 39)),
    (name: "T Bar Row", tags: ["lats", "rhomboids", "traps"], secondaryTags: ["rear delts", "biceps", "brachs"], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 14, 50, 11)),
    (name: "Chest Press", tags: ["mid chest", "triceps"], secondaryTags: ["front delts", "boxers"], note: "Start with 60 it's fine!", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 28, 23)),
    (name: "Press ups", tags: ["chest"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 8, 10, 40, 33)),
    (name: "Dumbbell split squats", tags: ["quads", "glutes"], secondaryTags: [], note: "Number of reps done on one side logged", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 25, 17, 23, 28)),
    (name: "Dumbbell shoulder shrugs", tags: ["traps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 1, 20, 50, 58)),
    (name: "Front lateral dumbbell raise", tags: ["front delts"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 29, 17, 36, 55)),
    (name: "Chest Cable Flys", tags: ["lower chest", "inner chest"], secondaryTags: ["front delts", "biceps"], note: "3 is 17.5 and 4 is 23", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 26, 54)),
    (name: "Pull ups", tags: ["lats"], secondaryTags: ["biceps", "rhomboids", "traps"], note: "Check notes", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 15, 15, 26, 9)),
    (name: "Tricep Dips (bar)", tags: ["triceps", "lower chest"], secondaryTags: ["front delts", "core"], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 11, 23, 24, 27)),
    (name: "Landmine Shoulder Press", tags: ["front delts"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 10, 23, 19, 18, 45)),
    (name: "Deadlifts (Trapbar)", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 1, 14, 16, 25, 47)),
    (name: "Barbell Lunges", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 9, 30, 17, 7, 30)),
    (name: "Leg Raises", tags: ["quads"], secondaryTags: [], note: "6 is 43kg, 7 is 48.5, 8 is 54, 9 is 59.5, 10 is 65", createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2026, 2, 9, 16, 31, 17)),
    (name: "Toes to bar", tags: ["abs"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 8, 16, 9, 47), lastUpdated: date(2025, 11, 9, 16, 37, 31)),
    (name: "Single arm back pull machine", tags: ["lats"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 9, 16, 6, 34), lastUpdated: date(2025, 11, 9, 16, 14, 21)),
    (name: "Barbell shoulder press", tags: ["front delts"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 10, 18, 2, 11), lastUpdated: date(2026, 1, 29, 16, 48, 44)),
    (name: "Deadlifts", tags: ["glutes", "hamstrings"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 20, 16, 25, 23), lastUpdated: date(2026, 2, 5, 17, 19, 23)),
    (name: "Dumbbell Romanian deadlift", tags: ["hamstrings", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 25, 17, 12, 23), lastUpdated: date(2025, 11, 25, 17, 15, 30)),
    (name: "Tricep ez bar", tags: ["triceps"], secondaryTags: [], note: nil as String?, createdDate: date(2025, 11, 28, 16, 50, 36), lastUpdated: date(2025, 11, 28, 16, 54, 15)),
    (name: "Neutral grip pull ups", tags: ["lats"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 4, 15, 41, 16), lastUpdated: date(2026, 1, 9, 15, 48, 36)),
    (name: "Hang cleans", tags: ["traps"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 6, 17, 6, 20), lastUpdated: date(2026, 1, 6, 17, 10, 35)),
    (name: "Front barbell squat", tags: ["quads", "glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 6, 17, 11, 52), lastUpdated: date(2026, 1, 6, 17, 12, 38)),
    (name: "Lu Raise", tags: ["side delts", "traps"], secondaryTags: ["front delts", "real delts"], note: nil as String?, createdDate: date(2026, 1, 7, 17, 38, 9), lastUpdated: date(2026, 2, 11, 23, 22, 32)),
    (name: "Front lateral raise plates", tags: ["front delts"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 7, 17, 38, 52), lastUpdated: date(2026, 1, 7, 17, 40, 46)),
    (name: "Single arm bicep cable curl", tags: ["biceps"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 14, 17, 7, 34), lastUpdated: date(2026, 1, 14, 17, 12, 10)),
    (name: "Plate loaded lat pulldown", tags: ["lats"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 25, 16, 30, 4), lastUpdated: date(2026, 1, 25, 16, 33, 55)),
    (name: "Angled rope row", tags: ["rear delts"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 1, 29, 16, 40, 39), lastUpdated: date(2026, 1, 29, 16, 46, 28)),
    (name: "Face pulls", tags: ["rear delts"], secondaryTags: [], note: "39.5 - 7, 8 - 45, 9 - 50.5", createdDate: date(2026, 1, 29, 17, 16, 34), lastUpdated: date(2026, 2, 8, 11, 36, 55)),
    (name: "Tricep dips (bench)", tags: ["triceps"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 2, 7, 18, 14, 8), lastUpdated: date(2026, 2, 7, 18, 19, 38)),
    (name: "Glute drive", tags: ["glutes"], secondaryTags: [], note: nil as String?, createdDate: date(2026, 2, 9, 16, 35, 47), lastUpdated: date(2026, 2, 9, 16, 40, 8)),
        ]

        // Create exercises
        var exercises: [String: Exercise] = [:]
        for data in exerciseData {
            let exercise = Exercise(name: data.name, tags: data.tags, secondaryTags: data.secondaryTags, note: data.note, createdDate: data.createdDate)
            exercise.lastUpdated = data.lastUpdated
            exercises[data.name] = exercise
            modelContext.insert(exercise)
        }

        // Helper function to add a working set
        func addSet(exercise: String, weight: Double, reps: Int, timestamp: Date, restSeconds: Int? = nil, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: false, isAssisted: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            set.restSeconds = restSeconds
            modelContext.insert(set)
        }

        // Helper function to add a warm-up set
        func addWarmUpSet(exercise: String, weight: Double, reps: Int, timestamp: Date, restSeconds: Int? = nil, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: true, isDropSet: false, isAssisted: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: false, exercise: ex)
            set.restSeconds = restSeconds
            modelContext.insert(set)
        }

        // Helper function to add a drop set
        func addDropSet(exercise: String, weight: Double, reps: Int, timestamp: Date, restSeconds: Int? = nil, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: true, isAssisted: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            set.restSeconds = restSeconds
            modelContext.insert(set)
        }

        // Helper function to add an assisted set
        func addAssistedSet(exercise: String, weight: Double, reps: Int, timestamp: Date, restSeconds: Int? = nil, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: false, isAssisted: true, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            set.restSeconds = restSeconds
            modelContext.insert(set)
        }

        // Helper function to add a to-failure set
        // Note: set isToFailure after creation when export generates this function
        func addToFailureSet(exercise: String, weight: Double, reps: Int, timestamp: Date, restSeconds: Int? = nil, isPauseAtTop: Bool = false, isTimedSet: Bool = false, tempoSeconds: Int = 0, isPB: Bool = false) {
            guard let ex = exercises[exercise] else { return }
            let set = ExerciseSet(timestamp: timestamp, weight: weight, reps: reps, isWarmUp: false, isDropSet: false, isAssisted: false, isPauseAtTop: isPauseAtTop, isTimedSet: isTimedSet, tempoSeconds: tempoSeconds, isPB: isPB, exercise: ex)
            set.restSeconds = restSeconds
            modelContext.insert(set)
        }

        // SESSION 1: 2025-09-22 17:00:00
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 0, 0), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 3, 0), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 17, 5, 0), restSeconds: 60)
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 10, 0), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 13, 0), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 22, 17, 15, 0), restSeconds: 60)
        // Chest Cable Flys: 3 sets
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 17, 0), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 20, 0), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 9, 22, 17, 23, 0), restSeconds: 60)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 25, 0), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 30, 0), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 9, 22, 17, 33, 0), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 35, 0), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 37, 0), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 22, 17, 40, 0), restSeconds: 60)
        // Back squat: 3 sets
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 0, 0), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 3, 0), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 22, 18, 5, 0), restSeconds: 60)
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 6, 0), isPB: true)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 9, 0), restSeconds: 60)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 22, 18, 12, 0), restSeconds: 60)
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 24, 0), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 26, 0), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 34.0, reps: 10, timestamp: date(2025, 9, 22, 18, 30, 0), restSeconds: 60)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 32, 0), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 35, 0), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 39.5, reps: 10, timestamp: date(2025, 9, 22, 18, 38, 0), restSeconds: 60)

        // SESSION 2: 2025-09-24 17:03:30
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 3, 30), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 7, 0), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 9, 0), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 9, 24, 17, 11, 0), restSeconds: 60)
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 14, 0), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 16, 0), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 18, 0), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 24, 17, 20, 0), restSeconds: 60)
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 22, 30), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 25, 0), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 27, 30), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 9, 24, 17, 30, 0), restSeconds: 60)
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 39, 0), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 41, 30), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 44, 0), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 12, timestamp: date(2025, 9, 24, 17, 46, 30), restSeconds: 60)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 49, 0), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 51, 30), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 9, 24, 17, 54, 0), restSeconds: 60)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 47, 30), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 48, 30), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 24, 20, 49, 30), restSeconds: 60)

        // SESSION 3: 2025-09-25 16:57:05
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 25, 16, 57, 5), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 13, timestamp: date(2025, 9, 25, 16, 58, 2), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 0, 9), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 25, 17, 1, 32), restSeconds: 60)
        // Hamstring Curls: 1 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 25, 17, 4, 30), restSeconds: 60)
        // Back squat: 5 sets
        addWarmUpSet(exercise: "Back squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 25, 17, 13, 4), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 40.0, reps: 8, timestamp: date(2025, 9, 25, 17, 15, 31), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 39), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 19, 44), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 8, timestamp: date(2025, 9, 25, 17, 21, 54), restSeconds: 60)
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 25, 36), restSeconds: 60)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 28, 6), restSeconds: 60)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 9, timestamp: date(2025, 9, 25, 17, 32, 50), restSeconds: 60)
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 11, timestamp: date(2025, 9, 25, 17, 41, 22), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 25, 17, 42, 28), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 12, timestamp: date(2025, 9, 25, 17, 46, 16), restSeconds: 60)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 48, 31), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2025, 9, 25, 17, 49, 56), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 9, timestamp: date(2025, 9, 25, 17, 52, 8), restSeconds: 60)

        // SESSION 4: 2025-09-26 16:16:57
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 12, timestamp: date(2025, 9, 26, 16, 16, 57), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 13, timestamp: date(2025, 9, 26, 16, 19, 9), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 7.5, reps: 15, timestamp: date(2025, 9, 26, 16, 22, 17), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 9, 26, 16, 25, 12), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 27, 22), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 9, 26, 16, 30, 22), restSeconds: 60)
        // Front lateral cable raise: 3 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 12, timestamp: date(2025, 9, 26, 16, 34, 9), restSeconds: 60)
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 35, 47), restSeconds: 60)
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 10, timestamp: date(2025, 9, 26, 16, 37, 55), restSeconds: 60)
        // Seated dumbbell Arnold press: 4 sets
        addSet(exercise: "Seated dumbbell Arnold press", weight: 7.5, reps: 10, timestamp: date(2025, 9, 26, 16, 39, 59), restSeconds: 60)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 41, 25), restSeconds: 60)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 10, timestamp: date(2025, 9, 26, 16, 43, 45), restSeconds: 60)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 10.0, reps: 12, timestamp: date(2025, 9, 26, 16, 47, 38), restSeconds: 60)
        // Butterfly sit up: 2 sets
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 57, 33), isPB: true)
        addSet(exercise: "Butterfly sit up", weight: 0.0, reps: 15, timestamp: date(2025, 9, 26, 16, 59, 27), restSeconds: 60)

        // SESSION 5: 2025-09-27 16:41:23
        // Chest Press: 6 sets
        addWarmUpSet(exercise: "Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 41, 23), restSeconds: 60)
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 8, timestamp: date(2025, 9, 27, 16, 41, 36), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 5, timestamp: date(2025, 9, 27, 16, 44, 32), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 9, 27, 16, 46, 53), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 9, 27, 16, 49, 41), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 9, 27, 16, 52, 45), restSeconds: 60)
        // Incline Dumbbell Chest Press: 4 sets
        addWarmUpSet(exercise: "Incline Dumbbell Chest Press", weight: 17.5, reps: 8, timestamp: date(2025, 9, 27, 16, 55, 12), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 10, timestamp: date(2025, 9, 27, 16, 56, 47), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 0, 12), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 20.0, reps: 11, timestamp: date(2025, 9, 27, 17, 3, 31), restSeconds: 60)
        // Dumbbell flys: 3 sets
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 7, timestamp: date(2025, 9, 27, 17, 5, 27), restSeconds: 60)
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 14, timestamp: date(2025, 9, 27, 17, 8, 59))
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 10, timestamp: date(2025, 9, 27, 17, 12, 57), restSeconds: 180)
        // Tricep Dips (bar): 4 sets
        addWarmUpSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 8, timestamp: date(2025, 9, 27, 17, 15, 10), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 17, 1), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 19, 23), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 7, timestamp: date(2025, 9, 27, 17, 21, 59), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 5 sets
        addWarmUpSet(exercise: "Overhead Tricep Rope Pulls", weight: 28.5, reps: 10, timestamp: date(2025, 9, 27, 17, 24, 57), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 12, timestamp: date(2025, 9, 27, 17, 27, 11), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 29, 38), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 6, timestamp: date(2025, 9, 27, 17, 31, 31), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 8, timestamp: date(2025, 9, 27, 17, 34, 3), restSeconds: 60)

        // SESSION 6: 2025-09-29 17:06:07
        // Straight Arm Lat Pulldown: 3 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 45.0, reps: 13, timestamp: date(2025, 9, 29, 17, 6, 7), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 47.5, reps: 12, timestamp: date(2025, 9, 29, 17, 8, 3), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 47.5, reps: 10, timestamp: date(2025, 9, 29, 17, 10, 0), restSeconds: 60)
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 9, timestamp: date(2025, 9, 29, 17, 11, 39), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 9, timestamp: date(2025, 9, 29, 17, 13, 40), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 15, 59), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 9, 29, 17, 18, 59), restSeconds: 60)
        // Reverse dumbbell lateral flys: 2 sets
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 10.0, reps: 12, timestamp: date(2025, 9, 29, 17, 23, 8), restSeconds: 60)
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 12.0, reps: 12, timestamp: date(2025, 9, 29, 17, 24, 57))
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 30, 21), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 9, 29, 17, 32, 0), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 35, 9), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 9, 29, 17, 38, 39), restSeconds: 60)
        // Bicep rope curls: 4 sets
        addWarmUpSet(exercise: "Bicep rope curls", weight: 42.0, reps: 14, timestamp: date(2025, 9, 29, 17, 40, 14), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 41, 54), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 43, 4), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 9, timestamp: date(2025, 9, 29, 17, 45, 12), restSeconds: 60)

        // SESSION 7: 2025-09-29 20:51:28
        // Reverse dumbbell lateral flys: 1 sets
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 10.0, reps: 15, timestamp: date(2025, 9, 29, 20, 51, 28), restSeconds: 180)

        // SESSION 8: 2025-09-30 16:48:49
        // Back squat: 5 sets
        addWarmUpSet(exercise: "Back squat", weight: 20.0, reps: 15, timestamp: date(2025, 9, 30, 16, 48, 49), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 51, 24), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 54, 4), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 56, 13), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 50.0, reps: 10, timestamp: date(2025, 9, 30, 16, 58, 25), restSeconds: 60)
        // Barbell Lunges: 3 sets
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 0, 30), restSeconds: 60)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 4, 10), restSeconds: 60)
        addSet(exercise: "Barbell Lunges", weight: 30.0, reps: 12, timestamp: date(2025, 9, 30, 17, 7, 30), restSeconds: 60)
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 14, timestamp: date(2025, 9, 30, 17, 11, 9), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 14, timestamp: date(2025, 9, 30, 17, 12, 28), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 16, timestamp: date(2025, 9, 30, 17, 14, 0), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 15, 31), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 13, timestamp: date(2025, 9, 30, 17, 17, 23), restSeconds: 60)
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 37.5, reps: 11, timestamp: date(2025, 9, 30, 17, 19, 5), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 48.5, reps: 10, timestamp: date(2025, 9, 30, 17, 20, 2), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 8, timestamp: date(2025, 9, 30, 17, 21, 33), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 9, 30, 17, 23, 15), restSeconds: 60)

        // SESSION 9: 2025-10-01 20:19:17
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 19, 17), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 1, 20, 21, 22), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 10, timestamp: date(2025, 10, 1, 20, 25, 30), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 1, 20, 37, 12), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 38, 10), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 1, 20, 40, 23), restSeconds: 60)
        // Dumbbell shoulder shrugs: 1 sets
        addSet(exercise: "Dumbbell shoulder shrugs", weight: 22.5, reps: 12, timestamp: date(2025, 10, 1, 20, 50, 58), isPB: true)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 56, 5), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 20, 58, 31), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 0, 55), restSeconds: 60)
        // Hyper extensions: 3 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 11, timestamp: date(2025, 10, 1, 21, 9, 45), restSeconds: 60)
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 11, 10), restSeconds: 60)
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 1, 21, 13, 8), restSeconds: 60)

        // SESSION 10: 2025-10-02 16:12:52
        // Chest Press: 5 sets
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 9, timestamp: date(2025, 10, 2, 16, 12, 52), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 14, 54), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 17, 30), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 10, 2, 16, 19, 59), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 7, timestamp: date(2025, 10, 2, 16, 22, 51), restSeconds: 60)
        // Incline chest press machine: 2 sets
        addWarmUpSet(exercise: "Incline chest press machine", weight: 20.0, reps: 10, timestamp: date(2025, 10, 2, 16, 25, 59), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 8, timestamp: date(2025, 10, 2, 16, 28, 18), restSeconds: 60)
        // Chest Cable Flys: 4 sets
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 2, 16, 35, 43), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 37, 38), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 39, 24), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 10, 2, 16, 40, 55), restSeconds: 60)
        // Incline chest press machine: 2 sets
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 8), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 16, 44, 13), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addWarmUpSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 8, timestamp: date(2025, 10, 2, 16, 45, 5), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 46, 50), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 10, 2, 16, 50, 5), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 7, timestamp: date(2025, 10, 2, 16, 52, 55), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 2, 16, 57, 27), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 16, 59, 14))
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 1, 16), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 9, timestamp: date(2025, 10, 2, 17, 3, 41), restSeconds: 60)

        // SESSION 11: 2025-10-02 20:28:56
        // T Bar Row: 1 sets
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 10, timestamp: date(2025, 10, 2, 20, 28, 56), restSeconds: 60)

        // SESSION 12: 2025-10-04 10:08:18
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 9, timestamp: date(2025, 10, 4, 10, 8, 18), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 10, 4, 10, 11, 10), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 8, timestamp: date(2025, 10, 4, 10, 14, 34), restSeconds: 60)
        // Seated cable row: 1 sets
        addSet(exercise: "Seated cable row", weight: 54.0, reps: 10, timestamp: date(2025, 10, 4, 10, 21, 42), restSeconds: 180)
        // Deadlifts (Trapbar): 3 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 4, 10, 26, 16), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 28, 3), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 4, 10, 31, 47), restSeconds: 60)
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 10, 4, 10, 32, 58), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 35, 38), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 4, 10, 38, 16), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 6, timestamp: date(2025, 10, 4, 10, 39, 52), restSeconds: 60)

        // SESSION 13: 2025-10-06 16:36:26
        // Leg press: 4 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2025, 10, 6, 16, 36, 26), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 38, 42), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 40, 44), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 6, 16, 43, 20), restSeconds: 60)
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 37.5, reps: 15, timestamp: date(2025, 10, 6, 16, 48, 45), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 6, 16, 49, 49), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 6, 16, 52, 3), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 6, 16, 54, 52), restSeconds: 60)
        // Sled Push: 4 sets
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 16, 58, 9), isPB: true)
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 0, 11), restSeconds: 60)
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 2, 56), restSeconds: 60)
        addSet(exercise: "Sled Push", weight: 50.0, reps: 0, timestamp: date(2025, 10, 6, 17, 6, 21), restSeconds: 60)

        // SESSION 14: 2025-10-07 16:46:03
        // Dumbbell chest press: 4 sets
        addWarmUpSet(exercise: "Dumbbell chest press", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 16, 46, 3), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 47, 4), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 51, 9), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 7, 16, 53, 43), restSeconds: 60)
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 8, timestamp: date(2025, 10, 7, 16, 55, 28), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 7, 16, 58, 34), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 10, 7, 17, 1, 58), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addWarmUpSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 7, timestamp: date(2025, 10, 7, 17, 11, 44), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 10, 7, 17, 13, 12), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 15, 43), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 8, timestamp: date(2025, 10, 7, 17, 19, 19), restSeconds: 60)
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 7, 17, 22, 27), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 25, 36), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 26, 29), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 7, 17, 28, 51), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 30, 18), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 32, 26), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 7, 17, 34, 27), restSeconds: 60)
        // Chest Cable Flys: 3 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2025, 10, 7, 17, 38, 31), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 11, timestamp: date(2025, 10, 7, 17, 39, 39), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 7, 17, 42, 29), restSeconds: 60)

        // SESSION 15: 2025-10-08 16:25:55
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 25, 55), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 26, 15), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 28, 7), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 8, 16, 31, 5), restSeconds: 60)
        // T Bar Row: 4 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 10, timestamp: date(2025, 10, 8, 16, 34, 47), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 8, timestamp: date(2025, 10, 8, 16, 36, 23), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 10, timestamp: date(2025, 10, 8, 16, 39, 27), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 32.0, reps: 9, timestamp: date(2025, 10, 8, 16, 42, 42), restSeconds: 60)
        // Reverse Cable Flys: 4 sets
        addWarmUpSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 13, timestamp: date(2025, 10, 8, 16, 45, 7), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 47, 50), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 8, 16, 50, 10), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 10, 8, 16, 52, 20), restSeconds: 60)
        // Straight Arm Lat Pulldown: 3 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 45.0, reps: 14, timestamp: date(2025, 10, 8, 16, 54, 55), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 56, 31), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.0, reps: 9, timestamp: date(2025, 10, 8, 16, 58, 2), restSeconds: 60)
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 8, 16, 59, 49), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 1, 55), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 3, 54), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 8, 17, 7, 19), restSeconds: 60)
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 8, 50), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 8, 17, 10, 5), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 8, 17, 11, 33), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 5, timestamp: date(2025, 10, 8, 18, 5, 41), restSeconds: 60)

        // SESSION 16: 2025-10-09 21:27:42
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 10, 9, 21, 27, 42), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 22.0, reps: 14, timestamp: date(2025, 10, 9, 21, 28, 8), restSeconds: 60)

        // SESSION 17: 2025-10-10 16:26:45
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 10, 16, 26, 45), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 10, 10, 16, 30, 50), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 33, 45), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 36, 25), restSeconds: 60)
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 10, 16, 39, 58), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 10, 16, 43, 10), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 7, timestamp: date(2025, 10, 10, 16, 46, 8), restSeconds: 60)
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 10, timestamp: date(2025, 10, 10, 16, 51, 26), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 10, timestamp: date(2025, 10, 10, 16, 51, 30), restSeconds: 60)
        // Dumbbell lateral raises: 4 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 14, timestamp: date(2025, 10, 10, 16, 53, 22), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 10, 16, 55, 49), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 14, timestamp: date(2025, 10, 10, 16, 58, 13), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 11, timestamp: date(2025, 10, 10, 17, 1, 1), restSeconds: 60)
        // Shoulder press machine : 4 sets
        addSet(exercise: "Shoulder press machine ", weight: 32.0, reps: 10, timestamp: date(2025, 10, 10, 17, 3, 54), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 32.0, reps: 10, timestamp: date(2025, 10, 10, 17, 4, 56), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 10, 17, 6, 45), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 7, timestamp: date(2025, 10, 10, 17, 8, 38), restSeconds: 60)
        // Leg Raises: 4 sets
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 10, timestamp: date(2025, 10, 10, 17, 10, 29), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 54.0, reps: 12, timestamp: date(2025, 10, 10, 17, 12, 5), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 10, 10, 17, 13, 44), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 10, 10, 17, 14, 51), restSeconds: 60)
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 10, 17, 17, 57), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 10, 17, 19, 37), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 10, 10, 17, 21, 26), restSeconds: 60)

        // SESSION 18: 2025-10-11 08:37:00
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2025, 10, 11, 8, 37, 0), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 37, 45), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 40, 1), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 110.0, reps: 10, timestamp: date(2025, 10, 11, 8, 41, 39), restSeconds: 60)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 54.0, reps: 10, timestamp: date(2025, 10, 11, 8, 52, 4), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 54.0, reps: 10, timestamp: date(2025, 10, 11, 8, 54, 17), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 7, timestamp: date(2025, 10, 11, 8, 56, 39), restSeconds: 60)
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 25.0, reps: 10, timestamp: date(2025, 10, 11, 8, 58, 56), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 30.0, reps: 8, timestamp: date(2025, 10, 11, 9, 1, 19), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 32.5, reps: 7, timestamp: date(2025, 10, 11, 9, 3, 27), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 32.5, reps: 10, timestamp: date(2025, 10, 11, 9, 6, 48), restSeconds: 60)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 8, timestamp: date(2025, 10, 11, 9, 9, 49), restSeconds: 60)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 10, 11, 9, 12, 53), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2025, 10, 11, 9, 14, 45), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 10, 11, 9, 19, 16), restSeconds: 60)
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 11, 9, 20, 11), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 11, 9, 22, 57), restSeconds: 60)

        // SESSION 19: 2025-10-13 19:10:59
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 20.0, reps: 14, timestamp: date(2025, 10, 13, 19, 10, 59), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 25.0, reps: 13, timestamp: date(2025, 10, 13, 19, 11, 10), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 12, timestamp: date(2025, 10, 13, 19, 11, 19), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 35.0, reps: 10, timestamp: date(2025, 10, 13, 19, 11, 28), restSeconds: 60)
        // Chest press machine: 4 sets
        addSet(exercise: "Chest press machine", weight: 35.0, reps: 12, timestamp: date(2025, 10, 13, 19, 13, 3), restSeconds: 60)
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 13, 19, 15, 52), restSeconds: 60)
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 10, timestamp: date(2025, 10, 13, 19, 18, 55), restSeconds: 60)
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 13, 19, 21, 32), restSeconds: 60)
        // Shoulder press machine : 3 sets
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 13, 19, 26, 2), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2025, 10, 13, 19, 28, 16), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 9, timestamp: date(2025, 10, 13, 19, 30, 52), restSeconds: 60)
        // Single cable lateral raise: 2 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 10, timestamp: date(2025, 10, 13, 19, 33, 8), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 35, 13), restSeconds: 60)
        // Front lateral cable raise: 2 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 35, 28), restSeconds: 60)
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 38, 27), restSeconds: 60)
        // Single cable lateral raise: 2 sets
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 38, 34), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 41, 7), restSeconds: 60)
        // Front lateral cable raise: 1 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 13, 19, 41, 13), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addWarmUpSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 8, timestamp: date(2025, 10, 13, 19, 44, 17), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 7, timestamp: date(2025, 10, 13, 19, 45, 53), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 10, 13, 19, 48, 14), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 10, 13, 19, 50, 56), restSeconds: 60)

        // SESSION 20: 2025-10-15 11:33:50
        // Chest press machine: 2 sets
        addSet(exercise: "Chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 15, 11, 33, 50), restSeconds: 60)
        addSet(exercise: "Chest press machine", weight: 55.0, reps: 13, timestamp: date(2025, 10, 15, 11, 34, 0), restSeconds: 60)

        // SESSION 21: 2025-10-15 16:45:53
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 15, 16, 45, 53), restSeconds: 60)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2025, 10, 15, 16, 46, 35), restSeconds: 60)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 10, 15, 16, 50, 27), restSeconds: 60)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 15, 16, 51, 9), restSeconds: 60)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 12, timestamp: date(2025, 10, 15, 16, 55, 41), restSeconds: 60)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 10, 15, 16, 56, 35), restSeconds: 60)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 12, timestamp: date(2025, 10, 15, 16, 58, 43), restSeconds: 60)
        // Straight Arm Lat Pulldown: 2 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.0, reps: 11, timestamp: date(2025, 10, 15, 17, 2, 6), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.0, reps: 11, timestamp: date(2025, 10, 15, 17, 3, 54), restSeconds: 60)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 10, 15, 17, 4, 3), restSeconds: 60)
        // T Bar Row: 4 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 10, timestamp: date(2025, 10, 15, 17, 8, 22), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 10, 15, 17, 10, 19), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 15, 17, 12, 54), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 7, timestamp: date(2025, 10, 15, 17, 15, 10), restSeconds: 60)
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2025, 10, 15, 17, 22, 30), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 10, timestamp: date(2025, 10, 15, 17, 25, 31), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 10, 15, 17, 27, 12), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 10, timestamp: date(2025, 10, 15, 17, 29, 3), restSeconds: 60)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 10, 15, 17, 31, 5), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 15, 17, 33, 8), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 8, timestamp: date(2025, 10, 15, 17, 35, 22), restSeconds: 60)

        // SESSION 22: 2025-10-16 19:29:22
        // Leg press: 4 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 14, timestamp: date(2025, 10, 16, 19, 29, 22), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 32, 38), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 35, 17), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 115.0, reps: 10, timestamp: date(2025, 10, 16, 19, 37, 50), restSeconds: 60)
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 37.5, reps: 12, timestamp: date(2025, 10, 16, 19, 42, 0), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 11, timestamp: date(2025, 10, 16, 19, 44, 15), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 16, 19, 46, 39), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 9, timestamp: date(2025, 10, 16, 19, 50, 26), restSeconds: 60)
        // Leg Raises: 4 sets
        addWarmUpSet(exercise: "Leg Raises", weight: 45.5, reps: 10, timestamp: date(2025, 10, 16, 19, 51, 52), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 9, timestamp: date(2025, 10, 16, 19, 52, 58), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 16, 19, 55, 26), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 16, 19, 57, 31), restSeconds: 60)
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 16, 20, 2, 15), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 16, 20, 4, 37), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 67.5, reps: 10, timestamp: date(2025, 10, 16, 20, 8, 12), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 67.5, reps: 9, timestamp: date(2025, 10, 16, 20, 10, 35), restSeconds: 60)
        // Dumbbell split squats: 3 sets
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 10, timestamp: date(2025, 10, 16, 20, 15, 24), restSeconds: 60)
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 10, timestamp: date(2025, 10, 16, 20, 16, 47), restSeconds: 60)
        addSet(exercise: "Dumbbell split squats", weight: 10.0, reps: 7, timestamp: date(2025, 10, 16, 20, 20, 34), restSeconds: 60)
        // Hyper extensions: 2 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 16, 20, 29, 14), restSeconds: 60)
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 16, 20, 30, 13), restSeconds: 60)

        // SESSION 23: 2025-10-17 13:31:15
        // Chest press machine: 3 sets
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 15), isPB: true)
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 18), restSeconds: 60)
        addSet(exercise: "Chest press machine", weight: 56.0, reps: 10, timestamp: date(2025, 10, 17, 13, 31, 21), restSeconds: 180)

        // SESSION 24: 2025-10-18 09:45:27
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 9, timestamp: date(2025, 10, 18, 9, 45, 27), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 10, 18, 9, 47, 55), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 9, 55, 49), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 9, timestamp: date(2025, 10, 18, 9, 56, 37), restSeconds: 60)
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 1, 58), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 5, 29), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 10, 18, 10, 12, 10), restSeconds: 60)
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2025, 10, 18, 10, 20, 34))
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2025, 10, 18, 10, 22, 58), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 10, 18, 10, 26, 44), restSeconds: 60)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 10, 18, 10, 37, 37), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 10, 18, 10, 38, 25), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 10, 18, 10, 42, 2), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 18, 10, 45, 15), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 10, timestamp: date(2025, 10, 18, 10, 50, 4), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 9, timestamp: date(2025, 10, 18, 10, 50, 7), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 7, timestamp: date(2025, 10, 18, 10, 52, 2), restSeconds: 60)

        // SESSION 25: 2025-10-21 17:15:43
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 8, timestamp: date(2025, 10, 21, 17, 15, 43), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 21, 17, 17, 27), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 21, 17, 20, 4), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 21, 17, 22, 16), restSeconds: 60)
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 9, timestamp: date(2025, 10, 21, 17, 25, 14), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 30, 18), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 30, 21), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 10, 21, 17, 32, 49), restSeconds: 60)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 9, timestamp: date(2025, 10, 21, 17, 35, 47), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 9, timestamp: date(2025, 10, 21, 17, 38, 2), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 7, timestamp: date(2025, 10, 21, 17, 40, 30), restSeconds: 60)
        // Standing dumbbell hammer curls: 3 sets
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 20, timestamp: date(2025, 10, 21, 17, 48, 55), isPB: true)
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 18, timestamp: date(2025, 10, 21, 17, 50, 35), restSeconds: 60)
        addSet(exercise: "Standing dumbbell hammer curls", weight: 12.5, reps: 20, timestamp: date(2025, 10, 21, 17, 53, 6), restSeconds: 60)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 54, 27), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 56, 11), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 21, 17, 57, 51), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 2, 47), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 5, 28), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 10, 21, 18, 7, 15), restSeconds: 60)

        // SESSION 26: 2025-10-22 19:32:22
        // Hamstring Curls: 4 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 22, 19, 32, 22), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 22, 19, 34, 23), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 6, timestamp: date(2025, 10, 22, 19, 36, 21), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 37.5, reps: 5, timestamp: date(2025, 10, 22, 19, 36, 55), restSeconds: 60)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 22, 19, 39, 55), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 10, 22, 19, 41, 23), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 22, 19, 43, 33), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 10, 22, 19, 48, 13), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 10, 22, 19, 50, 13), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 10, 22, 19, 53, 3), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 10, 22, 19, 55, 26), restSeconds: 60)
        // Incline chest press machine: 3 sets
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 10, 22, 19, 59, 16), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 10, 22, 20, 1, 25), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 10, 22, 20, 3, 34), restSeconds: 60)
        // T Bar Row: 5 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 12, timestamp: date(2025, 10, 22, 20, 5, 56), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 22, 20, 8, 13), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 9, timestamp: date(2025, 10, 22, 20, 11, 21), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 10, 22, 20, 13, 41), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 20.0, reps: 8, timestamp: date(2025, 10, 22, 20, 14, 49), restSeconds: 60)

        // SESSION 27: 2025-10-23 19:14:25
        // Landmine Shoulder Press: 3 sets
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 14, 25), isPB: true)
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 16, 41), restSeconds: 60)
        addSet(exercise: "Landmine Shoulder Press", weight: 10.0, reps: 10, timestamp: date(2025, 10, 23, 19, 18, 45), restSeconds: 60)
        // Landmine Row: 3 sets
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 12, timestamp: date(2025, 10, 23, 19, 22, 17), restSeconds: 60)
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 15, timestamp: date(2025, 10, 23, 19, 24, 28), isPB: true)
        addSet(exercise: "Landmine Row", weight: 25.0, reps: 15, timestamp: date(2025, 10, 23, 19, 26, 42), restSeconds: 60)
        // Reverse Cable Flys: 2 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 23, 19, 29, 26), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 12, timestamp: date(2025, 10, 23, 19, 30, 59), restSeconds: 60)

        // SESSION 28: 2025-10-28 16:35:49
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2025, 10, 28, 16, 35, 49), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 9, timestamp: date(2025, 10, 28, 16, 37, 41), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 41, 3), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 43, 37), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 28, 16, 46, 22), restSeconds: 60)
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 15, timestamp: date(2025, 10, 28, 16, 48, 59), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 10, 28, 16, 51, 21), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 16, 53, 52), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 16, 57, 57), restSeconds: 60)
        // Leg Raises: 4 sets
        addWarmUpSet(exercise: "Leg Raises", weight: 43.0, reps: 12, timestamp: date(2025, 10, 28, 16, 59, 11), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 1, 8), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 3, 16), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 10, 28, 17, 6, 3), restSeconds: 60)
        // Hamstring Curls: 1 sets
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 10, 28, 17, 7, 29), restSeconds: 60)
        // Dumbbell lunges: 3 sets
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 10, timestamp: date(2025, 10, 28, 17, 20, 15), restSeconds: 60)
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 14, timestamp: date(2025, 10, 28, 17, 20, 22), restSeconds: 60)
        addSet(exercise: "Dumbbell lunges", weight: 10.0, reps: 14, timestamp: date(2025, 10, 28, 17, 22, 27), restSeconds: 60)
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 10, 28, 17, 27, 50), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 10, 28, 17, 29, 36), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 10, timestamp: date(2025, 10, 28, 17, 32, 44), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 10, 28, 17, 35, 43), isPB: true)
        // Hyper extensions: 3 sets
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 28, 17, 46, 13), restSeconds: 60)
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 12, timestamp: date(2025, 10, 28, 17, 46, 16), restSeconds: 60)
        addSet(exercise: "Hyper extensions", weight: 0.0, reps: 13, timestamp: date(2025, 10, 28, 17, 47, 19), isPB: true)

        // SESSION 29: 2025-10-29 16:57:05
        // EZ bar curl: 4 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 15, timestamp: date(2025, 10, 29, 16, 57, 5), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 11, timestamp: date(2025, 10, 29, 16, 57, 12), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 11, timestamp: date(2025, 10, 29, 16, 59, 25), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 9.0, reps: 12, timestamp: date(2025, 10, 29, 17, 1, 56), restSeconds: 60)
        // Bicep rope curls: 4 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 10, 29, 17, 4, 7), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 14, timestamp: date(2025, 10, 29, 17, 6, 13), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 15, timestamp: date(2025, 10, 29, 17, 8, 44), restSeconds: 60)
        addDropSet(exercise: "Bicep rope curls", weight: 45.0, reps: 12, timestamp: date(2025, 10, 29, 17, 11, 42), restSeconds: 60)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 29, 17, 13, 52), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 10, 29, 17, 16, 2), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 10, timestamp: date(2025, 10, 29, 17, 18, 2), restSeconds: 60)
        // Seated dumbbell Arnold press: 3 sets
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 8, timestamp: date(2025, 10, 29, 17, 20, 58), restSeconds: 60)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 10, timestamp: date(2025, 10, 29, 17, 23, 15), isPB: true)
        addSet(exercise: "Seated dumbbell Arnold press", weight: 12.0, reps: 8, timestamp: date(2025, 10, 29, 17, 25, 39), restSeconds: 60)
        // Dumbbell lateral raises: 1 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 27, 53), restSeconds: 60)
        // Front lateral dumbbell raise: 1 sets
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 10, timestamp: date(2025, 10, 29, 17, 28, 39), isPB: true)
        // Dumbbell lateral raises: 1 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 31, 9), restSeconds: 60)
        // Front lateral dumbbell raise: 2 sets
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 6, timestamp: date(2025, 10, 29, 17, 31, 20), restSeconds: 60)
        addSet(exercise: "Front lateral dumbbell raise", weight: 10.0, reps: 7, timestamp: date(2025, 10, 29, 17, 36, 55), restSeconds: 60)
        // Dumbbell lateral raises: 2 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 36, 59), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 12, timestamp: date(2025, 10, 29, 17, 37, 2), restSeconds: 60)
        // Ball tricep pushdown: 3 sets
        addSet(exercise: "Ball tricep pushdown", weight: 17.5, reps: 12, timestamp: date(2025, 10, 29, 17, 39, 29), restSeconds: 60)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 10, timestamp: date(2025, 10, 29, 17, 40, 29))
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 10, timestamp: date(2025, 10, 29, 17, 43, 1), restSeconds: 180)
        // Tricep rope pushdown: 2 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 11, timestamp: date(2025, 10, 29, 17, 44, 33), restSeconds: 60)
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 29, 17, 46, 49), restSeconds: 60)

        // SESSION 30: 2025-10-30 18:59:43
        // Tricep rope pushdown: 1 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 10, 30, 18, 59, 43), restSeconds: 60)
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 30, 19, 14, 10), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 10, 30, 19, 16, 3), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 6, timestamp: date(2025, 10, 30, 19, 18, 22), restSeconds: 60)
        addDropSet(exercise: "Leg press", weight: 100.0, reps: 12, timestamp: date(2025, 10, 30, 19, 22, 8), restSeconds: 60)
        // Romanian deadlift : 3 sets
        addSet(exercise: "Romanian deadlift ", weight: 40.0, reps: 10, timestamp: date(2025, 10, 30, 19, 25, 37), restSeconds: 60)
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 10, timestamp: date(2025, 10, 30, 19, 27, 28), restSeconds: 60)
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 10, timestamp: date(2025, 10, 30, 19, 34, 42), restSeconds: 60)
        // Dumbbell split squats: 1 sets
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 6, timestamp: date(2025, 10, 30, 19, 34, 58), restSeconds: 60)
        // Toes to bar: 4 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 41, 37), restSeconds: 60)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 43, 30), restSeconds: 60)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 10, 30, 19, 45, 44), restSeconds: 60)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 6, timestamp: date(2025, 10, 30, 19, 47, 25), restSeconds: 60)
        // Box jumps: 3 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 10, timestamp: date(2025, 10, 30, 19, 56, 47), restSeconds: 60)
        addSet(exercise: "Box jumps", weight: 0.0, reps: 12, timestamp: date(2025, 10, 30, 19, 57, 36), restSeconds: 60)
        addSet(exercise: "Box jumps", weight: 0.0, reps: 12, timestamp: date(2025, 10, 30, 20, 0, 0), restSeconds: 60)

        // SESSION 31: 2025-11-01 08:56:40
        // Incline Dumbbell Chest Press: 5 sets
        addWarmUpSet(exercise: "Incline Dumbbell Chest Press", weight: 17.5, reps: 12, timestamp: date(2025, 11, 1, 8, 56, 40), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 1, 8, 58, 4), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 9, timestamp: date(2025, 11, 1, 9, 1, 1), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 1, 9, 5, 4), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 11, 1, 9, 8, 44), restSeconds: 60)
        // Cable chest flys mid: 4 sets
        addSet(exercise: "Cable chest flys mid", weight: 17.5, reps: 12, timestamp: date(2025, 11, 1, 9, 10, 33), restSeconds: 60)
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 10, timestamp: date(2025, 11, 1, 9, 12, 21), restSeconds: 60)
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 10, timestamp: date(2025, 11, 1, 9, 16, 20), restSeconds: 60)
        addSet(exercise: "Cable chest flys mid", weight: 20.0, reps: 11, timestamp: date(2025, 11, 1, 9, 17, 4), isPB: true)
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 15, timestamp: date(2025, 11, 1, 9, 28, 4), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 15, timestamp: date(2025, 11, 1, 9, 30, 26), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 10.0, reps: 13, timestamp: date(2025, 11, 1, 9, 33, 15), restSeconds: 60)
        // EZ bar curl: 2 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 10, timestamp: date(2025, 11, 1, 9, 36, 13), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 10.0, reps: 8, timestamp: date(2025, 11, 1, 9, 38, 4), isPB: true)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 10, timestamp: date(2025, 11, 1, 9, 43, 58), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 8, timestamp: date(2025, 11, 1, 9, 44, 2), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 10, timestamp: date(2025, 11, 1, 9, 45, 53), restSeconds: 60)
        // Bicep rope curls: 1 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 47, 41), restSeconds: 60)
        // Press ups: 2 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2025, 11, 1, 9, 48, 22))
        addSet(exercise: "Press ups", weight: 0.0, reps: 10, timestamp: date(2025, 11, 1, 9, 49, 34), restSeconds: 60)
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 49, 40), restSeconds: 60)
        addDropSet(exercise: "Bicep rope curls", weight: 39.5, reps: 15, timestamp: date(2025, 11, 1, 9, 52, 20), restSeconds: 60)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 10, timestamp: date(2025, 11, 1, 9, 52, 25), restSeconds: 180)

        // SESSION 32: 2025-11-03 17:11:55
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 11, 55), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 14, 11), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 17, 5), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 3, 17, 21, 0), restSeconds: 60)
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 3, 17, 26, 25), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 3, 17, 28, 49), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2025, 11, 3, 17, 31, 17), restSeconds: 60)
        // EZ bar curl: 3 sets
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 17, timestamp: date(2025, 11, 3, 17, 33, 42), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 17, timestamp: date(2025, 11, 3, 17, 36, 10), restSeconds: 60)
        addSet(exercise: "EZ bar curl", weight: 5.0, reps: 14, timestamp: date(2025, 11, 3, 17, 38, 25), restSeconds: 60)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 10, timestamp: date(2025, 11, 3, 17, 41, 19), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 59.5, reps: 8, timestamp: date(2025, 11, 3, 17, 43, 6), restSeconds: 60)
        addDropSet(exercise: "Lat pull down", weight: 59.5, reps: 8, timestamp: date(2025, 11, 3, 17, 45, 54), restSeconds: 60)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 15, timestamp: date(2025, 11, 3, 17, 55, 43), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 15, timestamp: date(2025, 11, 3, 17, 57, 10), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 10.0, reps: 13, timestamp: date(2025, 11, 3, 17, 59, 15), restSeconds: 60)

        // SESSION 33: 2025-11-04 16:46:00
        // Leg press: 4 sets
        addSet(exercise: "Leg press", weight: 120.0, reps: 10, timestamp: date(2025, 11, 4, 16, 46, 0), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 11, timestamp: date(2025, 11, 4, 16, 48, 25), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 12, timestamp: date(2025, 11, 4, 16, 51, 8), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 120.0, reps: 12, timestamp: date(2025, 11, 4, 16, 53, 51), restSeconds: 60)
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 15, timestamp: date(2025, 11, 4, 16, 55, 41), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 11, 4, 16, 57, 7), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2025, 11, 4, 16, 59, 26), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 4, 17, 4, 38), restSeconds: 60)
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 11, 4, 17, 4, 44), restSeconds: 60)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 6, 48), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 8, 54), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 10, timestamp: date(2025, 11, 4, 17, 10, 52), restSeconds: 60)
        // Toes to bar: 2 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 12, timestamp: date(2025, 11, 4, 17, 23, 40), restSeconds: 60)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 12, timestamp: date(2025, 11, 4, 17, 25, 54), restSeconds: 60)

        // SESSION 34: 2025-11-05 17:09:47
        // Shoulder press machine : 3 sets
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 10, timestamp: date(2025, 11, 5, 17, 9, 47), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 13, timestamp: date(2025, 11, 5, 17, 11, 34), restSeconds: 60)
        addSet(exercise: "Shoulder press machine ", weight: 43.0, reps: 8, timestamp: date(2025, 11, 5, 17, 14, 33), restSeconds: 180, isPB: true)
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 11, 5, 17, 17, 56), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 12, timestamp: date(2025, 11, 5, 17, 19, 34), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 5, 17, 21, 48), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 5, 17, 24, 19), restSeconds: 60)
        // Front lateral cable raise: 1 sets
        addSet(exercise: "Front lateral cable raise", weight: 20.0, reps: 15, timestamp: date(2025, 11, 5, 17, 25, 59), restSeconds: 60)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 11, 5, 17, 28, 53), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 5, 17, 30, 43), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 5, 17, 33, 5), restSeconds: 60)
        // Front lateral cable raise: 2 sets
        addSet(exercise: "Front lateral cable raise", weight: 20.0, reps: 15, timestamp: date(2025, 11, 5, 17, 34, 28), restSeconds: 60)
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 15, timestamp: date(2025, 11, 5, 17, 36, 47), restSeconds: 60)
        // Bicep rope curls: 1 sets
        addSet(exercise: "Bicep rope curls", weight: 45.0, reps: 15, timestamp: date(2025, 11, 5, 17, 38, 49), restSeconds: 60)
        // Tricep rope pushdown: 2 sets
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 15, timestamp: date(2025, 11, 5, 17, 40, 24), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 17, timestamp: date(2025, 11, 5, 17, 42, 56), restSeconds: 60)
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 5, 17, 43, 56), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 13, timestamp: date(2025, 11, 5, 17, 46, 30), restSeconds: 60)
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 12, timestamp: date(2025, 11, 5, 17, 50, 13), restSeconds: 60)
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 10, timestamp: date(2025, 11, 5, 17, 51, 55), restSeconds: 60)
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 15, timestamp: date(2025, 11, 5, 17, 54, 47))
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 12, timestamp: date(2025, 11, 5, 17, 55, 44), restSeconds: 60)
        // Seated dumbbell curl (on knee): 1 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 10.0, reps: 14, timestamp: date(2025, 11, 5, 17, 58, 15), restSeconds: 180)
        // Seated tricep dips: 1 sets
        addSet(exercise: "Seated tricep dips", weight: 0.0, reps: 13, timestamp: date(2025, 11, 5, 17, 58, 47), isPB: true)
        // Deadlifts (Trapbar): 5 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 10, timestamp: date(2025, 11, 5, 18, 1, 45), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 65.0, reps: 10, timestamp: date(2025, 11, 5, 18, 3, 35), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 18, 6, 10), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 18, 8, 54), restSeconds: 60)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2025, 11, 5, 19, 32, 36), restSeconds: 180)

        // SESSION 35: 2025-11-06 23:05:16
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 6, 23, 5, 16), restSeconds: 60)

        // SESSION 36: 2025-11-07 16:45:33
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 7, 16, 45, 33), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 7, 16, 48, 7))
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 16, 51, 15), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 16, 53, 54), restSeconds: 60)
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 7, 16, 58, 34), isPB: true)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 7, 17, 1, 14), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 9, timestamp: date(2025, 11, 7, 17, 5, 26), restSeconds: 60)
        // Chest Cable Flys: 3 sets
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 20, timestamp: date(2025, 11, 7, 17, 14, 58), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 17, 38), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 22.5, reps: 13, timestamp: date(2025, 11, 7, 17, 19, 30), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 22, 41), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 11, 7, 17, 27, 24), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 7, 17, 27, 28), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 11, 7, 17, 31, 26), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 12, timestamp: date(2025, 11, 7, 17, 33, 47), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 11, 7, 17, 37, 33), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.0, reps: 8, timestamp: date(2025, 11, 7, 17, 39, 20), restSeconds: 60)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 12, timestamp: date(2025, 11, 7, 17, 43, 0), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 7, 17, 44, 42), restSeconds: 60)
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 8, timestamp: date(2025, 11, 7, 17, 46, 52), restSeconds: 60)

        // SESSION 37: 2025-11-08 16:25:44
        // Back squat: 4 sets
        addSet(exercise: "Back squat", weight: 50.0, reps: 8, timestamp: date(2025, 11, 8, 16, 25, 44), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 8, 16, 27, 23), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 6.0, reps: 11, timestamp: date(2025, 11, 8, 16, 30, 3), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 8, 16, 33, 27), restSeconds: 60)
        // Pull ups: 3 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 38, 8), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 40, 11), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 8, 16, 43, 25), restSeconds: 60)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 7, timestamp: date(2025, 11, 8, 16, 48, 12), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 8, 16, 51, 4), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 8, 16, 52, 48), restSeconds: 60)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 11, 8, 16, 54, 51), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 8, 16, 57, 11), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 8, 16, 59, 52), restSeconds: 60)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 8, 17, 4, 40), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 8, 17, 5, 27), restSeconds: 60)
        addDropSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 8, timestamp: date(2025, 11, 8, 17, 9, 10), restSeconds: 60)

        // SESSION 38: 2025-11-09 15:32:17
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 15, timestamp: date(2025, 11, 9, 15, 32, 17), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2025, 11, 9, 15, 33, 43), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 130.0, reps: 11, timestamp: date(2025, 11, 9, 15, 35, 49), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 150.0, reps: 8, timestamp: date(2025, 11, 9, 15, 37, 42), isPB: true)
        addSet(exercise: "Leg press", weight: 130.0, reps: 13, timestamp: date(2025, 11, 9, 15, 39, 50), restSeconds: 60)
        // Hamstring Curls: 1 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 12, timestamp: date(2025, 11, 9, 15, 41, 20), restSeconds: 60)
        // Romanian deadlift : 4 sets
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 12, timestamp: date(2025, 11, 9, 15, 45, 56), restSeconds: 60)
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 6, timestamp: date(2025, 11, 9, 15, 47, 26), restSeconds: 60)
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 9, timestamp: date(2025, 11, 9, 15, 49, 27))
        addSet(exercise: "Romanian deadlift ", weight: 50.0, reps: 9, timestamp: date(2025, 11, 9, 15, 52, 38), restSeconds: 180)
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 9, 15, 54, 9), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 10, timestamp: date(2025, 11, 9, 15, 55, 52), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 9, timestamp: date(2025, 11, 9, 15, 58, 19), restSeconds: 60)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 8, timestamp: date(2025, 11, 9, 15, 59, 32), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 9, 16, 1, 13), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 11, 9, 16, 3, 38), restSeconds: 60)
        // Single arm back pull machine: 4 sets
        addSet(exercise: "Single arm back pull machine", weight: 15.0, reps: 12, timestamp: date(2025, 11, 9, 16, 6, 42), restSeconds: 60)
        addSet(exercise: "Single arm back pull machine", weight: 15.0, reps: 12, timestamp: date(2025, 11, 9, 16, 8, 38), restSeconds: 60)
        addSet(exercise: "Single arm back pull machine", weight: 20.0, reps: 10, timestamp: date(2025, 11, 9, 16, 11, 21), restSeconds: 60)
        addSet(exercise: "Single arm back pull machine", weight: 20.0, reps: 12, timestamp: date(2025, 11, 9, 16, 14, 21), isPB: true)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 9, 16, 17, 5), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 9, 16, 20, 46), restSeconds: 60)
        addDropSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 11, 9, 16, 20, 54), restSeconds: 60)
        // Toes to bar: 3 sets
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 13, timestamp: date(2025, 11, 9, 16, 32, 42), isPB: true)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 11, 9, 16, 37, 29), restSeconds: 60)
        addSet(exercise: "Toes to bar", weight: 0.0, reps: 11, timestamp: date(2025, 11, 9, 16, 37, 31), restSeconds: 60)

        // SESSION 39: 2025-11-10 17:27:30
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 11, timestamp: date(2025, 11, 10, 17, 27, 30), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 12, timestamp: date(2025, 11, 10, 17, 29, 30), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 17, 31, 45), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 10, 17, 34, 34), restSeconds: 60)
        // Dumbbell chest press: 2 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 10, timestamp: date(2025, 11, 10, 17, 37, 27), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 7, timestamp: date(2025, 11, 10, 17, 39, 27), restSeconds: 60)
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 15.0, reps: 12, timestamp: date(2025, 11, 10, 17, 44, 49), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 10, 17, 46, 52), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 10, 17, 49, 9), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 11, 10, 17, 51, 26), restSeconds: 60)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 12, timestamp: date(2025, 11, 10, 17, 56, 6), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 9, timestamp: date(2025, 11, 10, 17, 57, 47), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 11, 10, 17, 59, 44), restSeconds: 60)
        // Barbell shoulder press: 3 sets
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 12, timestamp: date(2025, 11, 10, 18, 2, 17), restSeconds: 60)
        addSet(exercise: "Barbell shoulder press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 18, 4, 8), isPB: true)
        addSet(exercise: "Barbell shoulder press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 10, 18, 7, 4), restSeconds: 180)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2025, 11, 10, 18, 8, 0), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 7, timestamp: date(2025, 11, 10, 18, 10, 0), restSeconds: 60)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 9, timestamp: date(2025, 11, 10, 18, 11, 44), restSeconds: 180)

        // SESSION 40: 2025-11-18 16:57:25
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 11, 18, 16, 57, 25), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 15, timestamp: date(2025, 11, 18, 17, 0, 13), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 12, timestamp: date(2025, 11, 18, 17, 3, 18), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 18, 17, 6, 35), restSeconds: 60)
        // Dumbbell chest press: 3 sets
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 8, timestamp: date(2025, 11, 18, 17, 9, 54), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 9, timestamp: date(2025, 11, 18, 17, 12, 40), restSeconds: 60)
        addSet(exercise: "Dumbbell chest press", weight: 25.0, reps: 6, timestamp: date(2025, 11, 18, 17, 15, 24), restSeconds: 60)
        // Dumbbell lateral raises: 3 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 24, 57), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 27, 34), restSeconds: 60)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 10, timestamp: date(2025, 11, 18, 17, 30, 15), restSeconds: 180)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 33, 36), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 36, 6), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 8, timestamp: date(2025, 11, 18, 17, 39, 23), restSeconds: 60)
        // Tricep rope pushdown: 4 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 42, 18), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 44, 11), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 46, 30), restSeconds: 60)
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 18, 17, 48, 58), restSeconds: 60)

        // SESSION 41: 2025-11-19 16:26:53
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 19, 16, 26, 53), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 11, 19, 16, 28, 36), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 19, 16, 32, 51), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 19, 16, 38, 36), restSeconds: 60)
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 12, timestamp: date(2025, 11, 19, 16, 42, 22))
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2025, 11, 19, 16, 45, 10), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 9, timestamp: date(2025, 11, 19, 16, 48, 14), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 19, 16, 51, 2), restSeconds: 60)
        // Straight Arm Lat Pulldown: 3 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.5, reps: 12, timestamp: date(2025, 11, 19, 16, 59, 41), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.5, reps: 14, timestamp: date(2025, 11, 19, 17, 2, 26), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.5, reps: 10, timestamp: date(2025, 11, 19, 17, 4, 40), restSeconds: 60)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 19, 17, 6, 8), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 13, timestamp: date(2025, 11, 19, 17, 8, 53), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 19, 17, 12, 23), restSeconds: 60)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 15, timestamp: date(2025, 11, 19, 17, 15, 18))
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2025, 11, 19, 17, 17, 44), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2025, 11, 19, 17, 20, 39), restSeconds: 60)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 13, timestamp: date(2025, 11, 19, 17, 34, 34))
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 19, 17, 36, 22), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 19, 17, 38, 44), restSeconds: 60)

        // SESSION 42: 2025-11-20 16:11:38
        // Back squat: 4 sets
        addSet(exercise: "Back squat", weight: 60.0, reps: 10, timestamp: date(2025, 11, 20, 16, 11, 38), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 60.0, reps: 11, timestamp: date(2025, 11, 20, 16, 17, 26))
        addSet(exercise: "Back squat", weight: 60.0, reps: 11, timestamp: date(2025, 11, 20, 16, 21, 30), restSeconds: 60)
        addSet(exercise: "Back squat", weight: 60.0, reps: 6, timestamp: date(2025, 11, 20, 16, 25, 1), restSeconds: 180)
        // Deadlifts: 3 sets
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 12, timestamp: date(2025, 11, 20, 16, 26, 24), isPB: true)
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 12, timestamp: date(2025, 11, 20, 16, 29, 19), restSeconds: 60)
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 10, timestamp: date(2025, 11, 20, 16, 33, 10), restSeconds: 180)
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 12, timestamp: date(2025, 11, 20, 16, 34, 28), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 8, timestamp: date(2025, 11, 20, 16, 36, 55), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 8, timestamp: date(2025, 11, 20, 16, 39, 16), restSeconds: 60)
        addDropSet(exercise: "Hamstring Curls", weight: 43.0, reps: 8, timestamp: date(2025, 11, 20, 16, 41, 53), restSeconds: 60)
        // Leg Raises: 2 sets
        addSet(exercise: "Leg Raises", weight: 65.0, reps: 8, timestamp: date(2025, 11, 20, 16, 43, 47), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 65.0, reps: 9, timestamp: date(2025, 11, 20, 16, 45, 45), isPB: true)
        // Dumbbell lunges: 3 sets
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 8, timestamp: date(2025, 11, 20, 16, 59, 18), restSeconds: 60)
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 6, timestamp: date(2025, 11, 20, 17, 1, 44), restSeconds: 60)
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 7, timestamp: date(2025, 11, 20, 17, 5, 0), restSeconds: 60)

        // SESSION 43: 2025-11-21 23:50:50
        // Dumbbell lunges: 2 sets
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 7, timestamp: date(2025, 11, 21, 23, 50, 50), restSeconds: 60)
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 9, timestamp: date(2025, 11, 21, 23, 51, 8), restSeconds: 180)

        // SESSION 44: 2025-11-22 15:30:25
        // Straight Arm Lat Pulldown: 2 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 50.5, reps: 10, timestamp: date(2025, 11, 22, 15, 30, 25), restSeconds: 60)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 60.0, reps: 10, timestamp: date(2025, 11, 22, 15, 30, 32), restSeconds: 180, isPauseAtTop: true, isTimedSet: true, tempoSeconds: 0, isPB: true)

        // SESSION 45: 2025-11-23 15:38:02
        // Chest Press: 3 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 11, 23, 15, 38, 2), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 11, 23, 15, 40, 42), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 11, 23, 15, 43, 21), restSeconds: 60)
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 11, timestamp: date(2025, 11, 23, 15, 45, 27), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 9, timestamp: date(2025, 11, 23, 15, 48, 11), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 10, timestamp: date(2025, 11, 23, 15, 51, 2), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 45.0, reps: 8, timestamp: date(2025, 11, 23, 15, 55, 13), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 10, timestamp: date(2025, 11, 23, 15, 58, 6), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 9, timestamp: date(2025, 11, 23, 16, 2, 5), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 9, timestamp: date(2025, 11, 23, 16, 4, 28), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 8, timestamp: date(2025, 11, 23, 16, 9, 52), restSeconds: 60)
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 12, timestamp: date(2025, 11, 23, 16, 11, 6))
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 8, timestamp: date(2025, 11, 23, 16, 13, 10), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 11, timestamp: date(2025, 11, 23, 16, 16, 9), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 11, timestamp: date(2025, 11, 23, 16, 19, 31), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 11, 23, 16, 21, 43), restSeconds: 60)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 11, timestamp: date(2025, 11, 23, 16, 31, 49), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 9, timestamp: date(2025, 11, 23, 16, 33, 20), restSeconds: 60)
        addDropSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 12, timestamp: date(2025, 11, 23, 16, 35, 35), restSeconds: 60)

        // SESSION 46: 2025-11-24 17:27:36
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 24, 17, 27, 36), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2025, 11, 24, 17, 31, 44), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 11, 24, 17, 33, 19), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 11, 24, 17, 35, 36), restSeconds: 60)
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2025, 11, 24, 17, 38, 21), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 24, 17, 41, 0), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 24, 17, 43, 13), restSeconds: 60)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 11, 24, 17, 45, 0), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2025, 11, 24, 17, 46, 55), restSeconds: 60)
        addDropSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 9, timestamp: date(2025, 11, 24, 17, 49, 37), restSeconds: 60)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 16, timestamp: date(2025, 11, 24, 17, 51, 10))
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 14, timestamp: date(2025, 11, 24, 17, 53, 10), restSeconds: 60)
        addDropSet(exercise: "Bicep rope curls", weight: 50.5, reps: 12, timestamp: date(2025, 11, 24, 17, 55, 57), restSeconds: 60)
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2025, 11, 24, 18, 2, 53), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2025, 11, 24, 18, 5, 10), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 14, timestamp: date(2025, 11, 24, 18, 8, 43), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 9, timestamp: date(2025, 11, 24, 18, 12, 9), restSeconds: 60)
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 13, timestamp: date(2025, 11, 24, 18, 13, 53), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 12, timestamp: date(2025, 11, 24, 18, 15, 39), restSeconds: 60)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 9, timestamp: date(2025, 11, 24, 18, 19, 20), restSeconds: 180)

        // SESSION 47: 2025-11-25 16:43:47
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 15, timestamp: date(2025, 11, 25, 16, 43, 47), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 100.0, reps: 12, timestamp: date(2025, 11, 25, 16, 45, 34), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2025, 11, 25, 16, 49, 31), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 130.0, reps: 13, timestamp: date(2025, 11, 25, 16, 52, 41), restSeconds: 60)
        addSet(exercise: "Leg press", weight: 140.0, reps: 11, timestamp: date(2025, 11, 25, 16, 56, 41), restSeconds: 180)
        // Hamstring Curls: 5 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 32.0, reps: 17, timestamp: date(2025, 11, 25, 17, 0, 41), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 43.0, reps: 15, timestamp: date(2025, 11, 25, 17, 1, 45), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 12, timestamp: date(2025, 11, 25, 17, 4, 14))
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 11, timestamp: date(2025, 11, 25, 17, 7, 13), restSeconds: 60)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 7, timestamp: date(2025, 11, 25, 17, 8, 57), restSeconds: 180)
        // Dumbbell Romanian deadlift: 3 sets
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 12, 34), restSeconds: 60)
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 14, 0), restSeconds: 60)
        addSet(exercise: "Dumbbell Romanian deadlift", weight: 12.5, reps: 12, timestamp: date(2025, 11, 25, 17, 15, 30), isPB: true)
        // Dumbbell split squats: 3 sets
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 18, 21), isPB: true)
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 20, 28), restSeconds: 60)
        addSet(exercise: "Dumbbell split squats", weight: 12.5, reps: 10, timestamp: date(2025, 11, 25, 17, 23, 28), restSeconds: 60)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 25, 17, 32, 47), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2025, 11, 25, 17, 34, 37), restSeconds: 60)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 11, timestamp: date(2025, 11, 25, 17, 36, 49), restSeconds: 180)
        // Box jumps: 3 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 40, 26), restSeconds: 60)
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 43, 19))
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2025, 11, 25, 17, 47, 13), restSeconds: 180)
        // T Bar Row: 2 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 25, 20, 32, 23), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 25, 20, 32, 32), restSeconds: 60)

        // SESSION 48: 2025-11-27 15:40:29
        // T Bar Row: 2 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 27, 15, 40, 29), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 11, 27, 17, 28, 47), restSeconds: 60)

        // SESSION 49: 2025-11-28 15:55:41
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 14, timestamp: date(2025, 11, 28, 15, 55, 41), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 13, timestamp: date(2025, 11, 28, 15, 57, 55), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 11, timestamp: date(2025, 11, 28, 16, 0, 35), restSeconds: 60)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 23.0, reps: 10, timestamp: date(2025, 11, 28, 16, 4, 24), isPB: true)
        addSet(exercise: "Single cable lateral raise", weight: 23.0, reps: 10, timestamp: date(2025, 11, 28, 16, 5, 29), restSeconds: 60)
        addDropSet(exercise: "Single cable lateral raise", weight: 23.0, reps: 10, timestamp: date(2025, 11, 28, 16, 9, 40), restSeconds: 60)
        // Front lateral cable raise: 3 sets
        addSet(exercise: "Front lateral cable raise", weight: 17.5, reps: 15, timestamp: date(2025, 11, 28, 16, 10, 57), restSeconds: 60)
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 16, timestamp: date(2025, 11, 28, 16, 13, 19), isPB: true)
        addSet(exercise: "Front lateral cable raise", weight: 23.0, reps: 14, timestamp: date(2025, 11, 28, 16, 15, 36), restSeconds: 60)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 16, timestamp: date(2025, 11, 28, 16, 17, 17), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2025, 11, 28, 16, 20, 32), restSeconds: 60)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 13, timestamp: date(2025, 11, 28, 16, 22, 19), restSeconds: 180)
        // Tricep rope pushdown: 3 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 13, timestamp: date(2025, 11, 28, 16, 25, 10), isPB: true)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 11, timestamp: date(2025, 11, 28, 16, 27, 24), restSeconds: 60)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2025, 11, 28, 16, 29, 44), restSeconds: 180)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 10, timestamp: date(2025, 11, 28, 16, 31, 56), isPB: true)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 10, timestamp: date(2025, 11, 28, 16, 34, 59), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 7, timestamp: date(2025, 11, 28, 16, 37, 36), restSeconds: 60)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2025, 11, 28, 16, 42, 4), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2025, 11, 28, 16, 42, 10), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 10, timestamp: date(2025, 11, 28, 16, 44, 29), restSeconds: 60)
        // Tricep ez bar: 3 sets
        addSet(exercise: "Tricep ez bar", weight: 10.0, reps: 12, timestamp: date(2025, 11, 28, 16, 50, 50), restSeconds: 60)
        addSet(exercise: "Tricep ez bar", weight: 10.0, reps: 12, timestamp: date(2025, 11, 28, 16, 51, 40), restSeconds: 60)
        addSet(exercise: "Tricep ez bar", weight: 10.0, reps: 15, timestamp: date(2025, 11, 28, 16, 54, 15), isPB: true)

        // SESSION 50: 2025-11-29 17:18:27
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 11, 29, 17, 18, 27), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 10, timestamp: date(2025, 11, 29, 17, 20, 33), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 11, 29, 17, 23, 18), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 9, timestamp: date(2025, 11, 29, 17, 26, 20), restSeconds: 60)
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 6, timestamp: date(2025, 11, 29, 17, 29, 28), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 11, 29, 17, 31, 25), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 8, timestamp: date(2025, 11, 29, 17, 33, 35), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 7, timestamp: date(2025, 11, 29, 17, 35, 50), restSeconds: 60)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 12, timestamp: date(2025, 11, 29, 17, 38, 4), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 15, timestamp: date(2025, 11, 29, 17, 40, 40), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 13, timestamp: date(2025, 11, 29, 17, 43, 0), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 12, timestamp: date(2025, 11, 29, 17, 44, 57), restSeconds: 60)

        // SESSION 51: 2025-12-01 16:26:26
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 12, 1, 16, 26, 26), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 9, timestamp: date(2025, 12, 1, 16, 28, 16))
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2025, 12, 1, 16, 30, 11), restSeconds: 60)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2025, 12, 1, 16, 33, 4), restSeconds: 180)
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 12, 1, 16, 36, 20), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2025, 12, 1, 16, 42, 55), restSeconds: 60)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2025, 12, 1, 16, 43, 39), restSeconds: 180)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 12, 1, 16, 48, 54))
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 12, 1, 16, 51, 15), restSeconds: 60)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 12, 1, 16, 54, 40), restSeconds: 180)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 10, timestamp: date(2025, 12, 1, 16, 57, 24), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 9, timestamp: date(2025, 12, 1, 17, 0, 3), restSeconds: 60)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 12.5, reps: 9, timestamp: date(2025, 12, 1, 17, 2, 34), restSeconds: 180)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2025, 12, 1, 17, 5, 7), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 10, timestamp: date(2025, 12, 1, 17, 9, 1), restSeconds: 60)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 10, timestamp: date(2025, 12, 1, 17, 9, 47), restSeconds: 180)

        // SESSION 52: 2025-12-03 16:40:37
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 30.0, reps: 12, timestamp: date(2025, 12, 3, 16, 40, 37), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 11, timestamp: date(2025, 12, 3, 16, 47, 10), restSeconds: 60)
        addSet(exercise: "Incline chest press machine", weight: 45.0, reps: 10, timestamp: date(2025, 12, 3, 16, 50, 11), isPB: true)
        addSet(exercise: "Incline chest press machine", weight: 45.0, reps: 10, timestamp: date(2025, 12, 3, 16, 52, 32), restSeconds: 180)
        // Chest Press: 3 sets
        addWarmUpSet(exercise: "Chest Press", weight: 40.0, reps: 10, timestamp: date(2025, 12, 3, 16, 54, 20), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 12, 3, 16, 57, 29), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 6, timestamp: date(2025, 12, 3, 16, 59, 25), restSeconds: 60)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 10, timestamp: date(2025, 12, 3, 17, 6, 4), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 10, timestamp: date(2025, 12, 3, 17, 8, 20), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 11, timestamp: date(2025, 12, 3, 17, 12, 0), restSeconds: 60)
        // Single cable lateral raise: 4 sets
        addWarmUpSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 10, timestamp: date(2025, 12, 3, 17, 15, 54), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 10, timestamp: date(2025, 12, 3, 17, 18, 24), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 12, 3, 17, 21, 1), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2025, 12, 3, 17, 24, 4), restSeconds: 60)
        // Chest Cable Flys: 4 sets
        addWarmUpSet(exercise: "Chest Cable Flys", weight: 15.0, reps: 15, timestamp: date(2025, 12, 3, 17, 35, 17), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 15, timestamp: date(2025, 12, 3, 17, 37, 18), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 14, timestamp: date(2025, 12, 3, 17, 40, 21), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2025, 12, 3, 17, 42, 45), restSeconds: 60)
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 12, timestamp: date(2025, 12, 3, 17, 45, 0), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 16, timestamp: date(2025, 12, 3, 17, 47, 31), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 36.5, reps: 15, timestamp: date(2025, 12, 3, 17, 50, 25), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 36.5, reps: 12, timestamp: date(2025, 12, 3, 17, 52, 31), restSeconds: 60)

        // SESSION 53: 2025-12-10 20:36:36
        // Tricep Dips (bar): 3 sets
        addWarmUpSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 11, timestamp: date(2025, 12, 10, 20, 36, 36), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 11, timestamp: date(2025, 12, 10, 20, 36, 59), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 15, timestamp: date(2025, 12, 10, 20, 37, 32), restSeconds: 60)

        // SESSION 54: 2025-12-12 15:09:12
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 7.5, reps: 15, timestamp: date(2025, 12, 12, 15, 9, 12), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 6, timestamp: date(2025, 12, 12, 15, 9, 55))
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 6, timestamp: date(2025, 12, 12, 16, 9, 12), restSeconds: 60)

        // SESSION 55: 2025-12-29 16:19:55
        // Chest Press: 5 sets
        addWarmUpSet(exercise: "Chest Press", weight: 20.0, reps: 12, timestamp: date(2025, 12, 29, 16, 19, 55), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2025, 12, 29, 16, 21, 4), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 55.0, reps: 8, timestamp: date(2025, 12, 29, 16, 24, 45), restSeconds: 60)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 5, timestamp: date(2025, 12, 29, 16, 28, 33))
        addSet(exercise: "Chest Press", weight: 60.0, reps: 5, timestamp: date(2025, 12, 29, 16, 32, 30), restSeconds: 180)
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 12, 29, 16, 36, 7), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 12, 29, 16, 38, 56), restSeconds: 60)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2025, 12, 29, 16, 42, 11), restSeconds: 180)
        // Chest Cable Flys: 2 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 12, timestamp: date(2025, 12, 29, 16, 45, 5), restSeconds: 60)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2025, 12, 29, 16, 49, 11), restSeconds: 180)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 15, timestamp: date(2025, 12, 29, 16, 52, 49), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 15, timestamp: date(2025, 12, 29, 16, 55, 13), restSeconds: 60)
        addSet(exercise: "Single cable lateral raise", weight: 17.5, reps: 15, timestamp: date(2025, 12, 29, 16, 59, 0), restSeconds: 180)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 10, timestamp: date(2025, 12, 29, 17, 1, 2), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 5.0, reps: 10, timestamp: date(2025, 12, 29, 17, 3, 1), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 10, timestamp: date(2025, 12, 29, 17, 5, 42), restSeconds: 60)
        addSet(exercise: "Tricep Dips (bar)", weight: 0.0, reps: 10, timestamp: date(2025, 12, 29, 17, 7, 49), restSeconds: 180)
        // Overhead Tricep Rope Pulls: 4 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 34.0, reps: 15, timestamp: date(2025, 12, 29, 17, 11, 21), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 36.5, reps: 12, timestamp: date(2025, 12, 29, 17, 13, 17), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 36.5, reps: 12, timestamp: date(2025, 12, 29, 17, 15, 48), restSeconds: 60)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 36.5, reps: 9, timestamp: date(2025, 12, 29, 17, 17, 33), restSeconds: 180)

        // SESSION 56: 2026-01-04 14:51:40
        // Lat pull down: 4 sets
        addWarmUpSet(exercise: "Lat pull down", weight: 47.5, reps: 10, timestamp: date(2026, 1, 4, 14, 51, 40), restSeconds: 56)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 8, timestamp: date(2026, 1, 4, 14, 52, 36), restSeconds: 136)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 10, timestamp: date(2026, 1, 4, 14, 54, 53), restSeconds: 162)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 9, timestamp: date(2026, 1, 4, 14, 57, 36), restSeconds: 180)
        // T Bar Row: 5 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 12, timestamp: date(2026, 1, 4, 14, 58, 24), restSeconds: 176)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 8, timestamp: date(2026, 1, 4, 15, 1, 21), restSeconds: 174)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 8, timestamp: date(2026, 1, 4, 15, 4, 15), restSeconds: 166)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 6, timestamp: date(2026, 1, 4, 15, 7, 1), restSeconds: 172)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2026, 1, 4, 15, 9, 53), restSeconds: 180)
        // Seated Incline dumbbell Curls: 3 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2026, 1, 4, 15, 11, 54), restSeconds: 180)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2026, 1, 4, 15, 15, 21), restSeconds: 180)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2026, 1, 4, 15, 19, 3), restSeconds: 180)
        // Reverse dumbbell lateral flys: 3 sets
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 12.5, reps: 15, timestamp: date(2026, 1, 4, 15, 19, 21), restSeconds: 180, isPB: true)
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 12.5, reps: 12, timestamp: date(2026, 1, 4, 15, 23, 57), restSeconds: 180)
        addSet(exercise: "Reverse dumbbell lateral flys", weight: 12.5, reps: 12, timestamp: date(2026, 1, 4, 15, 27, 8))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2026, 1, 4, 15, 29, 5), restSeconds: 143)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2026, 1, 4, 15, 31, 29), restSeconds: 171)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 13, timestamp: date(2026, 1, 4, 15, 34, 21), restSeconds: 180)
        // Neutral grip pull ups: 2 sets
        addSet(exercise: "Neutral grip pull ups", weight: 0.0, reps: 3, timestamp: date(2026, 1, 4, 15, 41, 42), restSeconds: 76)
        addSet(exercise: "Neutral grip pull ups", weight: 0.0, reps: 4, timestamp: date(2026, 1, 4, 15, 42, 59), restSeconds: 180)

        // SESSION 57: 2026-01-06 16:14:19
        // Leg Raises: 1 sets
        addWarmUpSet(exercise: "Leg Raises", weight: 43.0, reps: 10, timestamp: date(2026, 1, 6, 16, 14, 19), restSeconds: 180)
        // Leg press: 5 sets
        addWarmUpSet(exercise: "Leg press", weight: 50.0, reps: 12, timestamp: date(2026, 1, 6, 16, 15, 52), restSeconds: 155)
        addSet(exercise: "Leg press", weight: 100.0, reps: 10, timestamp: date(2026, 1, 6, 16, 18, 27), restSeconds: 126)
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2026, 1, 6, 16, 20, 34), restSeconds: 180)
        addSet(exercise: "Leg press", weight: 130.0, reps: 10, timestamp: date(2026, 1, 6, 16, 23, 49), restSeconds: 180)
        addSet(exercise: "Leg press", weight: 130.0, reps: 12, timestamp: date(2026, 1, 6, 16, 28, 48))
        // Romanian deadlift : 3 sets
        addSet(exercise: "Romanian deadlift ", weight: 40.0, reps: 10, timestamp: date(2026, 1, 6, 16, 40, 22), restSeconds: 136)
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 10, timestamp: date(2026, 1, 6, 16, 42, 39), restSeconds: 148, isPB: true)
        addSet(exercise: "Romanian deadlift ", weight: 60.0, reps: 7, timestamp: date(2026, 1, 6, 16, 45, 7))
        // Back squat: 3 sets
        addSet(exercise: "Back squat", weight: 60.0, reps: 5, timestamp: date(2026, 1, 6, 16, 51, 44), restSeconds: 180)
        addSet(exercise: "Back squat", weight: 60.0, reps: 8, timestamp: date(2026, 1, 6, 16, 56, 54), restSeconds: 180)
        addSet(exercise: "Back squat", weight: 60.0, reps: 8, timestamp: date(2026, 1, 6, 17, 0, 17), restSeconds: 180)
        // Hang cleans: 3 sets
        addSet(exercise: "Hang cleans", weight: 20.0, reps: 10, timestamp: date(2026, 1, 6, 17, 6, 44), restSeconds: 92)
        addSet(exercise: "Hang cleans", weight: 30.0, reps: 6, timestamp: date(2026, 1, 6, 17, 8, 17), restSeconds: 138, isPB: true)
        addSet(exercise: "Hang cleans", weight: 30.0, reps: 6, timestamp: date(2026, 1, 6, 17, 10, 35))
        // Front barbell squat: 1 sets
        addSet(exercise: "Front barbell squat", weight: 30.0, reps: 4, timestamp: date(2026, 1, 6, 17, 12, 38), isPB: true)
        // Hamstring Curls: 3 sets
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 10, timestamp: date(2026, 1, 6, 17, 18, 19), restSeconds: 120)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 10, timestamp: date(2026, 1, 6, 17, 20, 20), restSeconds: 175)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 10, timestamp: date(2026, 1, 6, 17, 23, 16), restSeconds: 180)

        // SESSION 58: 2026-01-07 16:33:36
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 8, timestamp: date(2026, 1, 7, 16, 33, 36), restSeconds: 180)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 1, 7, 16, 37, 56), restSeconds: 163)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 6, timestamp: date(2026, 1, 7, 16, 40, 39), restSeconds: 180)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 1, 7, 16, 45, 53), restSeconds: 180)
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 10, timestamp: date(2026, 1, 7, 16, 50, 46), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 1, 7, 16, 54, 43), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 1, 7, 16, 58, 37), restSeconds: 180)
        // Dumbbell flys: 3 sets
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 15, timestamp: date(2026, 1, 7, 17, 1, 25), restSeconds: 147)
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 15, timestamp: date(2026, 1, 7, 17, 3, 53), restSeconds: 180)
        addSet(exercise: "Dumbbell flys", weight: 12.5, reps: 17, timestamp: date(2026, 1, 7, 17, 7, 34), isPB: true)
        // Dumbbell lateral raises: 2 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 13, timestamp: date(2026, 1, 7, 17, 9, 35), restSeconds: 180, isPB: true)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 13, timestamp: date(2026, 1, 7, 17, 13, 0), restSeconds: 180)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 9, timestamp: date(2026, 1, 7, 17, 19, 59), restSeconds: 146)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 9, timestamp: date(2026, 1, 7, 17, 22, 26), restSeconds: 163)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 8, timestamp: date(2026, 1, 7, 17, 25, 9), restSeconds: 180)
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 13, timestamp: date(2026, 1, 7, 17, 28, 25), restSeconds: 156)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 13, timestamp: date(2026, 1, 7, 17, 31, 2), restSeconds: 180)
        addDropSet(exercise: "Overhead Tricep Rope Pulls", weight: 39.5, reps: 13, timestamp: date(2026, 1, 7, 17, 35, 27), restSeconds: 180)
        // Lu Raise: 1 sets
        addSet(exercise: "Lu Raise", weight: 5.0, reps: 10, timestamp: date(2026, 1, 7, 17, 38, 19), restSeconds: 141)
        // Front lateral raise plates: 1 sets
        addSet(exercise: "Front lateral raise plates", weight: 10.0, reps: 10, timestamp: date(2026, 1, 7, 17, 39, 1), restSeconds: 105, isPB: true)
        // Lu Raise: 1 sets
        addSet(exercise: "Lu Raise", weight: 5.0, reps: 10, timestamp: date(2026, 1, 7, 17, 40, 40), restSeconds: 180)
        // Front lateral raise plates: 1 sets
        addSet(exercise: "Front lateral raise plates", weight: 10.0, reps: 10, timestamp: date(2026, 1, 7, 17, 40, 46))

        // SESSION 59: 2026-01-09 08:28:09
        // Tricep Dips (bar): 1 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 8, timestamp: date(2026, 1, 9, 8, 28, 9), restSeconds: 180)

        // SESSION 60: 2026-01-09 15:32:11
        // Pull ups: 4 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 9, 15, 32, 11), restSeconds: 117)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2026, 1, 9, 15, 34, 8), restSeconds: 129)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 1, 9, 15, 36, 18), restSeconds: 149)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 9, 15, 38, 48), restSeconds: 180)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 14, timestamp: date(2026, 1, 9, 15, 41, 22), restSeconds: 156)
        // Neutral grip pull ups: 1 sets
        addSet(exercise: "Neutral grip pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 1, 9, 15, 42, 20), restSeconds: 180)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 12, timestamp: date(2026, 1, 9, 15, 43, 58), restSeconds: 180)
        // Neutral grip pull ups: 1 sets
        addSet(exercise: "Neutral grip pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 9, 15, 46, 2), restSeconds: 153, isPB: true)
        // Reverse Cable Flys: 1 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 10, timestamp: date(2026, 1, 9, 15, 47, 28), restSeconds: 180)
        // Neutral grip pull ups: 1 sets
        addSet(exercise: "Neutral grip pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 9, 15, 48, 36))
        // Seated cable row: 3 sets
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 8, timestamp: date(2026, 1, 9, 15, 50, 42), restSeconds: 118)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 8, timestamp: date(2026, 1, 9, 15, 52, 40), restSeconds: 175)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 10, timestamp: date(2026, 1, 9, 15, 55, 36), restSeconds: 180)
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 10, timestamp: date(2026, 1, 9, 16, 0, 24), restSeconds: 167, isPB: true)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 8, timestamp: date(2026, 1, 9, 16, 3, 11), restSeconds: 148)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 6, timestamp: date(2026, 1, 9, 16, 5, 40), restSeconds: 180)
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2026, 1, 9, 16, 7, 33), restSeconds: 180)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2026, 1, 9, 16, 10, 46), restSeconds: 180)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2026, 1, 9, 16, 14, 3), restSeconds: 180)

        // SESSION 61: 2026-01-13 21:26:26
        // Dumbbell hammer curls : 1 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2026, 1, 13, 21, 26, 26), restSeconds: 180)

        // SESSION 62: 2026-01-14 16:16:26
        // Deadlifts (Trapbar): 4 sets
        addSet(exercise: "Deadlifts (Trapbar)", weight: 60.0, reps: 12, timestamp: date(2026, 1, 14, 16, 16, 26), restSeconds: 180)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 12, timestamp: date(2026, 1, 14, 16, 19, 41), restSeconds: 166)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 10, timestamp: date(2026, 1, 14, 16, 22, 28), restSeconds: 180)
        addSet(exercise: "Deadlifts (Trapbar)", weight: 70.0, reps: 8, timestamp: date(2026, 1, 14, 16, 25, 47))
        // Pull ups: 3 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 14, 16, 29, 18), restSeconds: 148)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 14, 16, 31, 47), restSeconds: 125)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 1, 14, 16, 33, 52), restSeconds: 180)
        // T Bar Row: 4 sets
        addWarmUpSet(exercise: "T Bar Row", weight: 20.0, reps: 6, timestamp: date(2026, 1, 14, 16, 36, 31), restSeconds: 91)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 8, timestamp: date(2026, 1, 14, 16, 38, 3), restSeconds: 180)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2026, 1, 14, 16, 41, 13), restSeconds: 173)
        addSet(exercise: "T Bar Row", weight: 40.0, reps: 8, timestamp: date(2026, 1, 14, 16, 44, 6), restSeconds: 180)
        // Reverse Cable Flys: 4 sets
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 13, timestamp: date(2026, 1, 14, 16, 47, 27), restSeconds: 180)
        addSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 15, timestamp: date(2026, 1, 14, 16, 52, 12), restSeconds: 180)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 1, 14, 16, 56, 5), restSeconds: 180)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 11, timestamp: date(2026, 1, 14, 16, 59, 32), restSeconds: 180)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 14, timestamp: date(2026, 1, 14, 17, 2, 16), restSeconds: 122)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 14, timestamp: date(2026, 1, 14, 17, 4, 18), restSeconds: 150)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 13, timestamp: date(2026, 1, 14, 17, 6, 49), restSeconds: 180)
        // Single arm bicep cable curl: 2 sets
        addSet(exercise: "Single arm bicep cable curl", weight: 17.5, reps: 12, timestamp: date(2026, 1, 14, 17, 9, 17), restSeconds: 172, isPB: true)
        addSet(exercise: "Single arm bicep cable curl", weight: 17.5, reps: 12, timestamp: date(2026, 1, 14, 17, 12, 10))
        // Knees to toe: 3 sets
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 14, timestamp: date(2026, 1, 14, 17, 13, 46), restSeconds: 180, isPB: true)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 10, timestamp: date(2026, 1, 14, 17, 19, 21), restSeconds: 4)
        addSet(exercise: "Knees to toe", weight: 0.0, reps: 8, timestamp: date(2026, 1, 14, 17, 19, 25))

        // SESSION 63: 2026-01-25 16:09:36
        // Pull ups: 6 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 9, 36), restSeconds: 98)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 11, 15), restSeconds: 102)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 12, 57), restSeconds: 97)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 14, 34), restSeconds: 108)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 16, 22), restSeconds: 97)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 1, 25, 16, 18, 0), restSeconds: 180)
        // Seated cable row: 3 sets
        addSet(exercise: "Seated cable row", weight: 54.0, reps: 12, timestamp: date(2026, 1, 25, 16, 20, 21), restSeconds: 100)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 11, timestamp: date(2026, 1, 25, 16, 22, 1), restSeconds: 96)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 10, timestamp: date(2026, 1, 25, 16, 23, 37), restSeconds: 180)
        // Plate loaded lat pulldown: 3 sets
        addSet(exercise: "Plate loaded lat pulldown", weight: 40.0, reps: 10, timestamp: date(2026, 1, 25, 16, 30, 10), restSeconds: 110)
        addSet(exercise: "Plate loaded lat pulldown", weight: 40.0, reps: 15, timestamp: date(2026, 1, 25, 16, 32, 1), restSeconds: 114, isPB: true)
        addSet(exercise: "Plate loaded lat pulldown", weight: 40.0, reps: 12, timestamp: date(2026, 1, 25, 16, 33, 55))
        // Reverse Cable Flys: 3 sets
        addWarmUpSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 10, timestamp: date(2026, 1, 25, 16, 36, 17), restSeconds: 130)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 1, 25, 16, 38, 28), restSeconds: 165)
        addDropSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 11, timestamp: date(2026, 1, 25, 16, 41, 13), restSeconds: 180)
        // Seated Incline dumbbell Curls: 4 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 13, timestamp: date(2026, 1, 25, 16, 43, 5), restSeconds: 180)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2026, 1, 25, 16, 46, 28), restSeconds: 133)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2026, 1, 25, 16, 48, 41), restSeconds: 180)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2026, 1, 25, 16, 54, 2), restSeconds: 180)
        // Barbell shoulder press: 4 sets
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 12, timestamp: date(2026, 1, 25, 16, 54, 14), restSeconds: 120)
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 9, timestamp: date(2026, 1, 25, 16, 56, 15), restSeconds: 151)
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 10, timestamp: date(2026, 1, 25, 16, 58, 47), restSeconds: 180)
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 10, timestamp: date(2026, 1, 25, 17, 5, 9), restSeconds: 180)

        // SESSION 64: 2026-01-26 23:45:50
        // Press ups: 4 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 26, 23, 45, 50), restSeconds: 17)
        addSet(exercise: "Press ups", weight: 0.0, reps: 16, timestamp: date(2026, 1, 26, 23, 46, 7), restSeconds: 6)
        addSet(exercise: "Press ups", weight: 0.0, reps: 8, timestamp: date(2026, 1, 26, 23, 46, 13), restSeconds: 10)
        addSet(exercise: "Press ups", weight: 0.0, reps: 8, timestamp: date(2026, 1, 26, 23, 46, 23), restSeconds: 180)

        // SESSION 65: 2026-01-27 16:45:46
        // Incline Dumbbell Chest Press: 5 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 10, timestamp: date(2026, 1, 27, 16, 45, 46), restSeconds: 123)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 22.5, reps: 14, timestamp: date(2026, 1, 27, 16, 47, 49), restSeconds: 171)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 1, 27, 16, 50, 40), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 1, 27, 16, 53, 46), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 1, 27, 16, 59, 54), restSeconds: 180)
        // Dumbbell lateral raises: 4 sets
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2026, 1, 27, 17, 20, 18), restSeconds: 3)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2026, 1, 27, 17, 20, 22), restSeconds: 131)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2026, 1, 27, 17, 22, 34), restSeconds: 180)
        addSet(exercise: "Dumbbell lateral raises", weight: 12.5, reps: 12, timestamp: date(2026, 1, 27, 17, 26, 28))
        // Ball tricep pushdown: 3 sets
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 12, timestamp: date(2026, 1, 27, 17, 28, 49), restSeconds: 153)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 12, timestamp: date(2026, 1, 27, 17, 31, 23), restSeconds: 137)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 12, timestamp: date(2026, 1, 27, 17, 33, 41), restSeconds: 180)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 10, timestamp: date(2026, 1, 27, 17, 37, 28), restSeconds: 110)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 8, timestamp: date(2026, 1, 27, 17, 39, 18), restSeconds: 162)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 8, timestamp: date(2026, 1, 27, 17, 42, 1), restSeconds: 180)

        // SESSION 66: 2026-01-29 16:22:49
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 29, 16, 22, 49), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 29, 16, 24, 10), restSeconds: 155)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2026, 1, 29, 16, 26, 2), restSeconds: 174)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 29, 16, 26, 45), restSeconds: 174)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 29, 16, 28, 56), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 12, timestamp: date(2026, 1, 29, 16, 29, 39), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 29, 16, 32, 39), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 11, timestamp: date(2026, 1, 29, 16, 33, 18), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 1, 29, 16, 36, 41), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 17, timestamp: date(2026, 1, 29, 16, 38, 46), restSeconds: 180)
        // Angled rope row: 1 sets
        addSet(exercise: "Angled rope row", weight: 0.0, reps: 9, timestamp: date(2026, 1, 29, 16, 40, 44), restSeconds: 155)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 1, 29, 16, 42, 6), restSeconds: 174)
        // Angled rope row: 1 sets
        addSet(exercise: "Angled rope row", weight: 0.0, reps: 11, timestamp: date(2026, 1, 29, 16, 43, 19), restSeconds: 180, isPB: true)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 11, timestamp: date(2026, 1, 29, 16, 45, 0), restSeconds: 180)
        // Angled rope row: 1 sets
        addSet(exercise: "Angled rope row", weight: 0.0, reps: 10, timestamp: date(2026, 1, 29, 16, 46, 28))
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 12, timestamp: date(2026, 1, 29, 16, 48, 18), restSeconds: 130)
        // Barbell shoulder press: 1 sets
        addSet(exercise: "Barbell shoulder press", weight: 20.0, reps: 10, timestamp: date(2026, 1, 29, 16, 48, 44))
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 10, timestamp: date(2026, 1, 29, 16, 50, 29), restSeconds: 180)
        // Lat pull down: 3 sets
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 11, timestamp: date(2026, 1, 29, 16, 55, 18), restSeconds: 126)
        addSet(exercise: "Lat pull down", weight: 65.0, reps: 11, timestamp: date(2026, 1, 29, 16, 57, 25), restSeconds: 180)
        addSet(exercise: "Lat pull down", weight: 70.5, reps: 12, timestamp: date(2026, 1, 29, 17, 4, 5), restSeconds: 180, isPB: true)
        // Bicep rope curls: 1 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 16, timestamp: date(2026, 1, 29, 17, 6, 10), restSeconds: 180)
        // Reverse Cable Flys: 3 sets
        addWarmUpSet(exercise: "Reverse Cable Flys", weight: 17.5, reps: 11, timestamp: date(2026, 1, 29, 17, 8, 0), restSeconds: 180)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 1, 29, 17, 11, 3), restSeconds: 157)
        addDropSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 9, timestamp: date(2026, 1, 29, 17, 13, 41), restSeconds: 180)
        // Face pulls: 2 sets
        addSet(exercise: "Face pulls", weight: 39.5, reps: 13, timestamp: date(2026, 1, 29, 17, 16, 49), restSeconds: 71)
        addSet(exercise: "Face pulls", weight: 39.5, reps: 13, timestamp: date(2026, 1, 29, 17, 18, 0), restSeconds: 180)
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 14, timestamp: date(2026, 1, 29, 17, 18, 47), restSeconds: 79)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 10, timestamp: date(2026, 1, 29, 17, 20, 6), restSeconds: 115)
        addDropSet(exercise: "Bicep rope curls", weight: 45.0, reps: 10, timestamp: date(2026, 1, 29, 17, 22, 2), restSeconds: 180)

        // SESSION 67: 2026-01-30 17:17:57
        // Press ups: 9 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 30, 17, 17, 57), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 12, timestamp: date(2026, 1, 30, 17, 21, 5), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 1, 30, 17, 24, 36), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 30, 17, 28, 32), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 1, 30, 17, 33, 26), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 14, timestamp: date(2026, 1, 30, 17, 37, 56), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 30, 17, 42, 47), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 1, 30, 17, 50, 13), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 12, timestamp: date(2026, 1, 30, 17, 54, 29), restSeconds: 180)

        // SESSION 68: 2026-02-03 16:17:55
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 50.0, reps: 9, timestamp: date(2026, 2, 3, 16, 17, 55), restSeconds: 154)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 2, 3, 16, 20, 30), restSeconds: 152)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 6, timestamp: date(2026, 2, 3, 16, 23, 3), restSeconds: 162)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 8, timestamp: date(2026, 2, 3, 16, 25, 46), restSeconds: 180, isPB: true)
        // Chest Cable Flys: 3 sets
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 20, timestamp: date(2026, 2, 3, 16, 28, 54), restSeconds: 140)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 3, 16, 31, 15), restSeconds: 147)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 3, 16, 33, 43), restSeconds: 180)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2026, 2, 3, 16, 35, 58), restSeconds: 149)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2026, 2, 3, 16, 38, 27), restSeconds: 180)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 12, timestamp: date(2026, 2, 3, 16, 41, 47), restSeconds: 180)
        // Incline Dumbbell Chest Press: 3 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 10, timestamp: date(2026, 2, 3, 16, 43, 40), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 11, timestamp: date(2026, 2, 3, 16, 46, 56), restSeconds: 180, isPB: true)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 7, timestamp: date(2026, 2, 3, 16, 50, 7), restSeconds: 180)
        // Tricep Dips (bar): 3 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 10, timestamp: date(2026, 2, 3, 17, 1, 16), restSeconds: 108)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 10, timestamp: date(2026, 2, 3, 17, 3, 4), restSeconds: 174)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 11, timestamp: date(2026, 2, 3, 17, 5, 59), restSeconds: 180, isPB: true)
        // Tricep rope pushdown: 4 sets
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 12, timestamp: date(2026, 2, 3, 17, 9, 26), restSeconds: 84)
        addSet(exercise: "Tricep rope pushdown", weight: 45.0, reps: 10, timestamp: date(2026, 2, 3, 17, 10, 51), restSeconds: 85)
        addSet(exercise: "Tricep rope pushdown", weight: 42.0, reps: 10, timestamp: date(2026, 2, 3, 17, 12, 16), restSeconds: 127)
        addDropSet(exercise: "Tricep rope pushdown", weight: 39.5, reps: 10, timestamp: date(2026, 2, 3, 17, 14, 24), restSeconds: 180)

        // SESSION 69: 2026-02-05 16:21:40
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 2, 5, 16, 21, 40), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 2, 5, 16, 22, 30), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2026, 2, 5, 16, 25, 34), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 2, 5, 16, 26, 20), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 8, timestamp: date(2026, 2, 5, 16, 29, 4), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 17, timestamp: date(2026, 2, 5, 16, 30, 45), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 2, 5, 16, 33, 19), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 12, timestamp: date(2026, 2, 5, 16, 34, 7), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 2, 5, 16, 36, 46), restSeconds: 180)
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 5, 16, 39, 10), restSeconds: 128, isPB: true)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 2, 5, 16, 41, 18), restSeconds: 99)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 10, timestamp: date(2026, 2, 5, 16, 42, 57), restSeconds: 180)
        // T Bar Row: 3 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 12, timestamp: date(2026, 2, 5, 16, 46, 39), restSeconds: 126)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2026, 2, 5, 16, 48, 45), restSeconds: 180)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 12, timestamp: date(2026, 2, 5, 16, 51, 59), restSeconds: 180)
        // Seated dumbbell curl (on knee): 3 sets
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 12.0, reps: 10, timestamp: date(2026, 2, 5, 16, 55, 4), restSeconds: 180, isPB: true)
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 12.0, reps: 10, timestamp: date(2026, 2, 5, 16, 58, 17), restSeconds: 156)
        addSet(exercise: "Seated dumbbell curl (on knee)", weight: 12.0, reps: 8, timestamp: date(2026, 2, 5, 17, 0, 54))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 10, timestamp: date(2026, 2, 5, 17, 3, 51), restSeconds: 180)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2026, 2, 5, 17, 6, 53), restSeconds: 153)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2026, 2, 5, 17, 9, 26), restSeconds: 180)
        // Deadlifts: 3 sets
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 8, timestamp: date(2026, 2, 5, 17, 13, 28), restSeconds: 139)
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 8, timestamp: date(2026, 2, 5, 17, 15, 47), restSeconds: 180)
        addSet(exercise: "Deadlifts", weight: 60.0, reps: 8, timestamp: date(2026, 2, 5, 17, 19, 23), restSeconds: 180)
        // Face pulls: 3 sets
        addSet(exercise: "Face pulls", weight: 39.5, reps: 19, timestamp: date(2026, 2, 5, 17, 21, 35), restSeconds: 115)
        addSet(exercise: "Face pulls", weight: 45.0, reps: 18, timestamp: date(2026, 2, 5, 17, 23, 31), restSeconds: 160)
        addSet(exercise: "Face pulls", weight: 50.5, reps: 15, timestamp: date(2026, 2, 5, 17, 26, 11), restSeconds: 180)
        // Bicep rope curls: 2 sets
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2026, 2, 5, 17, 27, 52), restSeconds: 180)
        addSet(exercise: "Bicep rope curls", weight: 50.5, reps: 15, timestamp: date(2026, 2, 5, 17, 31, 5), restSeconds: 180)

        // SESSION 70: 2026-02-06 15:29:08
        // Press ups: 7 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 20, timestamp: date(2026, 2, 6, 15, 29, 8), restSeconds: 150, isPB: true)
        addSet(exercise: "Press ups", weight: 0.0, reps: 14, timestamp: date(2026, 2, 6, 15, 31, 39), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 2, 6, 15, 35, 11), restSeconds: 180)
        addSet(exercise: "Press ups", weight: 0.0, reps: 15, timestamp: date(2026, 2, 6, 15, 38, 42), restSeconds: 123)
        addSet(exercise: "Press ups", weight: 0.0, reps: 10, timestamp: date(2026, 2, 6, 15, 40, 46), restSeconds: 147)
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 2, 6, 15, 43, 13), restSeconds: 129)
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 2, 6, 15, 45, 22), restSeconds: 180)

        // SESSION 71: 2026-02-07 17:16:50
        // Incline chest press machine: 4 sets
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 12, timestamp: date(2026, 2, 7, 17, 16, 50), restSeconds: 180)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 12, timestamp: date(2026, 2, 7, 17, 20, 2), restSeconds: 166)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 9, timestamp: date(2026, 2, 7, 17, 22, 49), restSeconds: 180)
        addSet(exercise: "Incline chest press machine", weight: 40.0, reps: 13, timestamp: date(2026, 2, 7, 17, 26, 16))
        // Chest press machine: 3 sets
        addSet(exercise: "Chest press machine", weight: 50.0, reps: 7, timestamp: date(2026, 2, 7, 17, 29, 29), restSeconds: 180)
        addSet(exercise: "Chest press machine", weight: 50.0, reps: 8, timestamp: date(2026, 2, 7, 17, 32, 46), restSeconds: 180)
        addSet(exercise: "Chest press machine", weight: 50.0, reps: 9, timestamp: date(2026, 2, 7, 17, 36, 37))
        // Chest Cable Flys: 4 sets
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 18, timestamp: date(2026, 2, 7, 17, 40, 30), restSeconds: 129)
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 14, timestamp: date(2026, 2, 7, 17, 42, 40), restSeconds: 131, isPB: true)
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 11, timestamp: date(2026, 2, 7, 17, 44, 52), restSeconds: 23)
        addSet(exercise: "Chest Cable Flys", weight: 23.0, reps: 4, timestamp: date(2026, 2, 7, 17, 45, 15), restSeconds: 180)
        // Single cable lateral raise: 2 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 15, timestamp: date(2026, 2, 7, 17, 47, 58), restSeconds: 180)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 15, timestamp: date(2026, 2, 7, 17, 51, 33), restSeconds: 180)
        // Shoulder press machine : 3 sets
        addSet(exercise: "Shoulder press machine ", weight: 32.0, reps: 15, timestamp: date(2026, 2, 7, 17, 52, 30), restSeconds: 82)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 8, timestamp: date(2026, 2, 7, 17, 53, 52), restSeconds: 98)
        addSet(exercise: "Shoulder press machine ", weight: 37.5, reps: 9, timestamp: date(2026, 2, 7, 17, 55, 31), restSeconds: 180)
        // Tricep dips (bench): 2 sets
        addSet(exercise: "Tricep dips (bench)", weight: 0.0, reps: 20, timestamp: date(2026, 2, 7, 18, 14, 15), restSeconds: 180, isPB: true)
        addSet(exercise: "Tricep dips (bench)", weight: 0.0, reps: 15, timestamp: date(2026, 2, 7, 18, 19, 38), restSeconds: 180)

        // SESSION 72: 2026-02-08 10:22:24
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 16, timestamp: date(2026, 2, 8, 10, 22, 24), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 9, timestamp: date(2026, 2, 8, 10, 24, 7), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 16, timestamp: date(2026, 2, 8, 10, 25, 51), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 10, timestamp: date(2026, 2, 8, 10, 28, 42), restSeconds: 180, isPB: true)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 17, timestamp: date(2026, 2, 8, 10, 30, 47), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 2, 8, 10, 33, 0), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 13, timestamp: date(2026, 2, 8, 10, 34, 3), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 2, 8, 10, 36, 6), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 14, timestamp: date(2026, 2, 8, 10, 37, 20), restSeconds: 180)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 4, timestamp: date(2026, 2, 8, 10, 39, 39), restSeconds: 180)
        // Press ups: 1 sets
        addSet(exercise: "Press ups", weight: 0.0, reps: 10, timestamp: date(2026, 2, 8, 10, 40, 33))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 8, 10, 45, 40), restSeconds: 143)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 2, 8, 10, 48, 3), restSeconds: 152)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 12, timestamp: date(2026, 2, 8, 10, 50, 35), restSeconds: 180)
        // Seated cable row: 3 sets
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 15, timestamp: date(2026, 2, 8, 10, 52, 27), restSeconds: 180, isPB: true)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 11, timestamp: date(2026, 2, 8, 10, 55, 31), restSeconds: 152)
        addSet(exercise: "Seated cable row", weight: 59.5, reps: 11, timestamp: date(2026, 2, 8, 10, 58, 4))
        // Seated Incline dumbbell Curls: 5 sets
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 12, timestamp: date(2026, 2, 8, 11, 3, 17), restSeconds: 101)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2026, 2, 8, 11, 4, 59), restSeconds: 137)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 8, timestamp: date(2026, 2, 8, 11, 7, 17), restSeconds: 172)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 11, timestamp: date(2026, 2, 8, 11, 10, 9), restSeconds: 172)
        addSet(exercise: "Seated Incline dumbbell Curls", weight: 10.0, reps: 10, timestamp: date(2026, 2, 8, 11, 13, 2))
        // Dumbbell hammer curls : 3 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 12, timestamp: date(2026, 2, 8, 11, 15, 13), restSeconds: 180)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 14, timestamp: date(2026, 2, 8, 11, 18, 23), restSeconds: 156)
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 11, timestamp: date(2026, 2, 8, 11, 20, 59), restSeconds: 180)
        // Ball tricep pushdown: 3 sets
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 15, timestamp: date(2026, 2, 8, 11, 24, 34), restSeconds: 133, isPB: true)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 12, timestamp: date(2026, 2, 8, 11, 26, 48), restSeconds: 155)
        addSet(exercise: "Ball tricep pushdown", weight: 23.0, reps: 12, timestamp: date(2026, 2, 8, 11, 29, 24))
        // Face pulls: 3 sets
        addSet(exercise: "Face pulls", weight: 50.5, reps: 15, timestamp: date(2026, 2, 8, 11, 30, 52), restSeconds: 180)
        addSet(exercise: "Face pulls", weight: 53.0, reps: 13, timestamp: date(2026, 2, 8, 11, 33, 53), restSeconds: 180)
        addSet(exercise: "Face pulls", weight: 53.0, reps: 15, timestamp: date(2026, 2, 8, 11, 36, 55), restSeconds: 180, isPB: true)

        // SESSION 73: 2026-02-09 16:15:40
        // Back squat: 4 sets
        addSet(exercise: "Back squat", weight: 60.0, reps: 10, timestamp: date(2026, 2, 9, 16, 15, 40), restSeconds: 180)
        addSet(exercise: "Back squat", weight: 60.0, reps: 12, timestamp: date(2026, 2, 9, 16, 19, 15), restSeconds: 180, isPB: true)
        addSet(exercise: "Back squat", weight: 60.0, reps: 10, timestamp: date(2026, 2, 9, 16, 22, 15), restSeconds: 180)
        addSet(exercise: "Back squat", weight: 60.0, reps: 9, timestamp: date(2026, 2, 9, 16, 25, 30), restSeconds: 180)
        // Leg Raises: 3 sets
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2026, 2, 9, 16, 28, 1), restSeconds: 94)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2026, 2, 9, 16, 29, 36), restSeconds: 101)
        addSet(exercise: "Leg Raises", weight: 59.5, reps: 12, timestamp: date(2026, 2, 9, 16, 31, 17), restSeconds: 180)
        // Glute drive: 3 sets
        addSet(exercise: "Glute drive", weight: 30.0, reps: 15, timestamp: date(2026, 2, 9, 16, 35, 56), restSeconds: 62)
        addSet(exercise: "Glute drive", weight: 30.0, reps: 16, timestamp: date(2026, 2, 9, 16, 36, 58), restSeconds: 180, isPB: true)
        addSet(exercise: "Glute drive", weight: 30.0, reps: 16, timestamp: date(2026, 2, 9, 16, 40, 8), restSeconds: 180)
        // Hamstring Curls: 4 sets
        addWarmUpSet(exercise: "Hamstring Curls", weight: 43.0, reps: 12, timestamp: date(2026, 2, 9, 16, 43, 15), restSeconds: 142)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 12, timestamp: date(2026, 2, 9, 16, 45, 37), restSeconds: 180)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 15, timestamp: date(2026, 2, 9, 16, 50, 27), restSeconds: 125, isPB: true)
        addSet(exercise: "Hamstring Curls", weight: 48.5, reps: 14, timestamp: date(2026, 2, 9, 16, 52, 32))
        // Dumbbell lunges: 3 sets
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 16, timestamp: date(2026, 2, 9, 17, 4, 23), restSeconds: 180, isPB: true)
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 16, timestamp: date(2026, 2, 9, 17, 8, 18), restSeconds: 180)
        addSet(exercise: "Dumbbell lunges", weight: 12.5, reps: 14, timestamp: date(2026, 2, 9, 17, 11, 47), restSeconds: 2)

        // SESSION 74: 2026-02-11 16:28:41
        // Chest Press: 4 sets
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 2, 11, 16, 28, 41), restSeconds: 153)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 2, 11, 16, 31, 14), restSeconds: 172)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 7, timestamp: date(2026, 2, 11, 16, 34, 7), restSeconds: 180)
        addSet(exercise: "Chest Press", weight: 60.0, reps: 8, timestamp: date(2026, 2, 11, 16, 38, 13), restSeconds: 180)
        // Incline Dumbbell Chest Press: 4 sets
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 9, timestamp: date(2026, 2, 11, 16, 39, 59), restSeconds: 137)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 2, 11, 16, 42, 16), restSeconds: 160)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 2, 11, 16, 44, 57), restSeconds: 180)
        addSet(exercise: "Incline Dumbbell Chest Press", weight: 25.0, reps: 8, timestamp: date(2026, 2, 11, 16, 48, 0), restSeconds: 180)
        // Chest Cable Flys: 4 sets
        addSet(exercise: "Chest Cable Flys", weight: 17.5, reps: 14, timestamp: date(2026, 2, 11, 16, 49, 16), restSeconds: 162)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 11, 16, 51, 58), restSeconds: 150)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 16, timestamp: date(2026, 2, 11, 16, 54, 29), restSeconds: 104)
        addSet(exercise: "Chest Cable Flys", weight: 20.0, reps: 11, timestamp: date(2026, 2, 11, 16, 56, 13), restSeconds: 180)
        // Single cable lateral raise: 3 sets
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 15, timestamp: date(2026, 2, 11, 16, 58, 12), restSeconds: 153)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 15, timestamp: date(2026, 2, 11, 17, 0, 46), restSeconds: 180)
        addSet(exercise: "Single cable lateral raise", weight: 20.0, reps: 15, timestamp: date(2026, 2, 11, 17, 3, 54), restSeconds: 180)
        // Overhead Tricep Rope Pulls: 3 sets
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 13, timestamp: date(2026, 2, 11, 17, 5, 56), restSeconds: 177, isPB: true)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 11, timestamp: date(2026, 2, 11, 17, 8, 53), restSeconds: 140)
        addSet(exercise: "Overhead Tricep Rope Pulls", weight: 42.0, reps: 12, timestamp: date(2026, 2, 11, 17, 11, 14), restSeconds: 180)
        // Tricep Dips (bar): 4 sets
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 11, timestamp: date(2026, 2, 11, 17, 14, 8), restSeconds: 144)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 11, timestamp: date(2026, 2, 11, 17, 16, 33), restSeconds: 167)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 10, timestamp: date(2026, 2, 11, 17, 19, 20), restSeconds: 180)
        addSet(exercise: "Tricep Dips (bar)", weight: 10.0, reps: 8, timestamp: date(2026, 2, 11, 17, 23, 55), restSeconds: 180)
        // Lu Raise: 2 sets
        addSet(exercise: "Lu Raise", weight: 5.0, reps: 10, timestamp: date(2026, 2, 11, 17, 36, 9), restSeconds: 114)
        addSet(exercise: "Lu Raise", weight: 5.0, reps: 11, timestamp: date(2026, 2, 11, 17, 38, 4), restSeconds: 180, isPB: true)

        // SESSION 75: 2026-02-15 14:24:12
        // Pull ups: 5 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 2, 15, 14, 24, 12), restSeconds: 108)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 2, 15, 14, 26, 0), restSeconds: 180)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 6, timestamp: date(2026, 2, 15, 14, 30, 37), restSeconds: 180)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 7, timestamp: date(2026, 2, 15, 14, 33, 50), restSeconds: 130)
        addSet(exercise: "Pull ups", weight: 0.0, reps: 5, timestamp: date(2026, 2, 15, 14, 36, 0), restSeconds: 180)
        // T Bar Row: 4 sets
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 11, timestamp: date(2026, 2, 15, 14, 42, 1), restSeconds: 162)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2026, 2, 15, 14, 44, 43), restSeconds: 176)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 10, timestamp: date(2026, 2, 15, 14, 47, 40), restSeconds: 150)
        addSet(exercise: "T Bar Row", weight: 35.0, reps: 6, timestamp: date(2026, 2, 15, 14, 50, 11))
        // Reverse Cable Flys: 3 sets
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 13, timestamp: date(2026, 2, 15, 14, 52, 59), restSeconds: 123)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 13, timestamp: date(2026, 2, 15, 14, 55, 2), restSeconds: 133)
        addSet(exercise: "Reverse Cable Flys", weight: 20.0, reps: 15, timestamp: date(2026, 2, 15, 14, 57, 15))
        // Bicep rope curls: 3 sets
        addSet(exercise: "Bicep rope curls", weight: 53.0, reps: 17, timestamp: date(2026, 2, 15, 14, 59, 3), restSeconds: 136, isPB: true)
        addSet(exercise: "Bicep rope curls", weight: 53.0, reps: 16, timestamp: date(2026, 2, 15, 15, 1, 19), restSeconds: 176)
        addSet(exercise: "Bicep rope curls", weight: 53.0, reps: 13, timestamp: date(2026, 2, 15, 15, 4, 16))
        // Straight Arm Lat Pulldown: 4 sets
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 56.0, reps: 12, timestamp: date(2026, 2, 15, 15, 6, 11), restSeconds: 180)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 56.0, reps: 10, timestamp: date(2026, 2, 15, 15, 10, 54), restSeconds: 45)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 56.0, reps: 7, timestamp: date(2026, 2, 15, 15, 11, 40), restSeconds: 91)
        addSet(exercise: "Straight Arm Lat Pulldown", weight: 56.0, reps: 7, timestamp: date(2026, 2, 15, 15, 13, 11))
        // Dumbbell hammer curls : 1 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 15, timestamp: date(2026, 2, 15, 15, 16, 6), restSeconds: 168)
        // Box jumps: 1 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2026, 2, 15, 15, 17, 24), restSeconds: 180)
        // Dumbbell hammer curls : 1 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 16, timestamp: date(2026, 2, 15, 15, 18, 54), restSeconds: 180, isPB: true)
        // Box jumps: 1 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 15, timestamp: date(2026, 2, 15, 15, 20, 43), restSeconds: 141)
        // Dumbbell hammer curls : 1 sets
        addSet(exercise: "Dumbbell hammer curls ", weight: 12.5, reps: 16, timestamp: date(2026, 2, 15, 15, 22, 56))
        // Box jumps: 1 sets
        addSet(exercise: "Box jumps", weight: 0.0, reps: 16, timestamp: date(2026, 2, 15, 15, 23, 4), isPB: true)
        // Pull ups: 1 sets
        addSet(exercise: "Pull ups", weight: 0.0, reps: 4, timestamp: date(2026, 2, 15, 15, 26, 9))

        // Save all changes
        do {
            try modelContext.save()

            // Recalculate PB flags for all exercises (safety net to ensure correctness)
            for (_, exercise) in exercises {
                // Get all sets for this exercise and recalculate PBs
                for set in (exercise.sets ?? []) where !set.isWarmUp {
                    try ExerciseSetService.detectAndMarkPB(for: set, exercise: exercise, context: modelContext)
                }
            }
            try modelContext.save()
        } catch {
            print("Error saving test data: \(error)")
        }
    }

    // MARK: - Cleanup

    private static func clearAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Exercise.self)
            try modelContext.delete(model: ExerciseSet.self)
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

#endif
