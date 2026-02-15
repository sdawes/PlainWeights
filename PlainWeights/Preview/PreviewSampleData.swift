//
//  PreviewSampleData.swift
//  PlainWeights
//
//  Preview sample data for SwiftUI previews
//

import SwiftUI
import SwiftData

/// Preview modifier that provides sample exercise and set data
struct ExerciseListPreviewData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: Exercise.self, ExerciseSet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let calendar = Calendar.current
        let now = Date()

        // Exercise 1: Bench Press - Done today (green)
        let bench = Exercise(name: "Bench Press", tags: ["Chest", "Push"], secondaryTags: ["Triceps"])
        container.mainContext.insert(bench)

        // Today's sets
        container.mainContext.insert(ExerciseSet(timestamp: now, weight: 100, reps: 8, exercise: bench))
        container.mainContext.insert(ExerciseSet(timestamp: now.addingTimeInterval(180), weight: 100, reps: 7, exercise: bench))
        container.mainContext.insert(ExerciseSet(timestamp: now.addingTimeInterval(360), weight: 100, reps: 6, exercise: bench))

        // 1 week ago
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: weekAgo, weight: 95, reps: 8, exercise: bench))
        container.mainContext.insert(ExerciseSet(timestamp: weekAgo.addingTimeInterval(180), weight: 95, reps: 8, exercise: bench))

        // Exercise 2: Squat - Recent (no color)
        let squat = Exercise(name: "Squat", tags: ["Legs", "Compound"])
        container.mainContext.insert(squat)

        // 3 days ago
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: threeDaysAgo, weight: 140, reps: 5, isPB: true, exercise: squat))
        container.mainContext.insert(ExerciseSet(timestamp: threeDaysAgo.addingTimeInterval(240), weight: 140, reps: 4, exercise: squat))
        container.mainContext.insert(ExerciseSet(timestamp: threeDaysAgo.addingTimeInterval(480), weight: 130, reps: 5, isDropSet: true, exercise: squat))

        // 10 days ago
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: tenDaysAgo, weight: 135, reps: 5, exercise: squat))

        // Exercise 3: Deadlift - Stale (orange - 3 weeks)
        let deadlift = Exercise(name: "Deadlift", tags: ["Back", "Legs"], secondaryTags: ["Core"])
        container.mainContext.insert(deadlift)

        // 21 days ago
        let threeWeeksAgo = calendar.date(byAdding: .day, value: -21, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: threeWeeksAgo, weight: 180, reps: 3, exercise: deadlift))
        container.mainContext.insert(ExerciseSet(timestamp: threeWeeksAgo.addingTimeInterval(300), weight: 180, reps: 2, exercise: deadlift))

        // Exercise 4: Pull-ups - Very stale (red - 6 weeks)
        let pullups = Exercise(name: "Pull-ups", tags: ["Back", "Pull"], secondaryTags: ["Biceps"])
        container.mainContext.insert(pullups)

        // 42 days ago
        let sixWeeksAgo = calendar.date(byAdding: .day, value: -42, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: sixWeeksAgo, weight: 0, reps: 12, exercise: pullups))
        container.mainContext.insert(ExerciseSet(timestamp: sixWeeksAgo.addingTimeInterval(120), weight: 0, reps: 10, exercise: pullups))
        container.mainContext.insert(ExerciseSet(timestamp: sixWeeksAgo.addingTimeInterval(240), weight: 0, reps: 8, exercise: pullups))

        // Exercise 5: Overhead Press - Recent
        let ohp = Exercise(name: "Overhead Press", tags: ["Shoulders", "Push"], secondaryTags: ["Triceps"])
        container.mainContext.insert(ohp)

        // 5 days ago
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: fiveDaysAgo, weight: 60, reps: 8, exercise: ohp))
        container.mainContext.insert(ExerciseSet(timestamp: fiveDaysAgo.addingTimeInterval(200), weight: 60, reps: 7, exercise: ohp))

        // Exercise 6: Barbell Rows - Recent with PB
        let rows = Exercise(name: "Barbell Rows", tags: ["Back"], secondaryTags: ["Biceps", "Core"])
        container.mainContext.insert(rows)

        // 2 days ago
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        container.mainContext.insert(ExerciseSet(timestamp: twoDaysAgo, weight: 80, reps: 10, isPB: true, exercise: rows))
        container.mainContext.insert(ExerciseSet(timestamp: twoDaysAgo.addingTimeInterval(180), weight: 80, reps: 9, exercise: rows))
        container.mainContext.insert(ExerciseSet(timestamp: twoDaysAgo.addingTimeInterval(360), weight: 75, reps: 10, isDropSet: true, exercise: rows))

        // Exercise 7: Lat Pulldown - Never done (no sets)
        let latPulldown = Exercise(name: "Lat Pulldown", tags: ["Back"])
        container.mainContext.insert(latPulldown)

        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}
