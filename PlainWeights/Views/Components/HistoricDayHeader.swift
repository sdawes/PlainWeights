//
//  HistoricDayHeader.swift
//  PlainWeights
//
//  Header for historic day sections in exercise detail view.
//  Must be a struct (not a function) for SwiftUI List to handle spacing correctly.
//

import SwiftUI

struct HistoricDayHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    let dayGroup: ExerciseDataGrouper.DayGroup
    let sessionDurationMinutes: Int?

    // Computed properties for display
    private var isWeightedDay: Bool {
        dayGroup.sets.filter { !$0.isWarmUp && !$0.isBonus }.contains { $0.weight > 0 }
    }

    private var volume: Double {
        ExerciseVolumeCalculator.calculateVolume(for: dayGroup.sets)
    }

    private var totalReps: Int {
        dayGroup.sets.reduce(0) { $0 + $1.reps }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(Formatters.formatFullDayHeader(dayGroup.date))
                    .font(themeManager.currentTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.currentTheme.secondaryText)

                Spacer()

                HStack(spacing: 6) {
                    if isWeightedDay {
                        Text("\(Formatters.formatVolume(volume)) kg")
                            .font(themeManager.currentTheme.dataFont(size: 13))
                    } else {
                        Text("\(totalReps) reps")
                            .font(themeManager.currentTheme.dataFont(size: 13))
                    }

                    if let duration = sessionDurationMinutes {
                        Text("•")
                        Text("\(duration) min")
                            .font(themeManager.currentTheme.dataFont(size: 13))
                    }
                }
                .font(themeManager.currentTheme.interFont(size: 13))
                .foregroundStyle(themeManager.currentTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // Divider after header
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .background(themeManager.currentTheme.muted.opacity(0.3))
        .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
        .overlay(
            TopOpenBorder(radius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }
}
