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

    /// Format weight value, showing decimals only when needed (e.g., "100" or "100.5")
    static func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", value) :
            String(format: "%.1f", value)
    }

    // MARK: - Relative Date Formatting

    /// Cached relative date formatter
    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    /// Format date as relative string (e.g., "3 days ago", "yesterday", "2 weeks ago")
    static func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        // If it's today, show "Today"
        if calendar.isDateInToday(date) {
            return "Today"
        }

        // If it's yesterday, show "Yesterday"
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        // For dates within the last week, show relative format
        let daysDiff = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        if daysDiff <= 7 {
            return relativeDateFormatter.localizedString(for: date, relativeTo: now)
        }

        // For older dates, show "Mon 23 Dec" format
        return deltaDateFormatter.string(from: date)
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
        return String(format: "%d:%02d", minutes, remainingSeconds)
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
        lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int, isDropSet: Bool, isPauseAtTop: Bool, isTimedSet: Bool, tempoSeconds: Int, isPB: Bool)?
    ) -> String {
        guard let lastInfo = lastCompletedDayInfo else {
            return "Baseline day"
        }

        let delta = todayVolume - lastInfo.volume
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

        return "\(sign)\(formatVolume(delta)) kg\(percentPart) vs \(dateFormatted)"
    }
}