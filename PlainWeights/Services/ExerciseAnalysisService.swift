//
//  ExerciseAnalysisService.swift
//  PlainWeights
//
//  Generates an AI analysis of a single exercise's history using
//  Apple's on-device Foundation Models framework. Sister service to
//  AISummaryService — same on-device guarantees, same deterministic
//  sampling, but scoped to one exercise instead of the whole workout.
//
//  All inference runs on-device — nothing leaves the user's iPhone.
//

import Foundation
import FoundationModels

// MARK: - Structured Output

/// AI-generated analysis of a single exercise. Three labelled sections
/// rendered by `ExerciseAnalysisView`.
@Generable
struct ExerciseAnalysis {
    @Guide(description: "Two to three sentences describing the user's progression on this specific exercise over the recent sessions in the data. Reference concrete weights, reps, or session dates from the data — never invent numbers. Plain prose, no bullets, no markdown.")
    var progression: String

    @Guide(description: "Two to three sentences on how hard the user appears to be working — based on weight relative to their personal best, rep ranges, and total volume per session. Use clear gym terminology (intensity, load, rep range, accumulated volume). Cite numbers from the data only.")
    var effort: String

    @Guide(description: "One specific actionable recommendation: e.g. add weight, add reps, change tempo, deload, or 'No changes needed.' if the trajectory looks healthy. Keep it grounded in the data shown.")
    var recommendation: String
}

enum ExerciseAnalysisService {

    /// User-facing errors. Sanitised so view code never sees raw
    /// FoundationModels errors.
    enum AnalysisError: LocalizedError {
        case unavailable
        case noSessions
        case generationFailed

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "AI analysis isn't available on this device. Check Apple Intelligence is enabled in Settings."
            case .noSessions:
                return "Log a few sets for this exercise, then come back for an analysis."
            case .generationFailed:
                return "Couldn't generate analysis. Please try again."
            }
        }
    }

    // MARK: - System Prompt

    private static let systemPrompt: String = """
    You are a knowledgeable strength coach analysing the user's history for a single exercise. Address the user as "you". Be direct and factual. Use clear gym terminology (intensity, working set, rep range, accumulated volume, progressive overload, plateau).

    OUTPUT FORMAT — strict rules:
    - Plain prose only. The output is rendered as raw text — formatting characters appear literally.
    - DO NOT use markdown of any kind: no asterisks (**, *), no underscores (__, _), no backticks, no hash headers, no bullets (-, *, +) at the start of lines, no numbered lists.
    - DO NOT use emoji, hype, or preambles. Keep each section to two or three short sentences.

    CRITICAL — grounding rules:
    - Use only numbers, dates, and facts that appear in the data below. Never invent or estimate values that aren't there.
    - The exercise name and tags identify the lift and the muscles involved. Do not redefine the exercise; just analyse the user's history with it.
    - If there is only one session of data, say so plainly — do not fabricate a trend.
    """

    // MARK: - Public API

    /// Generate a three-section analysis for one exercise. Default
    /// call uses greedy sampling + zero temperature (deterministic).
    /// Pass `regenerate: true` for a varied rephrasing, used when the
    /// user taps "Try again".
    static func generateAnalysis(
        for exercise: Exercise,
        weightUnit: WeightUnit,
        regenerate: Bool = false
    ) async throws -> ExerciseAnalysis {

        guard SystemLanguageModel.default.isAvailable else {
            throw AnalysisError.unavailable
        }

        let workingSets = (exercise.sets ?? []).workingSets
        guard !workingSets.isEmpty else {
            throw AnalysisError.noSessions
        }

        let dataSection = buildDataSection(
            exercise: exercise,
            sets: workingSets,
            unit: weightUnit
        )

        let options: GenerationOptions = regenerate
            ? GenerationOptions(temperature: 0.6)
            : GenerationOptions(sampling: .greedy, temperature: 0.0)

        do {
            let session = LanguageModelSession(instructions: systemPrompt)
            let analysis = try await session.respond(
                to: dataSection,
                generating: ExerciseAnalysis.self,
                options: options
            )
            var content = analysis.content
            content.progression = sanitize(content.progression)
            content.effort = sanitize(content.effort)
            content.recommendation = sanitize(content.recommendation)
            return content
        } catch {
            print("❌ ExerciseAnalysisService — FoundationModels error: \(error)")
            throw AnalysisError.generationFailed
        }
    }

    /// Strip the markdown markers most likely to leak through from the
    /// model. Bold (`**`, `__`) is by far the most common offender.
    private static func sanitize(_ text: String) -> String {
        text.replacing("**", with: "").replacing("__", with: "")
    }

    // MARK: - Per-session aggregation

    /// One day's worth of stats for the exercise.
    private struct SessionStats {
        let date: Date
        let setCount: Int
        let maxWeight: Double      // user's display unit; 0 for bodyweight
        let maxWeightReps: Int     // reps achieved at max weight
        let totalReps: Int
        let totalVolume: Double    // user's display unit
    }

    private static func buildSessions(from sets: [ExerciseSet], unit: WeightUnit) -> [SessionStats] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: sets) {
            calendar.startOfDay(for: $0.timestamp)
        }
        return byDay.map { (date, daySets) in
            // Find the heaviest set; tie-break on most reps.
            let topSet = daySets.max { a, b in
                if a.weight != b.weight { return a.weight < b.weight }
                return a.reps < b.reps
            }
            let maxWeight = unit.fromKg(topSet?.weight ?? 0)
            let maxWeightReps = topSet?.reps ?? 0
            let totalReps = daySets.reduce(0) { $0 + $1.reps }
            let totalVolume = daySets.reduce(0.0) { $0 + (unit.fromKg($1.weight) * Double($1.reps)) }
            return SessionStats(
                date: date,
                setCount: daySets.count,
                maxWeight: maxWeight,
                maxWeightReps: maxWeightReps,
                totalReps: totalReps,
                totalVolume: totalVolume
            )
        }
        .sorted { $0.date > $1.date }   // most recent first
    }

    // MARK: - Data section

    private static func buildDataSection(
        exercise: Exercise,
        sets: [ExerciseSet],
        unit: WeightUnit
    ) -> String {
        let sessions = buildSessions(from: sets, unit: unit)
        let isBodyweight = sessions.allSatisfy { $0.maxWeight == 0 }
        let unitName = unit.displayName

        var lines: [String] = []

        // Identify the exercise.
        let allTags = exercise.tags + exercise.secondaryTags
        let tagsStr = allTags.isEmpty ? "" : " (\(allTags.joined(separator: ", ")))"
        lines.append("EXERCISE: \(exercise.name)\(tagsStr)")
        lines.append("")

        // Personal best (most recent flagged PB if multiple).
        let pbSet = sets.filter { $0.isPB }.max(by: { $0.timestamp < $1.timestamp })
        if let pb = pbSet {
            let dateStr = formattedDate(pb.timestamp)
            if isBodyweight {
                lines.append("ALL-TIME BEST: \(pb.reps) reps (\(dateStr))")
            } else {
                let pbWeight = Formatters.formatWeight(unit.fromKg(pb.weight))
                lines.append("ALL-TIME BEST: \(pbWeight)\(unitName) × \(pb.reps) reps (\(dateStr))")
            }
            lines.append("")
        }

        // Recent sessions, capped to keep the prompt focused.
        let recent = Array(sessions.prefix(10))
        lines.append("RECENT SESSIONS (most recent first, up to 10):")
        for s in recent {
            let dateStr = formattedDate(s.date)
            if isBodyweight {
                lines.append("- \(dateStr): \(s.setCount) sets, \(s.totalReps) total reps")
            } else {
                let maxStr = Formatters.formatWeight(s.maxWeight)
                let volStr = Formatters.formatVolume(s.totalVolume)
                lines.append("- \(dateStr): \(s.setCount) sets, max \(maxStr)\(unitName) × \(s.maxWeightReps) reps, \(s.totalReps) reps total, volume \(volStr)\(unitName)")
            }
        }

        if sessions.count > recent.count {
            lines.append("")
            lines.append("(\(sessions.count - recent.count) older sessions exist but are not shown.)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
