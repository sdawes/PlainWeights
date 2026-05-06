//
//  CSVExportService.swift
//  PlainWeights
//
//  Service for exporting workout data as CSV.
//

import Foundation
import SwiftData

/// User-selectable time range for the CSV export.
enum CSVExportRange: String, CaseIterable, Identifiable {
    case sixMonths = "Last 6 months"
    case oneYear   = "Last year"
    case threeYears = "Last 3 years"
    case all       = "All data"

    var id: String { rawValue }

    /// Inclusive lower-bound timestamp. `nil` means "no filter — all data".
    var cutoff: Date? {
        let now = Date()
        let calendar = Calendar.current
        switch self {
        case .sixMonths:  return calendar.date(byAdding: .month, value: -6, to: now)
        case .oneYear:    return calendar.date(byAdding: .year,  value: -1, to: now)
        case .threeYears: return calendar.date(byAdding: .year,  value: -3, to: now)
        case .all:        return nil
        }
    }

    /// Short suffix used in the exported filename.
    var fileSuffix: String {
        switch self {
        case .sixMonths:  return "6mo"
        case .oneYear:    return "1yr"
        case .threeYears: return "3yr"
        case .all:        return "all"
        }
    }
}

enum CSVExportService {

    /// Export workout data to a CSV file.
    /// - Parameters:
    ///   - container: The SwiftData model container
    ///   - weightUnit: User's preferred weight unit (kg/lbs)
    ///   - range: Time range to include. `.all` exports every set ever logged.
    /// - Returns: URL of the temporary CSV file
    static func exportToCSV(
        container: ModelContainer,
        weightUnit: WeightUnit,
        range: CSVExportRange = .all
    ) throws -> sending URL {
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let exerciseDescriptor = FetchDescriptor<Exercise>()
        let exercises = try context.fetch(exerciseDescriptor).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        let weightHeader = "Weight (\(weightUnit.rawValue))"
        let header = "Exercise,Muscle Tags,Date,Time,\(weightHeader),Reps,Warm Up,Drop Set,Assisted,Pause at Top,Timed Set,Tempo (s),PB,Rest (s),Notes\n"

        var csv = header

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")

        let cutoff = range.cutoff

        for exercise in exercises {
            let allSets = (exercise.sets ?? []).sorted { $0.timestamp < $1.timestamp }
            let sets = cutoff.map { c in allSets.filter { $0.timestamp >= c } } ?? allSets
            // Skip exercises that have no sets in the selected range so
            // the CSV doesn't pad with empty exercise rows.
            guard !sets.isEmpty else { continue }
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

        let fileName = "PlainWeights-Export-\(dateFormatter.string(from: Date()))-\(range.fileSuffix).csv"
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
