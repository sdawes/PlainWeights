//
//  ExerciseProgressIndicator.swift
//  PlainWeights
//
//  Displays progress indicators for exercise list rows
//

import SwiftUI

struct ExerciseProgressIndicator: View {
    @Environment(ThemeManager.self) private var themeManager
    let progress: RecentProgressCalculator.RecentProgressIndicators

    var body: some View {
        HStack(spacing: 8) {
            // Weight
            if progress.weightImprovement != 0 {
                Text(formatDelta(progress.weightImprovement, suffix: "kg"))
                    .foregroundStyle(progress.weightDirection.progressColor)
            }
            // Reps
            if progress.repsImprovement != 0 {
                Text(formatDelta(Double(progress.repsImprovement), suffix: "r"))
                    .foregroundStyle(progress.repsDirection.progressColor)
            }
            // Volume
            if progress.volumeImprovement != 0 {
                Text(formatDelta(progress.volumeImprovement, suffix: "vol"))
                    .foregroundStyle(progress.volumeDirection.progressColor)
            }
        }
        .font(themeManager.currentTheme.interFont(size: 12, weight: .medium))
    }

    private func formatDelta(_ value: Double, suffix: String) -> String {
        let sign = value > 0 ? "+" : ""
        let formatted = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        return "\(sign)\(formatted)\(suffix)"
    }
}
