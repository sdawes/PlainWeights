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
        dayGroup.sets.workingSets.contains { $0.weight > 0 }
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
                    .foregroundStyle(themeManager.currentTheme.primaryText)

                Spacer()

                HStack(spacing: 6) {
                    if isWeightedDay {
                        HStack(spacing: 2) {
                            Text(Formatters.formatVolume(volume))
                                .font(themeManager.currentTheme.dataFont(size: 13, weight: .semibold))
                            Text("kg")
                                .font(themeManager.currentTheme.dataFont(size: 13))
                        }
                    } else {
                        HStack(spacing: 2) {
                            Text("\(totalReps)")
                                .font(themeManager.currentTheme.dataFont(size: 13, weight: .semibold))
                            Text("reps")
                                .font(themeManager.currentTheme.dataFont(size: 13))
                        }
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
            .padding(.vertical, 14)

            // Divider after header
            Rectangle()
                .fill(themeManager.currentTheme.borderColor)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
        .overlay(
            TopOpenBorder(radius: 12)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
    }
}
