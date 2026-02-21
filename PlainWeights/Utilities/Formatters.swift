//
//  Formatters.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation

/// Shared formatting utilities for the app
enum Formatters {

    // MARK: - Cached Formatters

    /// Cached volume formatter for performance
    private static let volumeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter
    }()

    /// Cached date formatter for delta display
    private static let deltaDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"  // e.g., "Thu 14 Aug"
        return formatter
    }()

    /// Cached date formatter for day headers
    private static let dayHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"  // e.g., "Thursday, 14 August 2025"
        return formatter
    }()

    /// Cached time formatter for set timestamps (HH:mm format)
    private static let timeHMFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"  // 24-hour format
        formatter.locale = Locale(identifier: "en_GB_POSIX")  // Consistent formatting
        return formatter
    }()

    // MARK: - Volume Formatting

    /// Format volume with grouping separators (e.g., "1,250")
    static func formatVolume(_ volume: Double) -> String {
        volumeFormatter.string(from: NSNumber(value: volume)) ?? "0"
    }

    /// Format weight value, showing decimals only when needed (e.g., "100", "100.5", or "100.25")
    static func formatWeight(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return value.formatted(.number.precision(.fractionLength(0)))
        } else if (value * 10).truncatingRemainder(dividingBy: 1) == 0 {
            return value.formatted(.number.precision(.fractionLength(1)))
        } else {
            return value.formatted(.number.precision(.fractionLength(2)))
        }
    }

    /// Format weight for text field input (no grouping separators, parseable by Double())
    static func formatWeightForInput(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return value.formatted(.number.precision(.fractionLength(0)).grouping(.never))
        } else if (value * 10).truncatingRemainder(dividingBy: 1) == 0 {
            return value.formatted(.number.precision(.fractionLength(1)).grouping(.never))
        } else {
            return value.formatted(.number.precision(.fractionLength(2)).grouping(.never))
        }
    }

    /// Format weight value in specified unit with unit suffix (e.g., "100 kg" or "220 lbs")
    /// - Parameters:
    ///   - kg: Weight value in kilograms (storage unit)
    ///   - unit: The unit to display in
    /// - Returns: Formatted string with unit suffix
    static func formatWeightWithUnit(_ kg: Double, unit: WeightUnit) -> String {
        let displayValue = unit.fromKg(kg)
        return "\(formatWeight(displayValue)) \(unit.displayName)"
    }

    /// Format volume value in specified unit with unit suffix (e.g., "1,250 kg" or "2,756 lbs")
    static func formatVolumeWithUnit(_ kg: Double, unit: WeightUnit) -> String {
        let displayValue = unit.fromKg(kg)
        return "\(formatVolume(displayValue)) \(unit.displayName)"
    }

    // MARK: - Date Formatting

    /// Format date for delta display (e.g., "Thu 14 Aug")
    static func formatDeltaDate(_ date: Date) -> String {
        deltaDateFormatter.string(from: date)
    }

    /// Format date for day headers (e.g., "Thursday, 14 August 2025")
    static func formatDayHeader(_ date: Date) -> String {
        dayHeaderFormatter.string(from: date)
    }
    
    /// Format date for abbreviated day headers (e.g., "Thu 14 Aug")
    static func formatAbbreviatedDayHeader(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated).day().month(.abbreviated))
    }

    /// Format date for full day headers (e.g., "Sunday, Jan 25")
    static func formatFullDayHeader(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().weekday(.wide).month(.abbreviated).day())
    }

    /// Format time for set timestamps (e.g., "14:30")
    static func formatTimeHM(_ date: Date) -> String {
        timeHMFormatter.string(from: date)
    }

    /// Format duration in minutes:seconds (e.g., "0:00", "1:30", "3:45")
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        let paddedSeconds = remainingSeconds < 10 ? "0\(remainingSeconds)" : "\(remainingSeconds)"
        return "\(minutes):\(paddedSeconds)"
    }

    /// Format exercise last done date with smart relative display
    /// - Parameter date: The date the exercise was last performed
    /// - Returns: Smart formatted string like "yesterday", "3 days ago", "last week", etc.
    static func formatExerciseLastDone(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        // Get start of day for both dates to compare calendar days
        let startOfToday = calendar.startOfDay(for: now)
        let startOfExerciseDay = calendar.startOfDay(for: date)

        // Calculate difference in days
        let daysDifference = calendar.dateComponents([.day], from: startOfExerciseDay, to: startOfToday).day ?? 0

        // Handle different cases based on calendar days
        if daysDifference == 0 {
            return "today"
        } else if daysDifference == 1 {
            return "yesterday"
        } else if daysDifference >= 2 && daysDifference <= 6 {
            return "\(daysDifference) days ago"
        } else if daysDifference >= 7 && daysDifference <= 13 {
            return "last week"
        } else if daysDifference >= 14 && daysDifference <= 27 {
            let weeks = daysDifference / 7
            return "\(weeks) weeks ago"
        } else if daysDifference >= 28 && daysDifference <= 59 {
            return "last month"
        } else if daysDifference >= 60 && daysDifference <= 364 {
            let months = daysDifference / 30
            if months == 1 {
                return "last month"
            } else {
                return "\(months) months ago"
            }
        } else if daysDifference >= 365 && daysDifference < 730 {
            return "last year"
        } else {
            let years = daysDifference / 365
            return "\(years) years ago"
        }
    }

    /// Format date for workout journal with Today/Yesterday shortcuts
    static func formatWorkoutDayLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if date == today {
            return "Today"
        } else if date == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Yesterday"
        } else {
            return formatAbbreviatedDayHeader(date)
        }
    }
    
    // MARK: - Progress Text Formatting

    /// Format delta text with percentage and comparison date
    static func formatDeltaText(
        todayVolume: Double,
        lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int, isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool)?,
        unit: WeightUnit = .kg
    ) -> String {
        guard let lastInfo = lastCompletedDayInfo else {
            return "Baseline day"
        }

        let delta = todayVolume - lastInfo.volume
        let displayDelta = unit.fromKg(delta)
        let sign = delta >= 0 ? "+" : ""
        let dateFormatted = formatDeltaDate(lastInfo.date)

        let percentPart: String
        if lastInfo.volume > 0 {
            let deltaPercent = Int(round((delta / lastInfo.volume) * 100))
            let pSign = deltaPercent >= 0 ? "+" : ""
            percentPart = " (\(pSign)\(deltaPercent)%)"
        } else {
            percentPart = ""
        }

        return "\(sign)\(formatVolume(displayDelta)) \(unit.displayName)\(percentPart) vs \(dateFormatted)"
    }
}