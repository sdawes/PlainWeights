//
//  Formatters.swift
//  PlainWeights
//
//  Created by Stephen Dawes on 04/09/2025.
//

import Foundation

/// Shared formatting utilities for the app
enum Formatters {
    
    // MARK: - Volume Formatting
    
    /// Format volume with grouping separators (e.g., "1,250")
    static func formatVolume(_ volume: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: volume)) ?? "0"
    }
    
    /// Format weight value, showing decimals only when needed (e.g., "100" or "100.5")
    static func formatWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? 
            String(format: "%.0f", value) : 
            String(format: "%.1f", value)
    }
    
    // MARK: - Date Formatting
    
    /// Format date for delta display (e.g., "Thu 14 Aug")
    static func formatDeltaDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"  // e.g., "Thu 14 Aug"
        return formatter.string(from: date)
    }
    
    /// Format date for day headers (e.g., "Thursday, 14 August 2025")
    static func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"  // e.g., "Thursday, 14 August 2025"
        return formatter.string(from: date)
    }
    
    /// Format date for abbreviated day headers (e.g., "Thu 14 Aug")
    static func formatAbbreviatedDayHeader(_ date: Date) -> String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated).day().month(.abbreviated))
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
        lastCompletedDayInfo: (date: Date, volume: Double, maxWeight: Double, maxWeightReps: Int)?
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