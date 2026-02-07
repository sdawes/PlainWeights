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
                    .font(themeManager.effectiveTheme.interFont(size: 14, weight: .medium))
                    .foregroundStyle(themeManager.effectiveTheme.primaryText)

                Spacer()

                HStack(spacing: 6) {
                    if isWeightedDay {
                        HStack(spacing: 2) {
                            Text(Formatters.formatVolume(volume))
                                .font(themeManager.effectiveTheme.dataFont(size: 13, weight: .semibold))
                            Text("kg")
                                .font(themeManager.effectiveTheme.dataFont(size: 13))
                        }
                    } else {
                        HStack(spacing: 2) {
                            Text("\(totalReps)")
                                .font(themeManager.effectiveTheme.dataFont(size: 13, weight: .semibold))
                            Text("reps")
                                .font(themeManager.effectiveTheme.dataFont(size: 13))
                        }
                    }

                    if let duration = sessionDurationMinutes {
                        Text("•")
                        Text("\(duration) min")
                            .font(themeManager.effectiveTheme.dataFont(size: 13))
                    }
                }
                .font(themeManager.effectiveTheme.interFont(size: 13))
                .foregroundStyle(themeManager.effectiveTheme.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Divider after header
            Rectangle()
                .fill(themeManager.effectiveTheme.borderColor)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
        .background(themeManager.effectiveTheme.cardBackgroundColor)
        .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
        .overlay(
            TopOpenBorder(radius: 12)
                .stroke(themeManager.effectiveTheme.borderColor, lineWidth: 1)
        )
    }
}
