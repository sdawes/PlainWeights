//
//  AISummaryService.swift
//  PlainWeights
//
//  Generates AI summaries of workouts using Apple's on-device Foundation
//  Models framework (iOS 26+). All inference runs on-device — nothing
//  leaves the user's iPhone.
//

import Foundation
import FoundationModels

/// Scope of an AI-generated summary. The user picks one from the menu in
/// the exercise list toolbar; the service uses it to decide which slice
/// of training data to feed into the prompt.
enum AISummaryScope: String, CaseIterable, Identifiable {
    case lastSession = "Last session"
    case lastWeek = "Past 7 days"
    case lastMonth = "Past 30 days"
    case lastYear = "Past 12 months"

    var id: String { rawValue }
}

enum AISummaryService {

    /// User-facing errors. Sanitised so view code never has to know about
    /// FoundationModels internals.
    enum SummaryError: LocalizedError {
        case unavailable
        case noWorkouts
        case generationFailed

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "AI summary isn't available on this device. Check Apple Intelligence is enabled in Settings."
            case .noWorkouts:
                return "Record a workout first, then come back for a summary."
            case .generationFailed:
                return "Couldn't generate summary. Please try again."
            }
        }
    }

    /// Generate a 2–3 sentence summary of the most recent workout.
    static func generateLastSessionSummary(
        from sets: [ExerciseSet],
        weightUnit: WeightUnit
    ) async throws -> String {

        // 1) Capability gate.
        guard case .available = SystemLanguageModel.default.availability else {
            throw SummaryError.unavailable
        }

        // 2) Build prompt.
        guard let prompt = buildPrompt(from: sets, weightUnit: weightUnit) else {
            throw SummaryError.noWorkouts
        }

        // 3) Run on-device model.
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            // Diagnostics to console only; user gets a clean message.
            print("❌ AISummaryService — FoundationModels error: \(error)")
            throw SummaryError.generationFailed
        }
    }

    // MARK: - Prompt

    /// Build the prompt from the most recent workout day. Returns nil if
    /// there are no sets in the database.
    ///
    /// Performance: we find the most recent day first and filter to just
    /// that day before grouping, so we don't pay the cost of grouping the
    /// entire training history just to read one day.
    private static func buildPrompt(from sets: [ExerciseSet], weightUnit: WeightUnit) -> String? {
        let calendar = Calendar.current
        guard let mostRecent = sets.max(by: { $0.timestamp < $1.timestamp }) else {
            return nil
        }
        let lastDaySets = sets.filter {
            calendar.isDate($0.timestamp, inSameDayAs: mostRecent.timestamp)
        }

        let workoutDays = ExerciseDataGrouper.createWorkoutJournal(from: lastDaySets)
        guard let lastDay = workoutDays.first else { return nil }

        let dateStr = lastDay.date.formatted(.dateTime.weekday(.wide).day().month(.wide))

        var lines: [String] = []
        for ex in lastDay.exercises {
            let setStrings = ex.sets.workingSets.map { set in
                if set.weight == 0 {
                    return "\(set.reps) reps"
                } else {
                    let displayed = weightUnit.fromKg(set.weight)
                    return "\(Formatters.formatWeight(displayed)) \(weightUnit.displayName) × \(set.reps)"
                }
            }.joined(separator: ", ")
            lines.append("- \(ex.exercise.name): \(setStrings)")
        }
        let body = lines.joined(separator: "\n")

        return """
        Below is my workout from \(dateStr). Write a friendly 2–3 sentence summary of how it went, focusing on what stood out — strong lifts, total volume, or anything that looks notable. Keep it natural and supportive, not robotic.

        \(body)
        """
    }
}
