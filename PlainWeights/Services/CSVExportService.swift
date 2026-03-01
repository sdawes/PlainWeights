//
//  CSVExportService.swift
//  PlainWeights
//
//  Service for exporting workout data as CSV.
//

import Foundation
import SwiftData

enum CSVExportService {

    /// Export all workout data to a CSV file on a background thread.
    /// - Parameters:
    ///   - container: The SwiftData model container
    ///   - weightUnit: User's preferred weight unit (kg/lbs)
    /// - Returns: URL of the temporary CSV file
    static func exportToCSV(container: ModelContainer, weightUnit: WeightUnit) async throws -> URL {
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let exerciseDescriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
        let exercises = try context.fetch(exerciseDescriptor)

        let weightHeader = "Weight (\(weightUnit.rawValue))"
        let header = "Exercise,Tags,Date,Time,\(weightHeader),Reps,Warm Up,Drop Set,Assisted,Pause at Top,Timed Set,Tempo (s),PB,Rest (s),Notes\n"

        var csv = header

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        for exercise in exercises {
            let sets = (exercise.sets ?? []).sorted { $0.timestamp < $1.timestamp }
            let escapedName = escapeCSVField(exercise.name)
            let allTags = exercise.tags + exercise.secondaryTags
            let escapedTags = escapeCSVField(allTags.joined(separator: ", "))
            let escapedNotes = escapeCSVField(exercise.note ?? "")

            for set in sets {
                let date = dateFormatter.string(from: set.timestamp)
                let time = timeFormatter.string(from: set.timestamp)
                let weight = weightUnit.fromKg(set.weight)
                let weightString = formatWeight(weight)
                let reps = String(set.reps)
                let warmUp = set.isWarmUp ? "Yes" : ""
                let dropSet = set.isDropSet ? "Yes" : ""
                let assisted = set.isAssisted ? "Yes" : ""
                let pauseAtTop = set.isPauseAtTop ? "Yes" : ""
                let timedSet = set.isTimedSet ? "Yes" : ""
                let tempo = set.isTimedSet && set.tempoSeconds > 0 ? String(set.tempoSeconds) : ""
                let pb = set.isPB ? "Yes" : ""
                let rest = set.restSeconds.map { String($0) } ?? ""

                let row = "\(escapedName),\(escapedTags),\(date),\(time),\(weightString),\(reps),\(warmUp),\(dropSet),\(assisted),\(pauseAtTop),\(timedSet),\(tempo),\(pb),\(rest),\(escapedNotes)\n"
                csv.append(row)
            }
        }

        let fileName = "PlainWeights-Export-\(dateFormatter.string(from: Date())).csv"
        let fileURL = FileManager.default.temporaryDirectory.appending(path: fileName)
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    /// Escape a field for CSV: wrap in quotes if it contains commas, quotes, or newlines.
    /// Double any existing quotes per RFC 4180.
    private static func escapeCSVField(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") else {
            return field
        }
        let escaped = field.replacing("\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    /// Format weight value, dropping trailing zeros (e.g. 60.0 → "60", 62.5 → "62.5")
    private static func formatWeight(_ value: Double) -> String {
        if value == value.rounded(.towardZero) && value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(value)
    }
}
