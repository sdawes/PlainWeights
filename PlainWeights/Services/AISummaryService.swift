//
//  AISummaryService.swift
//  PlainWeights
//
//  Generates an AI summary of recent training using Apple's on-device
//  Foundation Models framework (iOS 26+). All inference runs on-device —
//  nothing leaves the user's iPhone.
//
//  Optimisations applied:
//  - GenerationOptions(.greedy, temperature: 0) for deterministic output
//    so the same input produces the same analysis on every tap.
//  - @Generable structured output (WorkoutAnalysis) so the framework
//    constrains the model to valid fields, eliminating template leaks
//    and making the SwiftUI render trivial.
//  - Period selection stays in Swift (30 days vs prior 30 days) — the
//    on-device 3B model isn't equipped to reason about what window
//    matters most for a given user.
//

import Foundation
import FoundationModels

// MARK: - Structured Output

/// The shape of an AI-generated workout analysis. Each field corresponds
/// to a labelled section in the sheet. The `@Generable` macro lets the
/// Foundation Models framework constrain output to this schema —
/// dramatically more reliable than asking the model to format prose.
@Generable
struct WorkoutAnalysis {
    @Guide(description: "Two to three sentences describing what muscle groups and exercises were trained over the past 30 days. Use the exact exercise names from the data — do not paraphrase or substitute them. Focus on muscle coverage and balance. If an entire muscle group (e.g. legs, back) appears absent from the data, flag it — but only based on what is actually missing from the provided exercise list, not from general gym knowledge. Plain prose, no bullets, no markdown.")
    var coverage: String

    @Guide(description: "Two to three sentences on progress vs the prior 30 days. Are you lifting more weight, doing more reps, hitting more total volume, or slipping? Reference one to two specific exercises with concrete numbers from the data only — never invent numbers. Plain prose.")
    var progress: String

    @Guide(description: "One specific actionable recommendation referencing real exercises or muscle groups. If everything looks balanced and progressing, write exactly 'No changes needed.'")
    var recommendation: String
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
                return "Add an exercise and log a few sets, then come back for insights."
            case .generationFailed:
                return "Couldn't generate summary. Please try again."
            }
        }
    }

    // MARK: - System Prompt

    private static let systemPrompt: String = """
    You are a knowledgeable gym coach. You see the user's training over the past 30 days plus stats from the prior 30 days for comparison. Address the user as "you". Be direct and factual. Use clear gym terminology (compound lift, antagonist, push/pull split, accessory work). No emoji, no hype, no preambles.

    CRITICAL — exercise names:
    - Every exercise name in your response MUST appear verbatim in the "EXERCISES TRAINED IN PAST 30 DAYS" section of the data below.
    - NEVER mention an exercise by a name that is not listed there. Do not substitute, generalise, or invent exercise names (e.g. do not say "deadlift" if only "Romanian Deadlift" appears in the data — they are different entries).
    - If you want to say an exercise was not done, it must appear in the "EXERCISES TRAINED IN PRIOR 30 DAYS BUT NOT THIS PERIOD" section. Do not flag an exercise as missing based on your own knowledge of muscle groups.

    Determine muscle groups from the EXERCISE NAME (e.g. "Bench press" implies chest, triceps, front delts). Tags in brackets are supplementary context only.

    Use only numbers that appear in the data — do not invent or estimate values that aren't there.
    """

    // MARK: - Public API

    /// Optional one-time prewarm. Call from the parent view's `.onAppear`
    /// to reduce first-tap latency. Cheap; safe to call repeatedly.
    static func prewarm() {
        guard SystemLanguageModel.default.isAvailable else { return }
        _ = LanguageModelSession(instructions: systemPrompt)
    }

    /// Generate a workout analysis covering the past 30 days, with progress
    /// observations vs the prior 30 days. Output is deterministic for a
    /// given input thanks to greedy sampling + zero temperature.
    static func generateAnalysis(
        from sets: [ExerciseSet],
        weightUnit: WeightUnit
    ) async throws -> WorkoutAnalysis {

        guard SystemLanguageModel.default.isAvailable else {
            throw SummaryError.unavailable
        }

        // Single-pass partition into current 30 days and prior 30 days.
        let calendar = Calendar.current
        let now = Date()
        guard
            let thirtyDays = calendar.date(byAdding: .day, value: -30, to: now),
            let sixtyDays = calendar.date(byAdding: .day, value: -60, to: now)
        else {
            throw SummaryError.generationFailed
        }

        var currentSets: [ExerciseSet] = []
        var priorSets: [ExerciseSet] = []
        for set in sets {
            if set.timestamp >= thirtyDays {
                currentSets.append(set)
            } else if set.timestamp >= sixtyDays {
                priorSets.append(set)
            }
        }

        guard !currentSets.isEmpty else {
            throw SummaryError.noWorkouts
        }

        let dataSection = buildDataSection(
            currentSets: currentSets,
            priorSets: priorSets,
            unit: weightUnit
        )

        // Deterministic sampling — same data should give the same analysis
        // every time the user taps the button.
        let options = GenerationOptions(
            sampling: .greedy,
            temperature: 0.0
        )

        do {
            let session = LanguageModelSession(instructions: systemPrompt)
            let analysis = try await session.respond(
                to: dataSection,
                generating: WorkoutAnalysis.self,
                options: options
            )
            return analysis.content
        } catch {
            print("❌ AISummaryService — FoundationModels error: \(error)")
            throw SummaryError.generationFailed
        }
    }

    // MARK: - Stats

    /// Aggregated stats per exercise across a period.
    private struct ExerciseStats {
        let exercise: Exercise
        let sessions: Int
        let totalSets: Int
        let maxWeight: Double      // user's display unit; 0 for bodyweight
        let totalReps: Int
        let totalVolume: Double    // user's display unit
    }

    private static func computeStats(
        from sets: [ExerciseSet],
        unit: WeightUnit
    ) -> [String: ExerciseStats] {
        let calendar = Calendar.current
        var raw: [String: (exercise: Exercise, days: Set<Date>, sets: Int, maxWeight: Double, totalReps: Int, totalVolume: Double)] = [:]

        for set in sets.workingSets {
            guard let exercise = set.exercise else { continue }
            let key = exercise.name
            let dayKey = calendar.startOfDay(for: set.timestamp)
            let displayWeight = unit.fromKg(set.weight)
            let volume = displayWeight * Double(set.reps)

            if var existing = raw[key] {
                existing.days.insert(dayKey)
                existing.sets += 1
                existing.maxWeight = max(existing.maxWeight, displayWeight)
                existing.totalReps += set.reps
                existing.totalVolume += volume
                raw[key] = existing
            } else {
                raw[key] = (exercise, [dayKey], 1, displayWeight, set.reps, volume)
            }
        }

        return raw.mapValues {
            ExerciseStats(
                exercise: $0.exercise,
                sessions: $0.days.count,
                totalSets: $0.sets,
                maxWeight: $0.maxWeight,
                totalReps: $0.totalReps,
                totalVolume: $0.totalVolume
            )
        }
    }

    // MARK: - Data section

    private static func buildDataSection(
        currentSets: [ExerciseSet],
        priorSets: [ExerciseSet],
        unit: WeightUnit
    ) -> String {
        let currentStats = computeStats(from: currentSets, unit: unit)
        let priorStats = computeStats(from: priorSets, unit: unit)
        let calendar = Calendar.current

        let currentSessions = Set(currentSets.workingSets.map { calendar.startOfDay(for: $0.timestamp) }).count
        let priorSessions = Set(priorSets.workingSets.map { calendar.startOfDay(for: $0.timestamp) }).count

        var lines: [String] = []
        lines.append("PAST 30 DAYS:")
        lines.append("Sessions in current 30 days: \(currentSessions)")
        lines.append("Sessions in prior 30 days (for comparison): \(priorSessions)")
        lines.append("")
        lines.append("EXERCISES TRAINED IN PAST 30 DAYS (with change vs prior 30 days):")

        let sortedCurrent = currentStats.values.sorted { $0.sessions > $1.sessions }
        for stat in sortedCurrent {
            lines.append(formatExerciseLine(
                current: stat,
                prior: priorStats[stat.exercise.name],
                unit: unit
            ))
        }

        // Highlight exercises trained in prior but not in current — gap signals.
        let currentNames = Set(currentStats.keys)
        let droppedStats = priorStats.values
            .filter { !currentNames.contains($0.exercise.name) }
            .sorted { $0.sessions > $1.sessions }

        if !droppedStats.isEmpty {
            lines.append("")
            lines.append("EXERCISES TRAINED IN PRIOR 30 DAYS BUT NOT THIS PERIOD:")
            for stat in droppedStats {
                lines.append("- \(stat.exercise.name)\(formatTags(stat.exercise)): \(stat.sessions) sessions previously, 0 in past 30 days")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func formatExerciseLine(
        current: ExerciseStats,
        prior: ExerciseStats?,
        unit: WeightUnit
    ) -> String {
        let unitName = unit.displayName
        let isBodyweight = current.maxWeight == 0
        let id = "\(current.exercise.name)\(formatTags(current.exercise))"

        // Current stats
        let currentStr: String
        if isBodyweight {
            currentStr = "\(current.sessions) sessions, \(current.totalSets) sets, \(current.totalReps) reps total"
        } else {
            let maxStr = Formatters.formatWeight(current.maxWeight)
            let volStr = Formatters.formatVolume(current.totalVolume)
            currentStr = "\(current.sessions) sessions, \(current.totalSets) sets, max \(maxStr)\(unitName), volume \(volStr)\(unitName)"
        }

        // Delta vs prior
        let deltaStr: String
        if let prior = prior {
            var deltas: [String] = []
            let sessionDelta = current.sessions - prior.sessions
            if sessionDelta != 0 {
                deltas.append("sessions \(signedInt(sessionDelta))")
            }
            if isBodyweight {
                let repsDelta = current.totalReps - prior.totalReps
                if repsDelta != 0 {
                    deltas.append("reps \(signedInt(repsDelta))")
                }
            } else {
                let weightDelta = current.maxWeight - prior.maxWeight
                if abs(weightDelta) >= 0.5 {
                    deltas.append("max \(signedWeight(weightDelta))\(unitName)")
                }
                if prior.totalVolume > 0 {
                    let pct = ((current.totalVolume - prior.totalVolume) / prior.totalVolume) * 100
                    if abs(pct) >= 1 {
                        deltas.append("volume \(signedPct(pct))")
                    }
                }
            }
            deltaStr = deltas.isEmpty ? "no change" : deltas.joined(separator: ", ")
        } else {
            deltaStr = "new in this period (no prior data)"
        }

        return "- \(id) | current: \(currentStr) | vs prior 30d: \(deltaStr)"
    }

    // MARK: - Helpers

    private static func signedInt(_ n: Int) -> String {
        n > 0 ? "+\(n)" : "\(n)"
    }

    private static func signedWeight(_ d: Double) -> String {
        let s = Formatters.formatWeight(abs(d))
        return d > 0 ? "+\(s)" : "-\(s)"
    }

    private static func signedPct(_ p: Double) -> String {
        let v = Int(p.rounded())
        return v > 0 ? "+\(v)%" : "\(v)%"
    }

    private static func formatTags(_ exercise: Exercise) -> String {
        let combined = exercise.tags + exercise.secondaryTags
        guard !combined.isEmpty else { return "" }
        return " (\(combined.joined(separator: ", ")))"
    }
}
